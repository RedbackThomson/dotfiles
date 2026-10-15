# Functions that can exit publish results through globals instead of stdout:
# an `exit` inside a command substitution only ends the subshell.

readonly EXIT_USAGE=2
readonly EXIT_CANCELLED=130

CREATED_WORKSPACE=
PROBE_DIR=

die() {
  printf 'dev: %s\n' "$*" >&2
  if [ -n "$CREATED_WORKSPACE" ]; then
    printf 'dev: workspace %s was created and still exists; reopen it with "dev resume %s" or remove it with "dev finish %s"\n' \
      "$CREATED_WORKSPACE" "$CREATED_WORKSPACE" "$CREATED_WORKSPACE" >&2
  fi
  exit 1
}

warn() {
  printf 'dev: %s\n' "$*" >&2
}

usage_error() {
  printf 'dev: %s\n' "$*" >&2
  printf 'Run "dev help" for usage.\n' >&2
  exit "$EXIT_USAGE"
}

usage() {
  cat <<'EOF'
Usage:
  dev start [--from REVISION] [--dry-run] [REPOSITORY] [WORKSPACE]
  dev resume [REPOSITORY/WORKSPACE]
  dev finish [--yes] [--dry-run] [REPOSITORY/WORKSPACE]
  dev list

Defaults:
  REPOSITORY   selected with fzf from the repository root
  WORKSPACE    prompted for by start; finish uses the current workspace;
               otherwise selected with fzf
  REVISION     main@upstream, resolved after fetching upstream

Environment:
  DEV_REPO_ROOT   overrides the repository root configured in Nix
  JJ_WORKSPACES   workspace base (default $XDG_DATA_HOME/jj-workspaces)
  DEV_TRASH_DIR   where finish moves workspace files (default ~/.Trash)

finish stops the Zellij session, snapshots the working copy, forgets the
workspace in jj and moves its files to the trash. It never pushes, abandons
non-empty changes, or deletes bookmarks. Run from inside the workspace's own
session, it confirms first and then finishes in the background, logging to
$XDG_STATE_HOME/dev.
EOF
}

has_control_chars() {
  [[ $1 == *[$'\t\n\r']* ]]
}

valid_workspace_name() {
  [[ $1 =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] && [ "$1" != default ]
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

jj_ro() {
  jj --no-pager --color=never --ignore-working-copy "$@"
}

# Runs zellij with the caller's PATH rather than this wrapper's, because a
# newly created session server passes its environment to every pane.
zellij_clean() {
  env -u ZELLIJ -u ZELLIJ_SESSION_NAME -u ZELLIJ_PANE_ID \
    PATH="$USER_PATH" "$ZELLIJ_BIN" "$@"
}

resolve_repo_root() {
  local root=${DEV_REPO_ROOT:-$DEV_DEFAULT_REPO_ROOT}
  [ -n "$root" ] || die 'no repository root: set repoRoot in the Nix package or export DEV_REPO_ROOT'
  [[ $root == /* ]] || die "repository root must be an absolute path: $root"
  [ -d "$root" ] || die "repository root does not exist: $root"
  REPO_ROOT=$(realpath -e -- "$root") || die "cannot resolve repository root: $root"
}

# Must agree with the `jj wa` alias, which treats an empty JJ_WORKSPACES as
# unset and rejects relative bases.
resolve_workspaces_base() {
  local base=${JJ_WORKSPACES:-${XDG_DATA_HOME:-$HOME/.local/share}/jj-workspaces}
  [[ $base == /* ]] || die "workspace base must be an absolute path: $base"
  has_control_chars "$base" && die 'workspace base contains a tab or newline'
  WORKSPACES_BASE=$(realpath -m -- "$base") || die "cannot resolve workspace base: $base"
}

# Sets WS_NAMES and WS_ROOTS for every workspace of the repository at $1.
load_workspaces() {
  local out name root
  WS_NAMES=()
  WS_ROOTS=()
  out=$(jj_ro -R "$1" workspace list -T 'name ++ "\t" ++ if(root, root, "") ++ "\n"') || return 1
  while IFS=$'\t' read -r name root; do
    [ -n "$name" ] || continue
    WS_NAMES+=("$name")
    WS_ROOTS+=("$root")
  done <<<"$out"
}

# Sets V_NAME and V_DEFAULT when $1 is a non-default workspace registered in
# jj at exactly $base/<basename of default root>/<name>; otherwise sets V_ERR.
verify_workspace() {
  local dir=$1 base=$2 real i root real_root parent current
  V_NAME=
  V_DEFAULT=
  V_ERR=
  if has_control_chars "$dir"; then
    V_ERR='path contains a tab or newline'
    return 1
  fi
  if [ -L "$dir" ]; then
    V_ERR='workspace path is a symlink'
    return 1
  fi
  real=$(realpath -e -- "$dir" 2>/dev/null) || {
    V_ERR='workspace path does not resolve'
    return 1
  }
  parent=$(dirname -- "$real")
  if [ "$real" != "$dir" ] || [ "$(dirname -- "$parent")" != "$base" ]; then
    V_ERR="not directly at $base/<repository>/<workspace>"
    return 1
  fi
  if [ ! -d "$real/.jj" ] || [ -L "$real/.jj" ]; then
    V_ERR='no .jj directory'
    return 1
  fi
  load_workspaces "$real" 2>/dev/null || {
    V_ERR='jj cannot load this workspace'
    return 1
  }
  # The recorded root is unset after `jj op revert` of a forget, so identity
  # comes from which workspace has this checkout's @ as its working copy.
  current=$(jj_ro -R "$real" log -r @ --no-graph -T 'working_copies.map(|w| w.name()).join("\n")' 2>/dev/null) || {
    V_ERR='jj cannot resolve the working-copy commit'
    return 1
  }
  if [[ $current == *$'\n'* ]]; then
    V_ERR='several jj workspaces share this working-copy commit'
    return 1
  fi

  for i in "${!WS_NAMES[@]}"; do
    root=${WS_ROOTS[$i]}
    real_root=
    if [ -n "$root" ]; then
      real_root=$(realpath -e -- "$root" 2>/dev/null) || real_root=
    fi
    if [ "${WS_NAMES[$i]}" = default ]; then
      V_DEFAULT=$real_root
    elif [ "${WS_NAMES[$i]}" = "$current" ]; then
      if [ -n "$root" ] && [ "$real_root" != "$real" ]; then
        V_ERR="jj records workspace \"$current\" at $root"
        return 1
      fi
      V_NAME=$current
    elif [ -n "$real_root" ] && [ "$real_root" = "$real" ]; then
      V_ERR="jj records workspace \"${WS_NAMES[$i]}\" at this path"
      return 1
    fi
  done

  if [ -z "$V_NAME" ]; then
    V_ERR='not registered as a non-default jj workspace at this path'
  elif [ "$V_NAME" != "$(basename -- "$real")" ]; then
    V_ERR="registered as \"$V_NAME\", which does not match the directory name"
  elif ! valid_workspace_name "$V_NAME"; then
    V_ERR="unsupported workspace name: $V_NAME"
  elif [ -z "$V_DEFAULT" ]; then
    V_ERR='the default workspace root cannot be resolved'
  elif [ "$V_DEFAULT" = "$real" ]; then
    V_ERR='this is the default workspace'
  elif [ "$(basename -- "$V_DEFAULT")" != "$(basename -- "$parent")" ]; then
    V_ERR="belongs to $V_DEFAULT, not a repository named $(basename -- "$parent")"
  else
    return 0
  fi
  return 1
}

# Sets REC_LABELS, REC_PATHS, REC_NAMES and REC_DEFAULTS for every verified
# workspace under the workspace base.
scan_workspaces() {
  local -a dirs=()
  local dir
  REC_LABELS=()
  REC_PATHS=()
  REC_NAMES=()
  REC_DEFAULTS=()
  resolve_workspaces_base
  [ -d "$WORKSPACES_BASE" ] || return 0

  mapfile -d '' -t dirs < <(find "$WORKSPACES_BASE" -mindepth 2 -maxdepth 2 -type d -print0 | sort -z)
  wait "$!" || die "could not scan $WORKSPACES_BASE"

  for dir in "${dirs[@]}"; do
    if verify_workspace "$dir" "$WORKSPACES_BASE"; then
      REC_LABELS+=("$(basename -- "$(dirname -- "$dir")")/$V_NAME")
      REC_PATHS+=("$dir")
      REC_NAMES+=("$V_NAME")
      REC_DEFAULTS+=("$V_DEFAULT")
    else
      warn "skipping $dir: $V_ERR"
    fi
  done
}

# Sets PICKED to the chosen line; cancelling exits the whole command.
pick() {
  local prompt=$1 status=0
  shift
  PICKED=$(fzf --prompt="$prompt" --height=40% --reverse < <(printf '%s\n' "$@")) || status=$?
  case $status in
    0) ;;
    1 | 130) exit "$EXIT_CANCELLED" ;;
    *) die "fzf failed with exit status $status" ;;
  esac
}

# Sets REPO to the canonical path of the selected repository.
select_repo() {
  local requested=$1 path candidate
  local -a names=()

  if [ -n "$requested" ]; then
    if [[ $requested == */* ]]; then
      path=$requested
    else
      resolve_repo_root
      path=$REPO_ROOT/$requested
    fi
    [ -d "$path" ] || die "repository not found: $requested"
    [ -d "$path/.jj" ] || die "not a Jujutsu repository: $path"
    REPO=$(realpath -e -- "$path") || die "cannot resolve repository: $path"
    has_control_chars "$REPO" && die 'repository path contains a tab or newline'
    return 0
  fi

  resolve_repo_root
  for candidate in "$REPO_ROOT"/*/; do
    candidate=${candidate%/}
    if [ ! -d "$candidate/.jj" ] || [ -L "$candidate" ]; then
      continue
    fi
    if has_control_chars "$candidate"; then
      warn "skipping repository with a tab or newline in its name: $candidate"
      continue
    fi
    names+=("$(basename -- "$candidate")")
  done
  [ "${#names[@]}" -gt 0 ] || die "no Jujutsu repositories found directly under $REPO_ROOT"

  require_command fzf
  pick 'Repository > ' "${names[@]}"
  REPO=$REPO_ROOT/$PICKED
}

# Sets CURRENT_INDEX to the record for the workspace containing the working
# directory or, failing that, the one whose Zellij session this runs in.
find_current_workspace() {
  local root i
  CURRENT_INDEX=''
  if root=$(jj_ro workspace root 2>/dev/null) && root=$(realpath -e -- "$root" 2>/dev/null); then
    for i in "${!REC_PATHS[@]}"; do
      if [ "${REC_PATHS[$i]}" = "$root" ]; then
        CURRENT_INDEX=$i
        return 0
      fi
    done
  fi
  [ -n "${ZELLIJ_SESSION_NAME:-}" ] || return 0
  for i in "${!REC_PATHS[@]}"; do
    session_name_for "${REC_DEFAULTS[$i]}" "${REC_NAMES[$i]}"
    if [ "$SESSION" = "$ZELLIJ_SESSION_NAME" ]; then
      CURRENT_INDEX=$i
      return 0
    fi
  done
}

# Sets WS_PATH, WS_NAME, WS_DEFAULT and WS_LABEL for the selected workspace.
# With prefer_current, an empty request selects the current workspace if any.
select_workspace() {
  local requested=$1 prefer_current=${2:-false} i match='' count=0 real

  scan_workspaces
  [ "${#REC_PATHS[@]}" -gt 0 ] || die "no workspaces found under $WORKSPACES_BASE"

  if [ -z "$requested" ] && [ "$prefer_current" = true ]; then
    find_current_workspace
    if [ -n "$CURRENT_INDEX" ]; then
      requested=${REC_LABELS[$CURRENT_INDEX]}
      printf 'Using current workspace %s\n' "$requested" >&2
    fi
  fi

  if [ -z "$requested" ]; then
    require_command fzf
    pick 'Workspace > ' "${REC_LABELS[@]}"
    requested=$PICKED
  fi

  for i in "${!REC_LABELS[@]}"; do
    if [ "${REC_LABELS[$i]}" = "$requested" ]; then
      match=$i
      count=1
      break
    fi
  done
  if [ "$count" -eq 0 ] && [ -d "$requested" ]; then
    real=$(realpath -e -- "$requested") || die "cannot resolve $requested"
    for i in "${!REC_PATHS[@]}"; do
      if [ "${REC_PATHS[$i]}" = "$real" ]; then
        match=$i
        count=1
      fi
    done
    [ "$count" -eq 1 ] || die "not a verified dev workspace: $real"
  fi
  if [ "$count" -eq 0 ]; then
    for i in "${!REC_NAMES[@]}"; do
      if [ "${REC_NAMES[$i]}" = "$requested" ]; then
        match=$i
        count=$((count + 1))
      fi
    done
  fi
  [ "$count" -gt 0 ] || die "workspace not found: $requested"
  [ "$count" -eq 1 ] || die "workspace name is ambiguous; use REPOSITORY/WORKSPACE: $requested"

  WS_PATH=${REC_PATHS[$match]}
  WS_NAME=${REC_NAMES[$match]}
  WS_DEFAULT=${REC_DEFAULTS[$match]}
  WS_LABEL=${REC_LABELS[$match]}
}

# Zellij session names are capped at ~24 bytes by the macOS socket path limit,
# so the readable prefix is truncated and the hash of the canonical default
# root and workspace name keeps truncated or punctuated names distinct.
session_name_for() {
  local default_root=$1 name=$2 repo hash
  repo=$(basename -- "$default_root")
  repo=${repo//[^A-Za-z0-9]/_}
  name=${name//[^A-Za-z0-9]/_}
  hash=$(printf '%s\0%s' "$default_root" "$2" | sha256sum) || die 'sha256sum failed'
  SESSION=${repo:0:6}-${name:0:8}-${hash:0:6}
}

# Sets SESSION_STATES[name] to "running" or "exited" for every Zellij session.
load_sessions() {
  local out='' line name
  declare -gA SESSION_STATES=()
  # list-sessions exits non-zero when there are no sessions at all.
  out=$("$ZELLIJ_BIN" list-sessions --no-formatting 2>/dev/null) || true
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    name=${line%% \[Created*}
    if [[ $line == *'(EXITED'* ]]; then
      SESSION_STATES[$name]=exited
    else
      SESSION_STATES[$name]=running
    fi
  done <<<"$out"
}

session_state() {
  load_sessions
  SESSION_STATE=${SESSION_STATES[$1]:-none}
}

open_session() {
  local workspace=$1 session=$2

  session_state "$session"
  if [ "$SESSION_STATE" = none ]; then
    require_command claude
    require_command zsh
    [ -f "$DEV_ZELLIJ_LAYOUT" ] || die "layout not found: $DEV_ZELLIJ_LAYOUT"
  fi

  if [ -z "${ZELLIJ:-}" ]; then
    cd -- "$workspace"
    if [ "$SESSION_STATE" = none ]; then
      exec env PATH="$USER_PATH" "$ZELLIJ_BIN" attach --create "$session" options --default-layout "$DEV_ZELLIJ_LAYOUT"
    fi
    exec env PATH="$USER_PATH" "$ZELLIJ_BIN" attach "$session"
  fi

  if [ "${ZELLIJ_SESSION_NAME:-}" = "$session" ]; then
    printf 'Already in Zellij session %s\n' "$session"
    return 0
  fi
  # switch-session ignores --layout when it creates a session, so new and
  # exited sessions are started in the background first. Zellij 0.45.1 does
  # not deliver cached plugin permissions to background-started sessions
  # (zellij-org/zellij#5705), which leaves the zjstatus bar blank there.
  case $SESSION_STATE in
    none)
      (cd -- "$workspace" && zellij_clean attach --create-background "$session" \
        options --default-layout "$DEV_ZELLIJ_LAYOUT") ||
        die "could not create Zellij session $session"
      ;;
    exited)
      (cd -- "$workspace" && zellij_clean attach --create-background "$session") ||
        die "could not resurrect Zellij session $session"
      ;;
  esac
  "$ZELLIJ_BIN" action switch-session "$session" ||
    die "could not switch to Zellij session $session"
}

# Fails unless `jj wa` passes options after the name through to
# `jj workspace add`; an alias that drops them still exits 0.
check_wa_alias() {
  local status=0
  PROBE_DIR=$(mktemp -d "${TMPDIR:-/tmp}/dev-wa.XXXXXX") || die 'mktemp failed'
  trap 'rm -rf -- "$PROBE_DIR"' EXIT INT TERM
  (
    set -euo pipefail
    cd -- "$PROBE_DIR"
    jj git init repo
    cd repo
    jj new
    JJ_WORKSPACES=$PROBE_DIR/ws jj wa probe --revision 'root()'
    [ "$(jj_ro -R "$PROBE_DIR/ws/repo/probe" log -r '@-' --no-graph -T 'if(root, "root")')" = root ]
  ) >/dev/null 2>&1 || status=$?
  rm -rf -- "$PROBE_DIR"
  trap - EXIT INT TERM
  [ "$status" -eq 0 ] ||
    die 'the "jj wa" alias ignores --revision; activate the Home Manager generation that forwards workspace-add options'
}

# Copies the default workspace's .envrc (following a symlink to its target)
# without granting direnv trust.
copy_envrc() {
  local src=$1/.envrc dst=$2/.envrc
  [ -e "$src" ] || [ -L "$src" ] || return 0
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    printf 'Kept the .envrc from the checked-out revision; %s was not copied.\n' "$src"
    return 0
  fi
  if [ ! -f "$src" ]; then
    warn "not copying $src: it is not a regular file or a link to one"
    return 0
  fi
  cp --preserve=mode -- "$src" "$dst" || die "could not copy .envrc to $dst"
  printf 'Copied .envrc; review it, then run "direnv allow" in the workspace.\n'
}

start_command() {
  local from=main@upstream from_given=false dry_run=false repo_arg='' name='' name_given=false
  local out default_root repo_name parent dest commit has_upstream=false real child existing

  while [ "$#" -gt 0 ]; do
    case $1 in
      --from)
        [ "$#" -ge 2 ] || usage_error '--from requires a revision'
        from=$2
        from_given=true
        shift 2
        ;;
      --dry-run)
        dry_run=true
        shift
        ;;
      -h | --help)
        usage
        return 0
        ;;
      -*) usage_error "unknown start option: $1" ;;
      *)
        if [ -z "$repo_arg" ]; then
          repo_arg=$1
        elif [ "$name_given" = false ]; then
          name=$1
          name_given=true
        else
          usage_error 'start accepts at most a repository and a workspace name'
        fi
        shift
        ;;
    esac
  done
  [ -n "$from" ] || usage_error 'base revision cannot be empty'

  require_command jj
  require_command zellij
  if [ "$dry_run" = false ]; then
    require_command claude
    require_command zsh
    [ -f "$DEV_ZELLIJ_LAYOUT" ] || die "layout not found: $DEV_ZELLIJ_LAYOUT"
  fi

  select_repo "$repo_arg"

  if [ "$name_given" = false ]; then
    [ -t 0 ] || usage_error 'a workspace name is required when stdin is not a terminal'
    printf 'Workspace name: ' >&2
    IFS= read -r name || exit "$EXIT_CANCELLED"
  fi
  valid_workspace_name "$name" ||
    usage_error "invalid workspace name \"$name\": use letters, digits, dot, underscore or dash, starting with a letter or digit, and not \"default\""

  out=$(jj_ro -R "$REPO" workspace root --name default) ||
    die "$REPO has no workspace named \"default\""
  default_root=$(realpath -e -- "$out") || die "cannot resolve default workspace root: $out"
  has_control_chars "$default_root" && die 'default workspace path contains a tab or newline'

  resolve_workspaces_base
  repo_name=$(basename -- "$default_root")
  parent=$WORKSPACES_BASE/$repo_name
  dest=$parent/$name

  load_workspaces "$default_root" || die "cannot list workspaces of $default_root"
  for existing in "${WS_NAMES[@]}"; do
    [ "$existing" != "$name" ] || die "$repo_name already has a workspace named \"$name\""
  done
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    die "workspace destination already exists: $dest"
  fi
  if [ -L "$parent" ]; then
    die "refusing a symlinked repository directory: $parent"
  elif [ -e "$parent" ] && [ ! -d "$parent" ]; then
    die "not a directory: $parent"
  elif [ -d "$parent" ]; then
    for child in "$parent"/*/; do
      [ -d "$child" ] || continue
      child=${child%/}
      if verify_workspace "$child" "$WORKSPACES_BASE" && [ "$V_DEFAULT" != "$default_root" ]; then
        die "$parent already holds workspaces of $V_DEFAULT, which has the same directory name"
      fi
    done
  fi

  out=$(jj_ro -R "$default_root" git remote list) || die "cannot list remotes of $default_root"
  [[ $'\n'$out == *$'\nupstream '* ]] && has_upstream=true
  if [ "$has_upstream" = false ] && [ "$from_given" = false ]; then
    die "$repo_name has no \"upstream\" remote; pass --from REVISION"
  fi

  check_wa_alias
  session_name_for "$default_root" "$name"

  if [ "$dry_run" = true ]; then
    commit=$(jj_ro -R "$default_root" log -r "exactly($from, 1)" --no-graph -T 'commit_id.short(12)' 2>/dev/null) ||
      commit='(does not resolve to one commit before fetching)'
    if [ "$has_upstream" = true ]; then
      printf 'Would fetch:   upstream in %s\n' "$default_root"
    fi
    printf 'Would create:  %s\n' "$dest"
    printf 'Base revision: %s -> %s (last fetched, last snapshot)\n' "$from" "$commit"
    printf 'Zellij:        %s\n' "$SESSION"
    return 0
  fi

  if [ "$has_upstream" = true ]; then
    printf 'Fetching upstream for %s...\n' "$repo_name"
    jj --no-pager -R "$default_root" git fetch --remote upstream || die 'fetching upstream failed; nothing was created'
  fi

  commit=$(jj --no-pager --color=never -R "$default_root" log -r "exactly($from, 1)" --no-graph -T 'commit_id') ||
    die "revision \"$from\" does not resolve to exactly one commit; nothing was created"

  (cd -- "$default_root" && jj --no-pager wa "$name" --revision "$commit") || {
    if [ -e "$dest" ]; then
      CREATED_WORKSPACE=$repo_name/$name
    fi
    die "jj wa failed"
  }
  CREATED_WORKSPACE=$repo_name/$name

  real=$(realpath -e -- "$dest") || die "jj wa did not create $dest"
  verify_workspace "$real" "$WORKSPACES_BASE" || die "new workspace failed verification: $V_ERR"
  out=$(jj_ro -R "$real" log -r @ --no-graph -T 'parents.map(|c| c.commit_id()).join(" ")') ||
    die 'cannot read the new working-copy commit'
  [ "$out" = "$commit" ] || die "new working-copy commit has parent(s) $out, expected $commit"

  copy_envrc "$default_root" "$real"
  open_session "$real" "$SESSION"
}

resume_command() {
  [ "$#" -le 1 ] || usage_error 'resume accepts at most one workspace'
  require_command jj
  require_command zellij
  select_workspace "${1:-}"
  session_name_for "$WS_DEFAULT" "$WS_NAME"
  open_session "$WS_PATH" "$SESSION"
}

list_command() {
  local i
  [ "$#" -eq 0 ] || usage_error 'list does not accept arguments'
  require_command jj
  scan_workspaces
  if [ "${#REC_PATHS[@]}" -eq 0 ]; then
    printf 'No workspaces found under %s\n' "$WORKSPACES_BASE"
    return 0
  fi
  load_sessions
  printf '%-32s %-24s %-8s %s\n' WORKSPACE SESSION STATE PATH
  for i in "${!REC_PATHS[@]}"; do
    session_name_for "${REC_DEFAULTS[$i]}" "${REC_NAMES[$i]}"
    printf '%-32s %-24s %-8s %s\n' "${REC_LABELS[$i]}" "$SESSION" \
      "${SESSION_STATES[$SESSION]:-none}" "${REC_PATHS[$i]}"
  done
}

finish_command() {
  local assume_yes=false dry_run=false requested=''

  while [ "$#" -gt 0 ]; do
    case $1 in
      --yes)
        assume_yes=true
        shift
        ;;
      --dry-run)
        dry_run=true
        shift
        ;;
      -h | --help)
        usage
        return 0
        ;;
      -*) usage_error "unknown finish option: $1" ;;
      *)
        [ -z "$requested" ] || usage_error 'finish accepts at most one workspace'
        requested=$1
        shift
        ;;
    esac
  done

  require_command jj
  require_command zellij
  select_workspace "$requested" true
  session_name_for "$WS_DEFAULT" "$WS_NAME"
  session_state "$SESSION"

  printf 'Workspace:  %s\n' "$WS_LABEL"
  printf 'Path:       %s\n' "$WS_PATH"
  printf 'Repository: %s\n' "$WS_DEFAULT"
  printf 'Session:    %s (%s)\n\n' "$SESSION" "$SESSION_STATE"

  if [ "$dry_run" = true ]; then
    printf 'Status as of the last snapshot:\n'
    jj_ro -R "$WS_PATH" status || die 'jj status failed'
    printf '\nWould stop the session, snapshot the working copy, forget the workspace and move its files to %s.\n' \
      "${DEV_TRASH_DIR:-$HOME/.Trash}"
    return 0
  fi

  jj --no-pager -R "$WS_PATH" status || die 'jj status failed; nothing changed'

  if [ "$assume_yes" = false ]; then
    [ -t 0 ] || usage_error 'finish needs a terminal for confirmation, or --yes'
    require_command fzf
    printf '\n' >&2
    pick "Finish $WS_LABEL? > " 'No, keep it' "Yes, finish $WS_LABEL"
    [ "$PICKED" = "Yes, finish $WS_LABEL" ] || exit "$EXIT_CANCELLED"
  fi

  if [ "${ZELLIJ_SESSION_NAME:-}" = "$SESSION" ]; then
    finish_detached
  else
    finish_execute
  fi
}

# Stopping this session kills the process running finish, so the cleanup
# continues in a process outside the session's process tree.
finish_detached() {
  local log_dir log
  log_dir=${XDG_STATE_HOME:-$HOME/.local/state}/dev
  mkdir -p -- "$log_dir" || die "cannot create $log_dir"
  log=$log_dir/finish-${WS_LABEL//\//-}-$(date +%Y%m%d-%H%M%S).log
  nohup "$0" __finish-detached "$WS_PATH" </dev/null >"$log" 2>&1 &
  printf '\nFinishing %s in the background; this session will close.\nLog: %s\n' "$WS_LABEL" "$log"
}

finish_detached_command() {
  [ "$#" -eq 1 ] || usage_error '__finish-detached takes a workspace path'
  # The session's pty hangup signals the process group this was started in.
  trap '' HUP INT TERM
  cd /
  sleep 2
  select_workspace "$1"
  session_name_for "$WS_DEFAULT" "$WS_NAME"
  session_state "$SESSION"
  finish_execute
}

finish_execute() {
  local change op trash_dir target

  trash_dir=${DEV_TRASH_DIR:-$HOME/.Trash}
  [[ $trash_dir == /* ]] || die "trash directory must be an absolute path: $trash_dir"
  mkdir -p -- "$trash_dir" || die "cannot create $trash_dir"
  target=$trash_dir/dev-${WS_LABEL//\//-}-$(date +%Y%m%d-%H%M%S)-$$
  [ ! -e "$target" ] && [ ! -L "$target" ] || die "trash target already exists: $target"

  # Stopping first ensures no shell or Claude process writes after the snapshot.
  if [ "$SESSION_STATE" != none ]; then
    "$ZELLIJ_BIN" delete-session --force "$SESSION" >/dev/null ||
      die "could not stop Zellij session $SESSION; nothing else changed"
    session_state "$SESSION"
    [ "$SESSION_STATE" = none ] || die "Zellij session $SESSION is still present; nothing else changed"
  fi

  jj --no-pager -R "$WS_PATH" util snapshot >/dev/null ||
    die "snapshot failed; the session is stopped but the workspace is untouched (try \"jj workspace update-stale\" in $WS_PATH)"
  change=$(jj_ro -R "$WS_PATH" log -r @ --no-graph -T 'if(empty, "", change_id.short())') ||
    die 'cannot read the working-copy change; the session is stopped but the workspace is untouched'

  jj --no-pager --ignore-working-copy -R "$WS_DEFAULT" workspace forget "$WS_NAME" ||
    die "jj workspace forget failed; the session is stopped but the workspace is untouched; reopen with \"dev resume $WS_LABEL\""
  op=$(jj_ro -R "$WS_DEFAULT" op log -n 1 --no-graph -T 'id.short(16)') ||
    die "workspace forgotten, but its operation id is unknown; files remain at $WS_PATH"

  mv -T -- "$WS_PATH" "$target" ||
    die "workspace forgotten, but moving its files failed; they remain at $WS_PATH (undo the forget with: jj -R \"$WS_DEFAULT\" op revert $op)"

  printf '\nFinished %s.\n' "$WS_LABEL"
  printf 'Files moved to %s; its .jj link only resolves at the original path.\n' "$target"
  if [ -n "$change" ]; then
    printf 'Working-copy change %s remains in the repository.\n' "$change"
  fi
  printf 'To restore the workspace:\n  mv -- "%s" "%s"\n  jj -R "%s" op revert %s\n' \
    "$target" "$WS_PATH" "$WS_DEFAULT" "$op"
}

main() {
  local command=${1:-help}
  [ "$#" -eq 0 ] || shift

  USER_PATH=${PATH#"$DEV_RUNTIME_PATH":}
  ZELLIJ_BIN=$(command -v zellij || true)

  case $command in
    start) start_command "$@" ;;
    resume) resume_command "$@" ;;
    finish) finish_command "$@" ;;
    list) list_command "$@" ;;
    __finish-detached) finish_detached_command "$@" ;;
    help | -h | --help) usage ;;
    *) usage_error "unknown command: $command" ;;
  esac
}

main "$@"

# Invoked by Linear's "Work on issue -> Custom script" with LINEAR_* env vars.
# Linear runs this from a GUI context, so orca is called by absolute path and
# all output goes to the log file instead of a terminal.

orca=${LINEAR_ORCA_BIN:-/Applications/Orca.app/Contents/Resources/bin/orca}
agent=${LINEAR_ORCA_AGENT:-claude}
log=${LINEAR_ORCA_LOG:-$HOME/Library/Logs/linear-orca.log}

mkdir -p "$(dirname "$log")"
exec >>"$log" 2>&1

echo "=== $(date -Iseconds) ${LINEAR_ISSUE_IDENTIFIER:-<no issue>} workDir=${LINEAR_WORK_DIR:-<unset>}"
trap 'echo "FAILED (exit $?)"' ERR

issue=${LINEAR_ISSUE_IDENTIFIER:?LINEAR_ISSUE_IDENTIFIER not set}
work_dir=${LINEAR_WORK_DIR:?LINEAR_WORK_DIR not set}

# `worktree current` resolves both main checkouts and Orca worktrees; the repo
# list prefix match catches subdirectories Orca doesn't recognize as a worktree.
repo_id=$(cd "$work_dir" && "$orca" worktree current --json 2>/dev/null | jq -r '.result.worktree.repoId // empty' || true)
if [[ -z $repo_id ]]; then
  repo_id=$("$orca" repo list --json | jq -r --arg dir "$work_dir/" '
    [.result.repos[] | select(.path as $p | $dir | startswith($p + "/"))]
    | max_by(.path | length) | .id // empty')
fi
if [[ -z $repo_id ]]; then
  echo "no Orca repo contains $work_dir"
  exit 1
fi
echo "repo: $repo_id"

existing=$("$orca" reference find "$issue" --repo "id:$repo_id" --json | jq -r '
  [.result.matches[] | select(.workspace.kind == "worktree")][0].workspace.id // empty')
if [[ -n $existing ]]; then
  echo "activating existing worktree $existing"
  "$orca" worktree activate --worktree "id:$existing" --json
  exit 0
fi

prompt="${LINEAR_PROMPT:-Work on Linear issue $issue.}

Read the full ticket with \`orca linear issue $issue --full\`. Do not change the ticket's status or post comments or links to Linear."

create_args=(
  --repo "id:$repo_id"
  --no-parent
  --name "${issue,,}"
  --linear-issue "$issue"
  --agent "$agent"
  --prompt "$prompt"
  --activate
  --json
)
if [[ -n ${LINEAR_ISSUE_BRANCH_NAME:-} ]]; then
  create_args+=(--branch "$LINEAR_ISSUE_BRANCH_NAME")
fi

echo "creating worktree ${issue,,}"
"$orca" worktree create "${create_args[@]}"
echo "done"

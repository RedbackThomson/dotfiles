export WORDCHARS='*_-.[]~;!$%^(){}<>'
autoload -Uz select-word-style
select-word-style normal

source ~/.orbstack/shell/init.zsh 2>/dev/null || :

source $HOME/scripts/upbound-jump.sh
source $HOME/scripts/upbound-kubedebug.sh
source $HOME/scripts/kubectl-aliases.sh

source <(compdef _switcher switch)

export GOPATH=$(go env GOPATH)
export GOBIN=$GOPATH/bin

export PATH="/usr/local/bin:$PATH"
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

if [[ -f '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]]; then
  source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
  export NIX_PATH="$HOME/.config/.nix"
fi

export CLOUDSDK_PYTHON_SITEPACKAGES=1

setopt always_to_end          # When completing a word, move the cursor to the end of the word
setopt auto_cd                # cd by typing directory name if it's not a command
setopt auto_list              # automatically list choices on ambiguous completion
setopt auto_menu              # automatically use menu completion
setopt auto_pushd             # Make cd push each old directory onto the stack
setopt completeinword         # If unset, the cursor is set to the end of the word
setopt extended_history       # save each command's beginning timestamp and duration to the history file
setopt hash_list_all          # when command completion is attempted, ensure the entire  path is hashed
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_find_no_dups      # When searching history don't show results already cycled through twice
setopt hist_ignore_dups       # Do not write events to history that are duplicates of previous events
setopt hist_ignore_space      # remove command line from history list when first character is a space
setopt hist_reduce_blanks     # remove superfluous blanks from history items
setopt hist_verify            # show command with history expansion to user before running it
setopt histignorespace        # remove commands from the history when the first character is a space
setopt inc_append_history     # save history entries as soon as they are entered
setopt interactivecomments    # allow use of comments in interactive code (bash-style comments)
setopt longlistjobs           # display PID when suspending processes as well
setopt no_beep                # silence all bells and beeps
setopt no_share_history       # Explicitly don't share history
setopt nocaseglob             # global substitution is case insensitive
setopt nonomatch              # try to avoid the 'zsh: no matches found...'
setopt noshwordsplit          # use zsh style word splitting
setopt notify                 # report the status of backgrounds jobs immediately
setopt numeric_glob_sort      # globs sorted numerically
setopt prompt_subst           # allow expansion in prompts
setopt pushd_ignore_dups      # Don't push duplicates onto the stack
setopt share_history          # Share history between windows
unsetopt correct_all          # Don't attempt to correct supposed typos

bindkey "\e[1;3D" backward-word     # ⌥←
bindkey "\e[1;3C" forward-word      # ⌥→
bindkey "^[[1;9D" beginning-of-line # cmd+←
bindkey "^[[1;9C" end-of-line       # cmd+→

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down
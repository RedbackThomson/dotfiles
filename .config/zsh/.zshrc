autoload -Uz compinit
compinit -C
export WORDCHARS='*_-.[]~;!$%^(){}<>'
autoload -Uz select-word-style
select-word-style normal

eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(direnv hook zsh)"
eval "$(zoxide init zsh)"
source <(switcher init zsh)
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

source $HOME/scripts/upbound-jump.sh
source $HOME/scripts/upbound-kubedebug.sh
source $HOME/scripts/kubectl-aliases.sh

export TERM="xterm-256color"
export EDITOR="nvim"
export VISUAL="nvim"
export XDG_CONFIG_HOME="$HOME/.config"

alias cd="z"
alias cat="bat"
alias k="kubectl"
alias kubectx="switch"
alias la="ls -a"
alias ll="ls -al"
alias grep="grep --color=always"
alias s="switch"
alias vim="nvim"
source <(compdef _switcher switch)

export TMUX_CONF_LOCAL="$HOME/.config/tmux/tmux.conf.local"

export GOPATH=$(go env GOPATH)
export GOBIN=$GOPATH/bin

export PATH="/usr/local/bin:$PATH"
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
export PATH="$(brew --prefix)/share/google-cloud-sdk/bin:$PATH"
export PATH="$(go env GOBIN):$PATH"
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# coreutils cp is causing issues with Tilt - disable for now
# export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"

export K9S_CONFIG_DIR="$HOME/.config/k9s"
export OMP_CONFIG="$HOME/.omp.config.json"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config $OMP_CONFIG)"
fi

export CLOUDSDK_PYTHON_SITEPACKAGES=1

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

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

HISTFILE=${HOME}/.zsh_history
HISTSIZE=100000
SAVEHIST=${HISTSIZE}

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

source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

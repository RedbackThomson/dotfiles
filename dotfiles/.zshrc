source /apollo/env/envImprovement/var/zshrc

LANG="en_US.UTF-8"
LC_COLLATE="en_US.UTF-8"
LC_CTYPE="en_US.UTF-8"
LC_MESSAGES="en_US.UTF-8"
LC_MONETARY="en_US.UTF-8"
LC_NUMERIC="en_US.UTF-8"
LC_TIME="en_US.UTF-8"
LC_ALL="en_US.UTF-8"
ZSH="$HOME/.oh-my-zsh"

export PATH=~/.toolbox/bin:$PATH
export BRAZIL_WORKSPACE_DEFAULT_LAYOUT=short

alias k=kubectl

for f in SDETools envImprovement AmazonAwsCli OdinTools NodeJS; do
    if [[ -d /apollo/env/$f ]]; then
        export PATH=$PATH:/apollo/env/$f/bin
    fi
done

export AUTO_TITLE_SCREENS="NO"

export PROMPT="
%{$fg[white]%}(%D %*) <%?> [%~] $program %{$fg[default]%}
%{$fg[cyan]%}%m %#%{$fg[default]%} "

export RPROMPT=

set-title() {
    echo -e "\e]0;$*\007"
}

ssh() {
    set-title $*;
    /usr/bin/ssh -2 $*;
    set-title $HOST;
}

creds () {
    ada credentials update --account=$1 --provider=isengard --role=${2:-"Admin"} --once
}

alias e=emacs
alias bb=brazil-build

alias bba='brazil-build apollo-pkg'
alias bre='brazil-runtime-exec'
alias brc='brazil-recursive-cmd'
alias bws='brazil ws'
alias bwsuse='bws use --gitMode -p'
alias bwscreate='bws create -n'
alias brc=brazil-recursive-cmd
alias bbr='brc brazil-build'
alias bball='brc --allPackages'
alias bbb='brc --allPackages brazil-build'
alias bbra='bbr apollo-pkg'

if [ -f ~/.zshrc-dev-dsk-post ]; then
    source ~/.zshrc-dev-dsk-post
fi

export PATH=$HOME/.toolbox/bin:$PATH

cols=$(tput cols)
# Ensure width is less than 80 and odd
cols=$((cols > 79 ? 79 : (cols % 2 == 0 ? cols - 1 : cols)))

echo -e '\033[0;31m'
cat << 'EOF' | awk -v cols=$cols '{ len=(cols/2)-(length($0)/2); printf("%"len"s%s\n", "", $0) }'
       _ _   _                               
 _ __ (_) |_| |__   ___  _ __ ___  ___  ___  
| '_ \| | __| '_ \ / _ \| '_ ` _ \/ __|/ _ \ 
| | | | | |_| | | | (_) | | | | | \__ \ (_) |
|_| |_|_|\__|_| |_|\___/|_| |_| |_|___/\___/ 
EOF

echo -e '\033[0;32m'
awk -v cols=$cols -v title="TMUX SESSIONS" 'BEGIN{len=((cols-2)/2)-(length(title)/2); bar=sprintf("%"len"s", ""); gsub(/ /,"━",bar); printf("┍%s%s%s┑\n", bar, title, bar)}'
tmux ls | awk -v prefix="│" -v cols=${cols} '{ split($0, a, ":"); acols=cols-1; j=sprintf("%s%s", prefix, a[1]); printf("%-"acols"s%s\n", j, prefix) }'
awk -v cols=$cols 'BEGIN{len=(cols-2); bar=sprintf("%"len"s", ""); gsub(/ /,"━",bar); printf("┕%s┙\n", bar)}'
echo -e '\033[0m'

export DOCKER_HOST=unix:///var/run/docker.sock
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/nithomso/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="theunraveler"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh
unsetopt share_history
setopt no_share_history

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#
export PATH=$PATH:/usr/local/kubebuilder/bin
export PATH=$PATH:/usr/local/go/bin
export PATH=/usr/local/bin:$PATH
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:~/.local/bin
export PATH=$PATH:~/miniconda3/bin
export DOCKER_HOST=unix:///var/run/docker.sock
unset DOCKER_TLS_VERIFY
export GOPROXY=direct
export DOCKER_BUILDKIT=1
export AWS_PAGER="" # Disable paging for AWS CLI v2

export PATH=$HOME/.toolbox/bin:$PATH

alias bb="noglob brazil-build"
alias vim="nvim"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/nithomso/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/nithomso/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/nithomso/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/nithomso/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export NVM_DIR="$HOME/.nvm"                                             
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

debug-controller() {
    if [ $# -ne 1 ]; then
        echo "ERROR: $(basename "$0") only accepts a single parameter" 1>&2
        echo "  $(basename "$0") <service>"
        return 1
    fi

    local service=$(echo "$1" | tr '[:upper:]' '[:lower:]')

    dlv debug github.com/aws-controllers-k8s/$service-controller/cmd/controller/ \
    --api-version=2 --log=true \
    --wd=$GOPATH/src/github.com/aws-controllers-k8s/$service-controller -- \
    --aws-region=us-west-2 --enable-development-logging --log-level=debug
}

debug-code-generator-controller() {
    if [ $# -ne 1 ]; then
        echo "ERROR: $(basename "$0") only accepts a single parameter" 1>&2
        echo "  $(basename "$0") <service>"
        return 1
    fi

    local service=$(echo "$1" | tr '[:upper:]' '[:lower:]')

    dlv debug github.com/aws-controllers-k8s/code-generator/cmd/ack-generate --api-version=2 \
    --build-flags="-tags=codegen" --log=true --wd=$GOPATH/src/github.com/aws-controllers-k8s/code-generator -- \
    controller $service -o $GOPATH/src/github.com/aws-controllers-k8s/$service-controller \
    --template-dirs $GOPATH/src/github.com/aws-controllers-k8s/$service-controller/templates,$GOPATH/src/github.com/aws-controllers-k8s/code-generator/templates \
    --cache-dir $HOME/.cache/aws-controllers-k8s \
    --generator-config-path $GOPATH/src/github.com/aws-controllers-k8s/$service-controller/generator.yaml \
    --service-account-name ack-$service-controller \
    --aws-sdk-go-version v1.42.0
}

debug-code-generator() {
    if [ $# -ne 1 ]; then
        echo "ERROR: $(basename "$0") only accepts a single parameter" 1>&2
        echo "  $(basename "$0") <service>"
        return 1
    fi

    local service=$(echo "$1" | tr '[:upper:]' '[:lower:]')

    dlv debug github.com/aws-controllers-k8s/code-generator/cmd/ack-generate --api-version=2 \
    --build-flags="-tags=codegen" --log=true --wd=$GOPATH/src/github.com/aws-controllers-k8s/code-generator -- \
    apis $service -o $GOPATH/src/github.com/aws-controllers-k8s/$service-controller \
    --template-dirs $GOPATH/src/github.com/aws-controllers-k8s/$service-controller/templates,$GOPATH/src/github.com/aws-controllers-k8s/code-generator/templates \
    --cache-dir $HOME/.cache/aws-controllers-k8s --version v1alpha1 \
    --generator-config-path $GOPATH/src/github.com/aws-controllers-k8s/$service-controller/generator.yaml \
    --aws-sdk-go-version v1.37.4
}

debug-code-generator-release() {
    if [ $# -ne 1 ]; then
        echo "ERROR: $(basename "$0") only accepts a single parameter" 1>&2
        echo "  $(basename "$0") <service>"
        return 1
    fi

    local service=$(echo "$1" | tr '[:upper:]' '[:lower:]')

    dlv debug github.com/aws-controllers-k8s/code-generator/cmd/ack-generate --api-version=2 \
    --build-flags="-tags=codegen" --log=true --wd=$GOPATH/src/github.com/aws-controllers-k8s/code-generator -- \
    release $service v1alpha1 -o $GOPATH/src/github.com/aws-controllers-k8s/$service-controller \
    --template-dirs $GOPATH/src/github.com/aws-controllers-k8s/$service-controller/templates,$GOPATH/src/github.com/aws-controllers-k8s/code-generator/templates \
    --cache-dir $HOME/.cache/aws-controllers-k8s \
    --generator-config-path $GOPATH/src/github.com/aws-controllers-k8s/$service-controller/generator.yaml \
    --metadata-config-path $GOPATH/src/github.com/aws-controllers-k8s/$service-controller/metadata.yaml \
    --aws-sdk-go-version v1.37.10
}

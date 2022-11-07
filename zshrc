# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
#export ZSH="$HOME/.oh-my-zsh"

if [ -f /usr/share/oh-my-zsh/oh-my-zsh.sh  ]; then
    export ZSH="/usr/share/oh-my-zsh/"
fi
if [ -f $HOME/.oh-my-zsh/oh-my-zsh.sh  ]; then
    export ZSH="$HOME/.oh-my-zsh"
fi

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="robbyrussell"
autoload -U promptinit; promptinit
prompt spaceship
# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
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
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
#COMPLETION_WAITING_DOTS="true"

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
ZSH_CUSTOM=/usr/share/zsh

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git aws docker fzf)
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
eval "$(zoxide init zsh)"
source "$ZSH/oh-my-zsh.sh"


if [ -f /.dockerenv ]; then
    # at least this is needed when connecting to docker
    # from windows powershell in windows terminal...
    bindkey  "^[[1~" beginning-of-line
    bindkey  "^[[4~" end-of-line
    bindkey  "^[[3~" delete-char

    # these work in neovim terminal
    bindkey  "^[[H" beginning-of-line
    bindkey  "^[[F" end-of-line

fi

if [ -f $HOME/.local-env.sh  ]; then
    source $HOME/.local-env.sh
fi

# start ssh-agent
#if [[ ! "$SSH_AUTH_SOCK" ]]; then
    #eval $(ssh-agent) > /dev/null
    #[[ -z $(ssh-add -l | grep "Identity added" ) ]] && grep -slR "PRIVATE" ~/.ssh/ | xargs ssh-add > /dev/null
#fi

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=1000
setopt APPEND_HISTORY

export EDITOR="nvr --remote-tab-wait-silent"
alias edit="$EDITOR"
alias tcd='nvr --remote-send "<C-\>:tcd $(pwd)<cr>"'
alias epoch="date +%s"
alias ls='ls --color=auto'
alias cat='bat'
alias ta="tmux attach"
alias p="tmux attach -t primary"
alias s="tmux attach -t secondary"
alias t="~/start-arch-linux-docker.sh"

alias terra="aws-vault exec rva --no-session -- terraform"
alias vault="aws-vault exec rva --"

alias add="git add"
alias checkout='git checkout'
alias commit='git commit'
alias fetch="git fetch"
alias log="git log"
alias pull="git pull"
alias push='git push'
alias stash="git stash"
alias status="git status"
alias gd="git diff"
alias gs="git show"
alias gca='nvr --nostart -s -c wa; git commit -a -m'
alias gcan='nvr --nostart -s -c wa; git commit -a --amend --no-edit'
alias gcan!='nvr --nostart -s -c wa; git commit -a --amend --no-edit && git push --force-with-lease' # gcan!
alias gpf='git push --force-with-lease'

# custom fzf integrated actions
function fn_git_checkout() {
    branch=$(git branch --all | fzf | sed "s/remotes\/origin\///" | xargs)
    git checkout $branch
}
alias gco='fn_git_checkout'

function fn_squash_add_all() {
    commit=$(git log --oneline | fzf | awk '{print $1}')
    git reset --soft $commit && git add -A && git commit
}
alias squash="fn_squash_add_all"

function fn_reset_branch() {
    branch=$(git rev-parse --abbrev-ref --symbolic-full-name @{u})
    git fetch && git reset --hard $branch
}
alias reset-branch="fn_reset_branch"
alias rebase-dev="git fetch && git rebase origin/dev"
alias rebase-develop="git fetch && git rebase origin/develop"
alias rebase-main="git fetch && git rebase origin/main"

function fn_docker_stop() {
    id=$(docker container ls | fzf | awk '{print $1;}')
    docker stop $id
}
alias stop="fn_docker_stop"

function fn_aws_tail() {
    USE_LAST="FALSE"
    if [[ $1 == "-" ]]; then
        USE_LAST="TRUE"
        shift
    fi
    if [[ $USE_LAST == "FALSE" || -z $LAST_AWS_LOG_GROUP ]]; then
        export LAST_AWS_LOG_GROUP=$(aws logs describe-log-groups | jq -r ".logGroups[].logGroupName" | fzf)
    fi
    echo "Tailing: $LAST_AWS_LOG_GROUP..."
    aws logs tail $LAST_AWS_LOG_GROUP --format short --follow "$@"
}
alias awstail="fn_aws_tail"

command -v z >/dev/null 2>&1 && alias cd="z"

SPACESHIP_CHAR_SYMBOL='❯ '
SPACESHIP_CHAR_SYMBOL_ROOT='# '

export ASPNETCORE_ENVIRONMENT=dev
export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false
export AWS_VAULT_BACKEND=pass
export NODE_OPTIONS="--max-old-space-size=4096"
export NNN_COLORS='#271cb8ae'
export GPG_TTY=$(tty)

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
ulimit -c 0

# nnn file borwser wrapper to cd on quit
n ()
{
    # Block nesting of nnn in subshells
    if [ -n $NNNLVL ] && [ "${NNNLVL:-0}" -ge 1 ]; then
        echo "nnn is already running"
        return
    fi

    # The default behaviour is to cd on quit (nnn checks if NNN_TMPFILE is set)
    # To cd on quit only on ^G, remove the "export" as in:
    #     NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
    # NOTE: NNN_TMPFILE is fixed, should not be modified
    export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

    # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
    # stty start undef
    # stty stop undef
    # stty lwrap undef
    # stty lnext undef

    nnn -e "$@"

    if [ -f "$NNN_TMPFILE" ]; then
            . "$NNN_TMPFILE"
            rm -f "$NNN_TMPFILE" > /dev/null
    fi
}

function work-on-issue() {
    issue=$(gh issue list | fzf --header "PLEASE SELECT AN ISSUE TO WORK ON" | awk -F '\t' '{ print $1 }')
    sanitized=$(gh issue view $issue --json "title" | jq -r ".title" | tr '[:upper:]' '[:lower:]' | tr -s -c "a-z0-9\n" "-" | head -c 60)
    branchname=$issue-$sanitized
    shortname=$(echo $branchname | head -c 30)
    if [[ ! -z "$shortname" ]]; then
        git fetch
        existing=$(git branch -a | grep -v remotes | grep $shortname | head -n 1)
        if [[ ! -z "$existing" ]]; then
            sh -c "git switch $existing"
        else
            bold=$(tput bold)
            normal=$(tput sgr0)
            echo "${bold}Please confirm new branch name:${normal}"
            vared branchname
            base=$(git branch --show-current)
            echo "${bold}Please confirm the base branch:${normal}"
            vared base
            git checkout -b $branchname origin/$base
            git push --set-upstream origin $branchname
        fi
    fi
}
#if [[ -n $SSH_CONNECTION ]] ; then
#    [ -z "$TMUX"  ] && { tmux attach || exec tmux new-session }
#fi
#
#export GIT_DIR="$HOME/bare.git"
#export GIT_WORK_TREE="$HOME"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/bin/terraform terraform

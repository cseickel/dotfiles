# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
#export ZSH="$HOME/.oh-my-zsh"

if [ -f /usr/share/oh-my-zsh/oh-my-zsh.sh  ]; then
    export ZSH="/usr/share/oh-my-zsh/"
fi
if [ -f $HOME/.oh-my-zsh/oh-my-zsh.sh  ]; then
    export ZSH="$HOME/.oh-my-zsh"
fi
source "$ZSH/oh-my-zsh.sh"

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
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git aws docker fzf)

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
if [[ ! "$SSH_AUTH_SOCK" ]]; then
    eval $(ssh-agent)
    ssh-add ~/.ssh/*id_rsa
fi

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
setopt INC_APPEND_HISTORY_TIME

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Prevent nested vim when using neovim terminal
nvim_wrapper() {
    if command -v nvr &> /dev/null; then
        if test -z $NVIM_LISTEN_ADDRESS; then
            nvim $argv
        else
            if test -z $argv; then
                nvr -cc "topleft split | Startify"
            else
                nvr -cc "topleft split" --remote $argv
            fi
        fi
    else
        nvim $argv
    fi
}
alias nvim="nvim_wrapper"
alias vim="nvim_wrapper"
alias tcd='nvr --remote-send "<C-\>:tcd $(pwd)<cr>"'
alias epoch="date +%s"
alias ls='ls --color=auto'
alias cat='bat'

alias add="git add"
alias checkout='git checkout'
alias commit='git commit'
alias fetch="git fetch"
alias log="git log"
alias pull="git pull"
alias push='git push'
alias status="git status"
alias gca='git commit -a -m'
alias gcan='git commit -a --amend --no-edit'
alias gcan!='git commit -a --amend --no-edit && git push --force-with-lease'
alias gpf='git push --force-with-lease'
alias gco='git checkout $(git branch --all | fzf | sed "s/remotes\/origin\///")'
alias reset-branch="git fetch && git reset --hard $(git rev-parse --abbrev-ref --symbolic-full-name @{u})"


SPACESHIP_CHAR_SYMBOL='❯ '
SPACESHIP_CHAR_SYMBOL_ROOT='# '

export AWS_VAULT_BACKEND=pass
export NODE_OPTIONS="--max-old-space-size=2048"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
ulimit -c 0

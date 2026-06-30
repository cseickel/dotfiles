# Interactive zsh configuration
# Source non-interactive env first (if not already sourced)
[ -z "$ZSHENV_SOURCED" ] && [ -f "$HOME/.zshenv" ] && . "$HOME/.zshenv"

# Go (interactive only - go env can be slow)
export GOPATH=$(go env GOPATH 2>/dev/null || echo "$HOME/go")
export PATH="$GOPATH/bin:$PATH"

# Path to oh-my-zsh installation
if [ -f /usr/share/oh-my-zsh/oh-my-zsh.sh ]; then
    export ZSH="/usr/share/oh-my-zsh/"
fi
if [ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    export ZSH="$HOME/.oh-my-zsh"
fi

# Prompt
eval "$(starship init zsh)"
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"

ZSH_CUSTOM=/usr/share/zsh
plugins=(git aws docker fzf)
source "$ZSH/oh-my-zsh.sh"

# Machine-specific env (if exists)
if [ -f "$HOME/.local-env.sh" ]; then
    source "$HOME/.local-env.sh"
fi

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=1000
setopt APPEND_HISTORY

# Aliases
alias epoch="date +%s"
alias ls='ls --color=auto'
alias cat='bat'
alias emod='nvim "$(find ./ -type f -printf '\''%T@ %p\n'\'' | sort -n | tail -1 | cut -d'\'' '\'' -f2-)"'
alias enew='nvim "$(find . -type f -exec stat --format='\''%W %n'\'' {} + | sort -nr | awk '\''NR==1{print $2}'\'')"'

alias cdk="aws-vault exec rva --no-session -- npm run cdk"
alias vault="aws-vault exec rva --"
alias vault-no-session="aws-vault exec rva --no-session --"

alias add="git add"
alias checkout='git checkout'
alias commit='git commit'
alias fetch="git fetch"
alias log="git log"
alias pull="git pull"
alias push='git push'
alias status="git status"
alias gd="git diff"
alias gs="git show"
alias gca='git commit -a -m'
alias gcan='git commit -a --amend --no-edit'
alias gcan!='git commit -a --amend --no-edit && git push --force-with-lease'
alias gpf='git push --force-with-lease'

function git_last() {
  git reflog show --pretty=format:'%gs ~ %gd' --date=relative | grep 'checkout:' | grep -oE '[^ ]+ ~ .*' | awk -F~ '!seen[$1]++' | head -n 10 | awk -F' ~ HEAD@{' '{printf("  \033[33m%14s: \033[37m %s\033[0m\n", substr($2, 1, length($2)-1), $1)}'
}

function fn_cherry_pick() {
  commit=$(git log --pretty=format:"%h %s" --branches='*' -n 100 \
    | fzf --height "90%" --header "PLEASE CHOOSE A COMMIT TO CHERRY-PICK" --reverse --border --ansi --preview "git show --color=always {1}" \
    | awk '{print $1}')
  if [ -n "$commit" ]; then
    git cherry-pick $commit
  fi
}
alias cherry=fn_cherry_pick

function fn_git_checkout() {
    branch=$(git branch --all \
      | fzf --height "90%" --header "PLEASE CHOOSE A BRANCH TO CHECKOUT" \
      | sed "s/remotes\/origin\///" | xargs)
    if [ -n "$branch" ]; then
      git checkout $branch
    fi
}
alias gco='fn_git_checkout'

function fn_checkout_gh_pr() {
 pr_number=$(gh pr ls | fzf | awk '{print $1}')
 if [ -n "$pr_number" ]; then
   gh pr checkout $pr_number
 fi
}
alias gpr='fn_checkout_gh_pr'

function fn_git_checkout_recent() {
  selection=$(git reflog show --pretty=format:'%gs ~ %gd' --date=relative \
    | grep 'checkout:' \
    | grep -oE '[^ ]+ ~ .*' \
    | awk -F~ '!seen[$1]++' \
    | head -n 20 \
    | awk -F' ~ HEAD@{' '{printf("  \033[33m%14s: \033[37m %s\033[0m\n", substr($2, 1, length($2)-1), $1)}' \
    | fzf --height "90%" --ansi --border --border-label "RECENTLY USED BRANCHES" )
  if [ -n "$selection" ]; then
    branch=$(echo $selection | cut -c 20-)
    git checkout $branch
  fi
}
alias gcr='fn_git_checkout_recent'

function fn_reset_soft() {
    commit=$(git log --oneline | fzf | awk '{print $1}')
    if [ -n "$commit" ]; then
        git reset --soft $commit
    else
      echo "Soft reset cancelled because no commit was selected."
    fi
}
alias reset-soft="fn_reset_soft"

function fn_squash_add_all() {
  commit=$(git log --oneline | fzf | awk '{print $1}')
  if [ -n "$commit" ]; then
    git reset --soft $commit && git add -A && git commit
  else
    echo "Squash cancelled because no commit was selected."
  fi
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

SPACESHIP_CHAR_SYMBOL='❯ '
SPACESHIP_CHAR_SYMBOL_ROOT='# '

export NNN_COLORS='#271cb8ae'
export GPG_TTY=$(tty)

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
ulimit -c 0

# nnn file browser wrapper to cd on quit
n ()
{
    if [ -n $NNNLVL ] && [ "${NNNLVL:-0}" -ge 1 ]; then
        echo "nnn is already running"
        return
    fi
    export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
    nnn -e "$@"
    if [ -f "$NNN_TMPFILE" ]; then
            . "$NNN_TMPFILE"
            rm -f "$NNN_TMPFILE" > /dev/null
    fi
}

function work-on-issue() {
    issue=$(gh issue list --limit 200 | fzf --header "PLEASE SELECT AN ISSUE TO WORK ON" | awk -F '\t' '{ print $1 }')
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
            base=$(gh repo view --json defaultBranchRef --jq ".defaultBranchRef.name")
            echo "${bold}Please confirm the base branch:${normal}"
            vared base
            if [[ -z "$base" ]]; then
              base=$(gh repo view --json defaultBranchRef --jq ".defaultBranchRef.name")
            fi
            git checkout -b $branchname origin/$base
            git push --set-upstream origin $branchname
        fi
    fi
}

autoload -U +X bashcompinit && bashcompinit

# NVM (interactive only - expensive startup)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Editor (interactive only)
if [[ ! -e ~/.local/bin/edit.sh ]]; then
  mkdir -p ~/.local/bin
  echo '#!/bin/bash
  if [[ -z "${TMUX}" ]]; then
    kitty nvim "$@"
  else
    tmux popup -w "160" -h "80%" -E nvim "$@"
  fi' > ~/.local/bin/edit.sh
  chmod +x ~/.local/bin/edit.sh
fi
export EDITOR=~/.local/bin/edit.sh

# opencode
export PATH=/home/user/.opencode/bin:$PATH
unset zle_bracketed_paste

# Claude Code shell functions
source "/home/chris/claude-instructions/scripts/shell-init.sh"

nv() {
  # Inside an nvim :terminal, defer to nvim-unception (open in the host).
  if [[ -n "$NVIM" || -n "$NVIM_UNCEPTION_PIPE_PATH_HOST" ]]; then
    command nvim "$@"
    return
  fi

  # Deterministic per-directory socket (hash of the physical cwd).
  local key sock
  key=$(pwd -P | command md5sum | cut -c1-16)
  sock="${XDG_RUNTIME_DIR:-/tmp}/nvim-${key}.sock"

  # No live server here? Spawn a headless one that auto-closes when idle.
  if [[ ! -S "$sock" ]] || ! command nvim --server "$sock" --remote-expr '1' &>/dev/null; then
    [[ -e "$sock" ]] && rm -f "$sock"               # clear a stale/dead socket file
    NVIM_AUTOCLOSE=300000 command nvim --headless --listen "$sock" &!  # 5-min idle close
    # Wait (up to ~2.5s) for the socket to come up before attaching.
    local i=0
    while [[ ! -S "$sock" ]] && (( i < 50 )); do sleep 0.05; ((i++)); done
    if [[ ! -S "$sock" ]]; then
      echo "nv: server failed to start at $sock" >&2
      return 1
    fi
  fi

  # Open any files passed, in the running server, then attach this terminal's UI.
  (( $# )) && command nvim --server "$sock" --remote "$@"
  command nvim --server "$sock" --remote-ui
}

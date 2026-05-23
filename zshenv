# ~/dotfiles/zshenv
# Runs for ALL zsh invocations (login, interactive, scripts, cron)
# Keep minimal - no expensive operations, no tty-dependent code

# PATH
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$HOME/AppImages:$HOME/.claude/local:$PATH"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Core environment
export PAGER="less -F"
export NODE_OPTIONS="--max-old-space-size=4096"
export AWS_VAULT_BACKEND=pass

# Machine-specific (if exists)
[ -f "$HOME/.local-env.sh" ] && . "$HOME/.local-env.sh"

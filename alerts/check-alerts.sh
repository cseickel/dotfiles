#!/bin/bash
# Cron job to check for pending alerts and launch interactive agent
# Schedule: 45 8,11,14,16 * * 1-5 /home/chris/dotfiles/alerts/check-alerts.sh

ALERTS_DIR="$HOME/.local/alerts"
COUNT_FILE="$ALERTS_DIR/pending-count"
CRITICAL_MD="$HOME/dotfiles/alerts/critical-alert.md"

vars=(
  # Memory DB (needed by mcp-servers)
  MEMORY_HOST
  MEMORY_PORT
  MEMORY_DATABASE
  MEMORY_USER
  MEMORY_PASSWORD
)

# Read pending count
count=0
if [[ -f "$COUNT_FILE" ]]; then
    count=$(cat "$COUNT_FILE" | tr -d '[:space:]')
    [[ -z "$count" ]] && count=0
fi

if [[ "$count" -gt 0 ]]; then
    echo "$(date): $count alerts pending, launching agent"

    set -a
    source <(/usr/bin/doppler secrets download --no-file --format env | grep -E "^($(IFS='|'; echo "${vars[*]}"))=")
    set +a

    # PG* for psql -> memory DB
    export PGHOST="$MEMORY_HOST"
    export PGPORT="$MEMORY_PORT"
    export PGDATABASE="$MEMORY_DATABASE"
    export PGUSER="$MEMORY_USER"
    export PGPASSWORD="$MEMORY_PASSWORD"

    # Clean env to avoid nix library conflicts with system ghostty
    unset NIX_CC NIX_PROFILES NIX_PATH
    unset LD_LIBRARY_PATH

    # Claude env vars (disable features not needed for alert review)
    export CLAUDE_CODE_DISABLE_CLAUDE_MDS=1
    export CLAUDE_CODE_DISABLE_CRON=1
    export CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS=1
    export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
    export CLAUDE_CODE_ENABLE_PROMPT_SUGGESTIONS=false
    export CLAUDE_CODE_ENABLE_TASKS=0
    export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=0
    export CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS=100000
    export CLAUDE_CODE_SYNC_PLUGIN_INSTALL=0
    export CLAUDE_CODE_SYNC_PLUGIN_INSTALL_TIMEOUT_MS=100
    export DISABLE_AUTOUPDATER=1
    export DISABLE_COMPACT=1
    export DISABLE_NON_ESSENTIAL_MODEL_CALLS=1
    export DISABLE_TELEMETRY=1
    export ENABLE_CLAUDEAI_MCP_SERVERS=false
    export ENABLE_LSP_TOOL=0
    export ENABLE_TOOL_SEARCH=false
    export MAX_MCP_OUTPUT_TOKENS=100000

    # Launch interactive agent in ghostty
    /usr/bin/ghostty -e \
        "$HOME/.local/bin/ccode" --append-system-prompt-file "$CRITICAL_MD" \
        "Review the $count alerts that need attention."
fi

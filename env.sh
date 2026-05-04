#!/bin/bash
# Claude Code environment for claude-instructions project
# Fetches only the secrets needed, maps PG* to memory DB for psql

vars=(
  # Memory DB (needed by mcp-servers)
  MEMORY_HOST
  MEMORY_PORT
  MEMORY_DATABASE
  MEMORY_USER
  MEMORY_PASSWORD
)
set -a
source <(doppler secrets download --no-file --format env | grep -E "^($(IFS='|'; echo "${vars[*]}"))=")
set +a

# PG* for psql -> memory DB
export PGHOST="$MEMORY_HOST"
export PGPORT="$MEMORY_PORT"
export PGDATABASE="$MEMORY_DATABASE"
export PGUSER="$MEMORY_USER"
export PGPASSWORD="$MEMORY_PASSWORD"

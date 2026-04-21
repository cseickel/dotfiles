#!/bin/bash
set -e
cd ~/.local/alerts

# IMAP credentials
. ./env

# PG credentials via doppler
vars=(MEMORY_HOST MEMORY_PORT MEMORY_DATABASE MEMORY_USER MEMORY_PASSWORD)
set -a
source <(doppler secrets download -p rva-capital -c local --no-file --format env | grep -E "^($(IFS='|'; echo "${vars[*]}"))=")
set +a
export PGHOST="$MEMORY_HOST"
export PGPORT="$MEMORY_PORT"
export PGDATABASE="$MEMORY_DATABASE"
export PGUSER="$MEMORY_USER"
export PGPASSWORD="$MEMORY_PASSWORD"

./alert-monitor

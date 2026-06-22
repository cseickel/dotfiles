# Alert Monitor Setup

## Prerequisites

1. Gmail account for alerts (e.g., alerts.claude.rva@gmail.com)
2. App password for IMAP access (not your regular password)
3. Go toolchain (to build the `alert-monitor` binary)
4. `doppler` CLI (PostgreSQL credentials are pulled from it at runtime)

## Configuration

Create `~/.local/alerts/env` with the IMAP credentials (sourced by `run.sh`):
```bash
# ~/.local/alerts/env
ALERT_IMAP_SERVER="imap.gmail.com"
ALERT_IMAP_USER="alerts.claude.rva@gmail.com"
ALERT_IMAP_PASSWORD="your-app-password"
```

PostgreSQL credentials are not stored here; `run.sh` and `check-alerts.sh` pull
them from `doppler` at runtime and export the `PG*` variables.

## Build

```bash
cd ~/dotfiles/alerts
go build   # produces the ./alert-monitor binary
```

## Cron Setup

Two scheduled jobs:

1. **Poller** (`run.sh`): fetches new mail, triages it, and launches the
   interactive agent if any `critical`/`unknown` alerts appear. `run.sh` sources
   `env` and `doppler` itself, so cron just calls it. Standard cron has a 1-minute
   floor; for ~30-second polling, add two entries:

   ```cron
   * * * * * ~/.local/alerts/run.sh >> ~/.local/alerts/logs/cron.log 2>&1
   * * * * * sleep 30 && ~/.local/alerts/run.sh >> ~/.local/alerts/logs/cron.log 2>&1
   ```

2. **Scheduled review** (`check-alerts.sh`): at set times, launches the interactive
   agent when `pending-count` (batched `alert` items) is non-zero:

   ```cron
   45 8,11,14,16 * * 1-5 ~/dotfiles/alerts/check-alerts.sh
   ```

Edit crontab with: `crontab -e`

## Testing

```bash
cd ~/dotfiles/alerts
go build
~/.local/alerts/run.sh   # one fetch + triage cycle
```

## Files

- `alert-monitor.go` - Main program source (compiles to the `alert-monitor` binary)
- `run.sh` - Poller entry point: loads credentials, runs `./alert-monitor`
- `check-alerts.sh` - Scheduled launcher for the interactive review agent
- `triage.md` - Non-interactive triage agent instructions
- `critical-alert.md` - Interactive alert agent instructions
- `rules.md` - Auto-generated from the `triage_rules` table
- `env.template` - Template for the `env` IMAP credentials file
- `emails/` - Downloaded email folders
- `logs/` - Triage logs and cron output

## Database Tables

- `alert_emails` - Email log with status (NULL/critical/alert/dismissed/unknown/ignore)
- `triage_rules` - Classification rules

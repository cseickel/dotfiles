# Alert Monitor Setup

## Prerequisites

1. Gmail account for alerts (e.g., alerts.claude.rva@gmail.com)
2. App password for IMAP access (not your regular password)

## Configuration

Set environment variables:
```bash
export ALERT_IMAP_SERVER="imap.gmail.com"
export ALERT_IMAP_USER="alerts.claude.rva@gmail.com"
export ALERT_IMAP_PASSWORD="your-app-password"
```

Add to `~/.bashrc` or create `~/.local/alerts/env`:
```bash
# ~/.local/alerts/env
ALERT_IMAP_SERVER="imap.gmail.com"
ALERT_IMAP_USER="alerts.claude.rva@gmail.com"
ALERT_IMAP_PASSWORD="your-app-password"
```

## Cron Setup

Standard cron has 1-minute minimum resolution. For 30-second polling, add two entries:

```cron
* * * * * . ~/.local/alerts/env && python3 ~/.local/alerts/alert-monitor.py >> ~/.local/alerts/logs/cron.log 2>&1
* * * * * sleep 30 && . ~/.local/alerts/env && python3 ~/.local/alerts/alert-monitor.py >> ~/.local/alerts/logs/cron.log 2>&1
```

Edit crontab with: `crontab -e`

## Testing

Run manually:
```bash
source ~/.local/alerts/env
python3 ~/.local/alerts/alert-monitor.py
```

## Files

- `alert-monitor.py` - Main script
- `triage.md` - Non-interactive triage agent instructions
- `critical-alert.md` - Interactive alert agent instructions
- `rules.md` - Auto-generated from database rules
- `emails/` - Downloaded email folders
- `logs/` - Triage logs and cron output

## Database Tables

- `alert_emails` - Email log with status (NULL/Y/N/A/D/U)
- `triage_rules` - Classification rules

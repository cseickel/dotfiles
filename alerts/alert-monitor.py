#!/usr/bin/env python3
"""
Alert Monitor: Fetch emails, triage with Claude, notify/escalate as needed.

Run via cron every 30 seconds.
"""

import imaplib
import email
from email.header import decode_header
import os
import sys
import json
import subprocess
from datetime import datetime
from pathlib import Path
import psycopg2

# Configuration
ALERTS_DIR = Path.home() / ".local" / "alerts"
EMAILS_DIR = ALERTS_DIR / "emails"
LOGS_DIR = ALERTS_DIR / "logs"
RULES_FILE = ALERTS_DIR / "rules.md"
TRIAGE_MD = ALERTS_DIR / "triage.md"
CRITICAL_MD = ALERTS_DIR / "critical-alert.md"

# IMAP settings (configure these)
IMAP_SERVER = os.environ.get("ALERT_IMAP_SERVER", "imap.gmail.com")
IMAP_USER = os.environ.get("ALERT_IMAP_USER", "")
IMAP_PASSWORD = os.environ.get("ALERT_IMAP_PASSWORD", "")

# Database
DB_NAME = "memory"


def get_db_connection():
    return psycopg2.connect(dbname=DB_NAME)


def ensure_tables_exist():
    """Create database tables if they don't exist."""
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS alert_emails (
            id SERIAL PRIMARY KEY,
            status CHAR(1) CHECK(status IS NULL OR status IN ('Y','N','A','D','U')),
            from_addr TEXT NOT NULL,
            subject TEXT NOT NULL,
            folder TEXT NOT NULL,
            received_at TIMESTAMPTZ DEFAULT NOW()
        );
        CREATE INDEX IF NOT EXISTS idx_alert_emails_status ON alert_emails(status);

        CREATE TABLE IF NOT EXISTS triage_rules (
            id SERIAL PRIMARY KEY,
            from_pattern TEXT,
            subject_pattern TEXT,
            instructions TEXT NOT NULL,
            created_at TIMESTAMPTZ DEFAULT NOW(),
            updated_at TIMESTAMPTZ DEFAULT NOW()
        );
        CREATE INDEX IF NOT EXISTS idx_triage_rules_updated_at ON triage_rules(updated_at);
    """)
    conn.commit()
    cur.close()
    conn.close()


def decode_mime_header(header):
    """Decode a MIME-encoded header to string."""
    if header is None:
        return ""
    decoded_parts = decode_header(header)
    result = []
    for part, encoding in decoded_parts:
        if isinstance(part, bytes):
            result.append(part.decode(encoding or "utf-8", errors="replace"))
        else:
            result.append(part)
    return "".join(result)


def fetch_emails():
    """Fetch new emails from IMAP, save to folders, insert to DB, delete from server."""
    if not IMAP_USER or not IMAP_PASSWORD:
        print("IMAP credentials not configured. Set ALERT_IMAP_USER and ALERT_IMAP_PASSWORD.")
        return []

    new_emails = []

    mail = imaplib.IMAP4_SSL(IMAP_SERVER)
    mail.login(IMAP_USER, IMAP_PASSWORD)
    mail.select("INBOX")

    # Search for all unseen messages
    _, message_numbers = mail.search(None, "UNSEEN")

    conn = get_db_connection()
    cur = conn.cursor()

    for num in message_numbers[0].split():
        # Fetch without marking as seen yet
        _, msg_data = mail.fetch(num, "(RFC822)")

        for response_part in msg_data:
            if isinstance(response_part, tuple):
                msg = email.message_from_bytes(response_part[1])

                from_addr = decode_mime_header(msg.get("From", ""))
                subject = decode_mime_header(msg.get("Subject", ""))
                date_str = msg.get("Date", "")

                # Create folder with timestamp
                timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
                # Find next available sequence number
                seq = 0
                while True:
                    folder_name = f"{timestamp}-{seq:02d}"
                    folder_path = EMAILS_DIR / folder_name
                    if not folder_path.exists():
                        break
                    seq += 1

                folder_path.mkdir(parents=True)

                # Extract body and attachments
                if msg.is_multipart():
                    for part in msg.walk():
                        content_type = part.get_content_type()
                        content_disposition = str(part.get("Content-Disposition", ""))

                        if "attachment" in content_disposition:
                            filename = part.get_filename()
                            if filename:
                                filename = decode_mime_header(filename)
                                filepath = folder_path / filename
                                with open(filepath, "wb") as f:
                                    f.write(part.get_payload(decode=True) or b"")
                        elif content_type == "text/plain":
                            body = part.get_payload(decode=True)
                            if body:
                                with open(folder_path / "body.txt", "wb") as f:
                                    f.write(body)
                        elif content_type == "text/html":
                            body = part.get_payload(decode=True)
                            if body:
                                with open(folder_path / "body.html", "wb") as f:
                                    f.write(body)
                else:
                    body = msg.get_payload(decode=True)
                    if body:
                        content_type = msg.get_content_type()
                        if content_type == "text/html":
                            with open(folder_path / "body.html", "wb") as f:
                                f.write(body)
                        else:
                            with open(folder_path / "body.txt", "wb") as f:
                                f.write(body)

                # Insert to database with NULL status
                cur.execute(
                    """INSERT INTO alert_emails (from_addr, subject, folder)
                       VALUES (%s, %s, %s) RETURNING id""",
                    (from_addr, subject, str(folder_path))
                )
                email_id = cur.fetchone()[0]
                conn.commit()

                new_emails.append({
                    "id": email_id,
                    "from": from_addr,
                    "subject": subject,
                    "folder": str(folder_path)
                })

                # Delete from server after successful save
                mail.store(num, "+FLAGS", "\\Deleted")

    mail.expunge()
    mail.logout()
    cur.close()
    conn.close()

    return new_emails


def dump_rules_if_needed():
    """Dump rules from DB to file if any have been updated."""
    conn = get_db_connection()
    cur = conn.cursor()

    # Get latest rule update time
    cur.execute("SELECT MAX(updated_at) FROM triage_rules")
    latest_update = cur.fetchone()[0]

    # Check if dump file exists and is newer
    if RULES_FILE.exists() and latest_update:
        file_mtime = datetime.fromtimestamp(RULES_FILE.stat().st_mtime)
        if file_mtime.replace(tzinfo=None) >= latest_update.replace(tzinfo=None):
            cur.close()
            conn.close()
            return  # No update needed

    # Dump rules to markdown
    cur.execute("SELECT from_pattern, subject_pattern, instructions FROM triage_rules ORDER BY id")
    rules = cur.fetchall()

    with open(RULES_FILE, "w") as f:
        f.write("# Triage Rules\n\n")
        if not rules:
            f.write("No rules defined yet.\n")
        else:
            for from_pat, subj_pat, instructions in rules:
                f.write(f"## Rule\n")
                if from_pat:
                    f.write(f"- From pattern: `{from_pat}`\n")
                if subj_pat:
                    f.write(f"- Subject pattern: `{subj_pat}`\n")
                f.write(f"- Instructions: {instructions}\n\n")

    cur.close()
    conn.close()


def get_null_emails():
    """Get emails with NULL status (need triage)."""
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        """SELECT id, from_addr, subject, folder
           FROM alert_emails
           WHERE status IS NULL"""
    )
    emails = [
        {"id": row[0], "from": row[1], "subject": row[2], "folder": row[3]}
        for row in cur.fetchall()
    ]
    cur.close()
    conn.close()
    return emails


def run_triage_agent(emails):
    """Run the triage agent and return JSON decisions."""
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    log_file = LOGS_DIR / f"{timestamp}-triage.log"

    # Build prompt with email metadata
    prompt = "Classify these emails:\n\n"
    for e in emails:
        prompt += f"- ID: {e['id']}, From: {e['from']}, Subject: {e['subject']}, Folder: {e['folder']}\n"

    # Invoke triage agent with minimal config (matches spag_env from claude-companion.lua)
    env = os.environ.copy()
    env.update({
        "CLAUDE_CODE_DISABLE_CLAUDE_MDS": "1",
        "CLAUDE_CODE_DISABLE_CRON": "1",
        "CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS": "1",
        "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
        "CLAUDE_CODE_DISABLE_THINKING": "1",
        "CLAUDE_CODE_ENABLE_PROMPT_SUGGESTIONS": "false",
        "CLAUDE_CODE_ENABLE_TASKS": "0",
        "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1",
        "CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS": "100000",
        "CLAUDE_CODE_SYNC_PLUGIN_INSTALL": "0",
        "CLAUDE_CODE_SYNC_PLUGIN_INSTALL_TIMEOUT_MS": "100",
        "DISABLE_AUTOUPDATER": "1",
        "DISABLE_COMPACT": "1",
        "DISABLE_NON_ESSENTIAL_MODEL_CALLS": "1",
        "DISABLE_TELEMETRY": "1",
        "ENABLE_CLAUDEAI_MCP_SERVERS": "false",
        "ENABLE_LSP_TOOL": "0",
        "ENABLE_TOOL_SEARCH": "false",
        "MAX_MCP_OUTPUT_TOKENS": "100000",
    })

    result = subprocess.run(
        [
            "claude", "-p", prompt,
            "--model", "claude-sonnet-4-5",
            "--system-prompt-file", str(TRIAGE_MD),
            "--setting-sources", "",
            "--strict-mcp-config",
            "--tools", "Read",
            "--no-session-persistence",
        ],
        env=env,
        capture_output=True,
        text=True,
        timeout=120
    )

    # Log output
    with open(log_file, "w") as f:
        f.write(f"Prompt:\n{prompt}\n\n")
        f.write(f"Exit code: {result.returncode}\n\n")
        f.write(f"Stdout:\n{result.stdout}\n\n")
        f.write(f"Stderr:\n{result.stderr}\n")

    if result.returncode != 0:
        print(f"Triage agent failed. See {log_file}")
        return []

    # Parse JSON from output
    try:
        # Find JSON array in output
        output = result.stdout.strip()
        start = output.find("[")
        end = output.rfind("]") + 1
        if start >= 0 and end > start:
            return json.loads(output[start:end])
    except json.JSONDecodeError as e:
        print(f"Failed to parse triage output: {e}")
        with open(log_file, "a") as f:
            f.write(f"\nJSON parse error: {e}\n")

    return []


def apply_decisions(decisions):
    """Apply triage decisions: update DB, notify, launch IA if needed."""
    conn = get_db_connection()
    cur = conn.cursor()

    has_critical = False
    has_unknown = False

    for d in decisions:
        email_id = d.get("id")
        status = d.get("status")
        reason = d.get("reason", "")

        if not email_id or not status:
            continue

        # Update status in DB
        cur.execute(
            "UPDATE alert_emails SET status = %s WHERE id = %s",
            (status, email_id)
        )

        if status == "A":
            # Get email details for notification
            cur.execute(
                "SELECT from_addr, subject FROM alert_emails WHERE id = %s",
                (email_id,)
            )
            row = cur.fetchone()
            if row:
                from_addr, subject = row
                # Send desktop notification
                subprocess.run([
                    "notify-send",
                    "-u", "normal",
                    f"Alert: {subject[:50]}",
                    f"From: {from_addr}\n{reason}"
                ])
        elif status == "N":
            has_critical = True
        elif status == "U":
            has_unknown = True

    conn.commit()
    cur.close()
    conn.close()

    # Launch interactive agent if needed
    if has_critical or has_unknown:
        launch_interactive_agent()


def launch_interactive_agent():
    """Launch the interactive critical alert agent in a new terminal."""
    # Clean env to avoid nix library conflicts with system ghostty
    clean_env = {k: v for k, v in os.environ.items()
                 if not k.startswith('NIX_') and k != 'LD_LIBRARY_PATH'}
    # Start interactive TUI with initial prompt (no -p flag keeps it interactive)
    subprocess.Popen([
        "ghostty", "-e",
        "claude", "--append-system-prompt-file", str(CRITICAL_MD),
        "Review the alerts that need attention."
    ], env=clean_env)


def main():
    # Ensure directories and tables exist
    EMAILS_DIR.mkdir(parents=True, exist_ok=True)
    LOGS_DIR.mkdir(parents=True, exist_ok=True)
    ensure_tables_exist()

    # Fetch new emails
    new_emails = fetch_emails()
    print(f"Fetched {len(new_emails)} new emails")

    # Dump rules if needed
    dump_rules_if_needed()

    # Get emails needing triage (NULL status)
    null_emails = get_null_emails()

    if not null_emails:
        print("No emails to triage")
        return

    print(f"Triaging {len(null_emails)} emails")

    # Run triage agent
    decisions = run_triage_agent(null_emails)

    if not decisions:
        print("No decisions from triage agent")
        return

    print(f"Got {len(decisions)} decisions")

    # Apply decisions
    apply_decisions(decisions)

    print("Done")


if __name__ == "__main__":
    main()

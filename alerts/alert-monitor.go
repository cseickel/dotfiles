package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"mime"
	"mime/multipart"
	"net/mail"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"

	"github.com/emersion/go-imap/v2"
	"github.com/emersion/go-imap/v2/imapclient"
	_ "github.com/jackc/pgx/v5/stdlib"
)

var (
	alertsDir  = filepath.Join(os.Getenv("HOME"), ".local", "alerts")
	emailsDir  = filepath.Join(alertsDir, "emails")
	logsDir    = filepath.Join(alertsDir, "logs")
	rulesFile  = filepath.Join(alertsDir, "rules.md")
	triageMD   = filepath.Join(alertsDir, "triage.md")
	criticalMD = filepath.Join(alertsDir, "critical-alert.md")
)

type Email struct {
	ID      int64
	From    string
	Subject string
	Folder  string
}

type Decision struct {
	ID     int64  `json:"id"`
	Status string `json:"status"`
	Reason string `json:"reason"`
}

func main() {
	if err := run(); err != nil {
		log.Fatal(err)
	}
}

func run() error {
	// Ensure directories exist
	os.MkdirAll(emailsDir, 0755)
	os.MkdirAll(logsDir, 0755)

	db, err := sql.Open("pgx", "")
	if err != nil {
		return fmt.Errorf("db connect: %w", err)
	}
	defer db.Close()

	if err := ensureTables(db); err != nil {
		return fmt.Errorf("ensure tables: %w", err)
	}

	// Fetch new emails
	newEmails, err := fetchEmails(db)
	if err != nil {
		return fmt.Errorf("fetch emails: %w", err)
	}
	fmt.Printf("Fetched %d new emails\n", len(newEmails))

	// Dump rules if needed
	if err := dumpRulesIfNeeded(db); err != nil {
		return fmt.Errorf("dump rules: %w", err)
	}

	// Get emails needing triage
	nullEmails, err := getNullEmails(db)
	if err != nil {
		return fmt.Errorf("get null emails: %w", err)
	}

	if len(nullEmails) == 0 {
		fmt.Println("No emails to triage")
		return nil
	}

	fmt.Printf("Triaging %d emails\n", len(nullEmails))

	// Run triage agent
	decisions, err := runTriageAgent(nullEmails)
	if err != nil {
		return fmt.Errorf("triage: %w", err)
	}

	if len(decisions) == 0 {
		fmt.Println("No decisions from triage agent")
		return nil
	}

	fmt.Printf("Got %d decisions\n", len(decisions))

	// Apply decisions
	if err := applyDecisions(db, decisions); err != nil {
		return fmt.Errorf("apply decisions: %w", err)
	}

	fmt.Println("Done")
	return nil
}

func ensureTables(db *sql.DB) error {
	_, err := db.Exec(`
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
	`)
	return err
}

func fetchEmails(db *sql.DB) ([]Email, error) {
	imapServer := getEnv("ALERT_IMAP_SERVER", "imap.gmail.com")
	imapUser := os.Getenv("ALERT_IMAP_USER")
	imapPassword := os.Getenv("ALERT_IMAP_PASSWORD")

	if imapUser == "" || imapPassword == "" {
		fmt.Println("IMAP credentials not configured. Set ALERT_IMAP_USER and ALERT_IMAP_PASSWORD.")
		return nil, nil
	}

	client, err := imapclient.DialTLS(imapServer+":993", nil)
	if err != nil {
		return nil, fmt.Errorf("dial: %w", err)
	}
	defer client.Close()

	if err := client.Login(imapUser, imapPassword).Wait(); err != nil {
		return nil, fmt.Errorf("login: %w", err)
	}
	defer client.Logout()

	if _, err := client.Select("INBOX", nil).Wait(); err != nil {
		return nil, fmt.Errorf("select inbox: %w", err)
	}

	// Search for unseen messages
	criteria := &imap.SearchCriteria{NotFlag: []imap.Flag{imap.FlagSeen}}
	searchData, err := client.Search(criteria, nil).Wait()
	if err != nil {
		return nil, fmt.Errorf("search: %w", err)
	}

	seqNums := searchData.AllSeqNums()
	if len(seqNums) == 0 {
		return nil, nil
	}

	var newEmails []Email

	// Fetch each message
	seqSet := imap.SeqSetNum(seqNums...)
	fetchOptions := &imap.FetchOptions{
		BodySection: []*imap.FetchItemBodySection{{}},
	}
	messages, err := client.Fetch(seqSet, fetchOptions).Collect()
	if err != nil {
		return nil, fmt.Errorf("fetch: %w", err)
	}

	var processedSeqNums []uint32
	for _, msg := range messages {
		for _, section := range msg.BodySection {
			email, err := processMessage(db, section.Bytes)
			if err != nil {
				log.Printf("process message: %v", err)
				continue
			}
			newEmails = append(newEmails, email)
			processedSeqNums = append(processedSeqNums, msg.SeqNum)
		}
	}

	// Mark as deleted
	if len(processedSeqNums) > 0 {
		delSeqSet := imap.SeqSetNum(processedSeqNums...)
		storeFlags := imap.StoreFlags{
			Op:    imap.StoreFlagsAdd,
			Flags: []imap.Flag{imap.FlagDeleted},
		}
		if err := client.Store(delSeqSet, &storeFlags, nil).Close(); err != nil {
			log.Printf("store deleted flag: %v", err)
		}
		if err := client.Expunge().Close(); err != nil {
			log.Printf("expunge: %v", err)
		}
	}

	return newEmails, nil
}

func processMessage(db *sql.DB, body []byte) (Email, error) {
	msg, err := mail.ReadMessage(strings.NewReader(string(body)))
	if err != nil {
		return Email{}, fmt.Errorf("parse message: %w", err)
	}

	from := decodeHeader(msg.Header.Get("From"))
	subject := decodeHeader(msg.Header.Get("Subject"))

	// Create folder
	timestamp := time.Now().Format("20060102-150405")
	var folderPath string
	for seq := 0; ; seq++ {
		folderPath = filepath.Join(emailsDir, fmt.Sprintf("%s-%02d", timestamp, seq))
		if _, err := os.Stat(folderPath); os.IsNotExist(err) {
			break
		}
	}
	os.MkdirAll(folderPath, 0755)

	// Extract body and attachments
	contentType := msg.Header.Get("Content-Type")
	if strings.HasPrefix(contentType, "multipart/") {
		if err := processMultipart(msg, folderPath); err != nil {
			log.Printf("process multipart: %v", err)
		}
	} else {
		body, _ := io.ReadAll(msg.Body)
		if strings.Contains(contentType, "text/html") {
			os.WriteFile(filepath.Join(folderPath, "body.html"), body, 0644)
		} else {
			os.WriteFile(filepath.Join(folderPath, "body.txt"), body, 0644)
		}
	}

	// Insert to database
	var id int64
	err = db.QueryRow(
		`INSERT INTO alert_emails (from_addr, subject, folder) VALUES ($1, $2, $3) RETURNING id`,
		from, subject, folderPath,
	).Scan(&id)
	if err != nil {
		return Email{}, fmt.Errorf("insert: %w", err)
	}

	return Email{ID: id, From: from, Subject: subject, Folder: folderPath}, nil
}

func processMultipart(msg *mail.Message, folderPath string) error {
	mediaType, params, err := mime.ParseMediaType(msg.Header.Get("Content-Type"))
	if err != nil {
		return err
	}
	if !strings.HasPrefix(mediaType, "multipart/") {
		return nil
	}

	mr := multipart.NewReader(msg.Body, params["boundary"])
	for {
		part, err := mr.NextPart()
		if err == io.EOF {
			break
		}
		if err != nil {
			return err
		}

		contentType := part.Header.Get("Content-Type")
		contentDisp := part.Header.Get("Content-Disposition")
		data, _ := io.ReadAll(part)

		if strings.Contains(contentDisp, "attachment") {
			filename := part.FileName()
			if filename != "" {
				os.WriteFile(filepath.Join(folderPath, filename), data, 0644)
			}
		} else if strings.Contains(contentType, "text/plain") {
			os.WriteFile(filepath.Join(folderPath, "body.txt"), data, 0644)
		} else if strings.Contains(contentType, "text/html") {
			os.WriteFile(filepath.Join(folderPath, "body.html"), data, 0644)
		}
	}
	return nil
}

func decodeHeader(header string) string {
	dec := new(mime.WordDecoder)
	decoded, err := dec.DecodeHeader(header)
	if err != nil {
		return header
	}
	return decoded
}

func dumpRulesIfNeeded(db *sql.DB) error {
	var latestUpdate sql.NullTime
	db.QueryRow("SELECT MAX(updated_at) FROM triage_rules").Scan(&latestUpdate)

	if !latestUpdate.Valid {
		return nil
	}

	info, err := os.Stat(rulesFile)
	if err == nil && info.ModTime().After(latestUpdate.Time) {
		return nil
	}

	rows, err := db.Query("SELECT from_pattern, subject_pattern, instructions FROM triage_rules ORDER BY id")
	if err != nil {
		return err
	}
	defer rows.Close()

	var sb strings.Builder
	sb.WriteString("# Triage Rules\n\n")

	hasRules := false
	for rows.Next() {
		hasRules = true
		var fromPat, subjPat, instructions sql.NullString
		rows.Scan(&fromPat, &subjPat, &instructions)

		sb.WriteString("## Rule\n")
		if fromPat.Valid && fromPat.String != "" {
			sb.WriteString(fmt.Sprintf("- From pattern: `%s`\n", fromPat.String))
		}
		if subjPat.Valid && subjPat.String != "" {
			sb.WriteString(fmt.Sprintf("- Subject pattern: `%s`\n", subjPat.String))
		}
		sb.WriteString(fmt.Sprintf("- Instructions: %s\n\n", instructions.String))
	}

	if !hasRules {
		sb.WriteString("No rules defined yet.\n")
	}

	return os.WriteFile(rulesFile, []byte(sb.String()), 0644)
}

func getNullEmails(db *sql.DB) ([]Email, error) {
	rows, err := db.Query(`SELECT id, from_addr, subject, folder FROM alert_emails WHERE status IS NULL`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var emails []Email
	for rows.Next() {
		var e Email
		rows.Scan(&e.ID, &e.From, &e.Subject, &e.Folder)
		emails = append(emails, e)
	}
	return emails, rows.Err()
}

func runTriageAgent(emails []Email) ([]Decision, error) {
	timestamp := time.Now().Format("20060102-150405")
	logFile := filepath.Join(logsDir, timestamp+"-triage.log")

	var prompt strings.Builder
	prompt.WriteString("Classify these emails:\n\n")
	for _, e := range emails {
		prompt.WriteString(fmt.Sprintf("- ID: %d, From: %s, Subject: %s, Folder: %s\n",
			e.ID, e.From, e.Subject, e.Folder))
	}

	cmd := exec.CommandContext(context.Background(),
		"claude", "-p", prompt.String(),
		"--model", "claude-sonnet-4-5",
		"--system-prompt-file", triageMD,
		"--setting-sources", "",
		"--strict-mcp-config",
		"--tools", "Read",
		"--no-session-persistence",
	)

	cmd.Env = append(os.Environ(),
		"CLAUDE_CODE_DISABLE_CLAUDE_MDS=1",
		"CLAUDE_CODE_DISABLE_CRON=1",
		"CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS=1",
		"CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1",
		"CLAUDE_CODE_DISABLE_THINKING=1",
		"CLAUDE_CODE_ENABLE_PROMPT_SUGGESTIONS=false",
		"CLAUDE_CODE_ENABLE_TASKS=0",
		"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1",
		"CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS=100000",
		"CLAUDE_CODE_SYNC_PLUGIN_INSTALL=0",
		"CLAUDE_CODE_SYNC_PLUGIN_INSTALL_TIMEOUT_MS=100",
		"DISABLE_AUTOUPDATER=1",
		"DISABLE_COMPACT=1",
		"DISABLE_NON_ESSENTIAL_MODEL_CALLS=1",
		"DISABLE_TELEMETRY=1",
		"ENABLE_CLAUDEAI_MCP_SERVERS=false",
		"ENABLE_LSP_TOOL=0",
		"ENABLE_TOOL_SEARCH=false",
		"MAX_MCP_OUTPUT_TOKENS=100000",
	)

	output, err := cmd.Output()

	// Log output
	logContent := fmt.Sprintf("Prompt:\n%s\n\nOutput:\n%s\n", prompt.String(), string(output))
	if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			logContent += fmt.Sprintf("\nStderr:\n%s\n", string(exitErr.Stderr))
		}
		os.WriteFile(logFile, []byte(logContent), 0644)
		return nil, fmt.Errorf("claude command: %w", err)
	}
	os.WriteFile(logFile, []byte(logContent), 0644)

	// Parse JSON from output
	outputStr := string(output)
	start := strings.Index(outputStr, "[")
	end := strings.LastIndex(outputStr, "]")
	if start < 0 || end <= start {
		return nil, nil
	}

	var decisions []Decision
	if err := json.Unmarshal([]byte(outputStr[start:end+1]), &decisions); err != nil {
		return nil, fmt.Errorf("parse json: %w", err)
	}

	return decisions, nil
}

func applyDecisions(db *sql.DB, decisions []Decision) error {
	hasCritical := false
	hasUnknown := false

	for _, d := range decisions {
		if d.ID == 0 || d.Status == "" {
			continue
		}

		_, err := db.Exec("UPDATE alert_emails SET status = $1 WHERE id = $2", d.Status, d.ID)
		if err != nil {
			log.Printf("update status: %v", err)
			continue
		}

		switch d.Status {
		case "A":
			var from, subject string
			db.QueryRow("SELECT from_addr, subject FROM alert_emails WHERE id = $1", d.ID).Scan(&from, &subject)
			if subject != "" {
				if len(subject) > 50 {
					subject = subject[:50]
				}
				exec.Command("notify-send", "-u", "normal",
					fmt.Sprintf("Alert: %s", subject),
					fmt.Sprintf("From: %s\n%s", from, d.Reason),
				).Run()
			}
		case "N":
			hasCritical = true
		case "U":
			hasUnknown = true
		}
	}

	if hasCritical || hasUnknown {
		launchInteractiveAgent()
	}

	return nil
}

func launchInteractiveAgent() {
	// Clean env to avoid nix library conflicts with system ghostty
	var cleanEnv []string
	for _, env := range os.Environ() {
		if !strings.HasPrefix(env, "NIX_") && !strings.HasPrefix(env, "LD_LIBRARY_PATH=") {
			cleanEnv = append(cleanEnv, env)
		}
	}

	cmd := exec.Command("ghostty", "-e",
		"claude", "--append-system-prompt-file", criticalMD,
		"Review the alerts that need attention.")
	cmd.Env = cleanEnv
	cmd.Start()
}

func getEnv(key, defaultVal string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return defaultVal
}

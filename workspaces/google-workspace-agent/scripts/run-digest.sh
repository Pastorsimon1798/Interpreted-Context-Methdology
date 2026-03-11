#!/bin/bash
#
# run-digest.sh - Generate digest from all stage outputs
#
# Usage: ./run-digest.sh [--email] [--slack] [--date YYYYMMDD]
#
# Options:
#   --email     Send digest via email (requires EMAIL_RECIPIENT in config)
#   --slack     Send digest via Slack (requires SLACK_WEBHOOK_URL in config)
#   --date      Process specific date (default: today)
#
# Dependencies:
#   - gws CLI (Google Workspace CLI)
#   - jq (JSON processor)
#   - Prior runs of run-triage.sh, run-extraction.sh, run-calendar.sh
#
# Output:
#   output/digest-YYYYMMDD.md
#

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_DIR="${WORKSPACE_ROOT}/output"
SHARED_DIR="${WORKSPACE_ROOT}/shared"
CONFIG_FILE="${WORKSPACE_ROOT}/config/agent-config.json"

# Date handling
DATE="${1#--date=}"
if [[ -z "${DATE:-}" ]] || [[ "$1" != "--date="* ]]; then
    DATE=$(date +%Y%m%d)
fi

# Parse flags
SEND_EMAIL=false
SEND_SLACK=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --email)
            SEND_EMAIL=true
            shift
            ;;
        --slack)
            SEND_SLACK=true
            shift
            ;;
        --date)
            DATE="$2"
            shift 2
            ;;
        --date=*)
            DATE="${1#--date=}"
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Output file
DIGEST_FILE="${OUTPUT_DIR}/digest-${DATE}.md"

# Template
TEMPLATE_FILE="${SHARED_DIR}/digest-template.md"

# =============================================================================
# DEPENDENCY CHECKS
# =============================================================================

check_dependencies() {
    local missing=()

    # Check for gws CLI
    if ! command -v gws &> /dev/null; then
        missing+=("gws CLI (Google Workspace CLI)")
    fi

    # Check for jq
    if ! command -v jq &> /dev/null; then
        missing+=("jq (JSON processor)")
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "ERROR: Missing dependencies:"
        printf '  - %s\n' "${missing[@]}"
        echo ""
        echo "Install missing dependencies and try again."
        exit 1
    fi
}

# =============================================================================
# LOAD CONFIGURATION
# =============================================================================

load_config() {
    if [[ ! -f "${CONFIG_FILE}" ]]; then
        echo "WARNING: Config file not found at ${CONFIG_FILE}"
        echo "Using default configuration."
        return
    fi

    # Parse config values
    DIGEST_FREQUENCY=$(jq -r '.digest.frequency // "daily"' "${CONFIG_FILE}")
    DIGEST_DELIVERY_TIME=$(jq -r '.digest.deliveryTime // "08:00"' "${CONFIG_FILE}")
    MAX_CRITICAL_ITEMS=$(jq -r '.digest.maxCriticalItems // 5' "${CONFIG_FILE}")
    MAX_HIGH_ITEMS=$(jq -r '.digest.maxHighItems // 10' "${CONFIG_FILE}")
    MAX_EXTRACTIONS=$(jq -r '.digest.maxExtractions // 10' "${CONFIG_FILE}")
    EMAIL_RECIPIENT=$(jq -r '.digest.emailRecipient // ""' "${CONFIG_FILE}")
    SLACK_WEBHOOK_URL=$(jq -r '.digest.slackWebhookUrl // ""' "${CONFIG_FILE}")
}

# =============================================================================
# READ STAGE OUTPUTS
# =============================================================================

read_triage_report() {
    local triage_file="${WORKSPACE_ROOT}/stages/01-triage/output/triage-report.md"

    if [[ ! -f "${triage_file}" ]]; then
        echo "WARNING: Triage report not found at ${triage_file}"
        return
    fi

    # Extract statistics from triage report
    TOTAL_EMAILS=$(grep -c "^## " "${triage_file}" 2>/dev/null || echo "0")
    CRITICAL_COUNT=$(grep -c "\[CRITICAL\]" "${triage_file}" 2>/dev/null || echo "0")
    HIGH_COUNT=$(grep -c "\[HIGH\]" "${triage_file}" 2>/dev/null || echo "0")
    ACTION_COUNT=$(grep -c "^\- \[ \]" "${triage_file}" 2>/dev/null || echo "0")

    # Extract critical items
    CRITICAL_ITEMS=$(sed -n '/## ACTION REQUIRED/,/## HIGH PRIORITY/p' "${triage_file}" 2>/dev/null | head -n -1)

    # Extract high priority items
    HIGH_ITEMS=$(sed -n '/## HIGH PRIORITY/,/## INBOX SUMMARY/p' "${triage_file}" 2>/dev/null | head -n -1)
}

read_extraction_log() {
    local extraction_file="${WORKSPACE_ROOT}/stages/02-extraction/output/extraction-log.md"

    if [[ ! -f "${extraction_file}" ]]; then
        echo "WARNING: Extraction log not found at ${extraction_file}"
        return
    fi

    # Count extractions
    RESOURCES_SAVED=$(grep -c "^- " "${extraction_file}" 2>/dev/null || echo "0")

    # Extract links
    EXTRACTED_LINKS=$(sed -n '/### Links/,/### /p' "${extraction_file}" 2>/dev/null | head -n -1)

    # Extract quotes
    EXTRACTED_QUOTES=$(sed -n '/### Quotes/,/### /p' "${extraction_file}" 2>/dev/null | head -n -1)

    # Extract deadlines
    EXTRACTED_DEADLINES=$(sed -n '/### Deadlines/,/### /p' "${extraction_file}" 2>/dev/null | head -n -1)
}

read_calendar_log() {
    local calendar_file="${WORKSPACE_ROOT}/stages/03-calendar/output/calendar-log.md"

    if [[ ! -f "${calendar_file}" ]]; then
        echo "WARNING: Calendar log not found at ${calendar_file}"
        return
    fi

    # Count events created
    EVENTS_CREATED=$(grep -c "^- " "${calendar_file}" 2>/dev/null || echo "0")

    # Extract today's schedule
    TODAY_SCHEDULE=$(sed -n '/### Today.*Schedule/,/### /p' "${calendar_file}" 2>/dev/null | head -n -1)

    # Extract upcoming events
    UPCOMING_EVENTS=$(sed -n '/### Upcoming/,/---/p' "${calendar_file}" 2>/dev/null | head -n -1)

    # Calculate focus time
    FOCUS_TIME=$(grep "Focus Time" "${calendar_file}" 2>/dev/null | head -1 || echo "Not tracked")
}

# =============================================================================
# AGGREGATE STATISTICS
# =============================================================================

aggregate_stats() {
    # Calculate totals
    TOTAL_PROCESSED=$((TOTAL_EMAILS + RESOURCES_SAVED + EVENTS_CREATED))

    # Calculate meeting load (placeholder - would need actual calendar data)
    MEETING_LOAD="${MEETING_LOAD:-0}"

    # Generate timestamp
    GENERATION_TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

    # Calculate next digest time
    case "${DIGEST_FREQUENCY}" in
        "daily")
            NEXT_DIGEST=$(date -v+1d "+%Y-%m-%d ${DIGEST_DELIVERY_TIME}")
            ;;
        "twice-daily")
            NEXT_DIGEST=$(date -v+12H "+%Y-%m-%d %H:%M")
            ;;
        "weekly")
            NEXT_DIGEST=$(date -v+7d "+%Y-%m-%d ${DIGEST_DELIVERY_TIME}")
            ;;
        *)
            NEXT_DIGEST=$(date -v+1d "+%Y-%m-%d ${DIGEST_DELIVERY_TIME}")
            ;;
    esac
}

# =============================================================================
# FORMAT DIGEST (ADHD-FRIENDLY)
# =============================================================================

format_digest() {
    local output_file="$1"

    cat > "${output_file}" << EOF
# Google Workspace Digest

**Date:** $(date -j -f "%Y%m%d" "${DATE}" "+%Y-%m-%d" 2>/dev/null || echo "${DATE}")
**Time Range:** Last 24 hours
**Generated:** ${GENERATION_TIMESTAMP}

---

## ACTION REQUIRED

EOF

    # Add critical items (max 5, bold for attention)
    if [[ -n "${CRITICAL_ITEMS:-}" ]]; then
        echo "${CRITICAL_ITEMS}" | head -n "${MAX_CRITICAL_ITEMS:-5}" >> "${output_file}"
    else
        echo "**No critical items** - Inbox is clear!" >> "${output_file}"
    fi

    cat >> "${output_file}" << EOF

---

## HIGH PRIORITY

EOF

    # Add high priority items (max 10)
    if [[ -n "${HIGH_ITEMS:-}" ]]; then
        echo "${HIGH_ITEMS}" | head -n "${MAX_HIGH_ITEMS:-10}" >> "${output_file}"
    else
        echo "All caught up - no high priority items pending." >> "${output_file}"
    fi

    cat >> "${output_file}" << EOF

---

## INBOX SUMMARY

| Category | Count | Status |
|----------|-------|--------|
| **Critical** | ${CRITICAL_COUNT:-0} | Action Required |
| **High Priority** | ${HIGH_COUNT:-0} | Review Today |
| Action Items | ${ACTION_COUNT:-0} | Created in Tasks |
| Total Processed | ${TOTAL_PROCESSED:-0} | This Period |

---

## EXTRACTED THIS PERIOD

EOF

    # Add extractions (max 10)
    if [[ -n "${EXTRACTED_LINKS:-}" ]]; then
        echo "### Links" >> "${output_file}"
        echo "${EXTRACTED_LINKS}" | head -n "${MAX_EXTRACTIONS:-10}" >> "${output_file}"
        echo "" >> "${output_file}"
    fi

    if [[ -n "${EXTRACTED_QUOTES:-}" ]]; then
        echo "### Quotes" >> "${output_file}"
        echo "${EXTRACTED_QUOTES}" | head -n "${MAX_EXTRACTIONS:-10}" >> "${output_file}"
        echo "" >> "${output_file}"
    fi

    if [[ -n "${EXTRACTED_DEADLINES:-}" ]]; then
        echo "### Deadlines" >> "${output_file}"
        echo "${EXTRACTED_DEADLINES}" | head -n "${MAX_EXTRACTIONS:-10}" >> "${output_file}"
        echo "" >> "${output_file}"
    fi

    cat >> "${output_file}" << EOF

---

## CALENDAR

### Today's Schedule

EOF

    if [[ -n "${TODAY_SCHEDULE:-}" ]]; then
        echo "${TODAY_SCHEDULE}" >> "${output_file}"
    else
        echo "No events scheduled for today." >> "${output_file}"
    fi

    cat >> "${output_file}" << EOF

**Focus Time Remaining:** ${FOCUS_TIME:-Not tracked}
**Meeting Load:** ${MEETING_LOAD}% of day

### Upcoming

EOF

    if [[ -n "${UPCOMING_EVENTS:-}" ]]; then
        echo "${UPCOMING_EVENTS}" >> "${output_file}"
    else
        echo "No upcoming events in the next 7 days." >> "${output_file}"
    fi

    cat >> "${output_file}" << EOF

---

## METRICS

**Emails Processed:** ${TOTAL_EMAILS:-0}
**Actions Extracted:** ${ACTION_COUNT:-0}
**Resources Saved:** ${RESOURCES_SAVED:-0}
**Events Created:** ${EVENTS_CREATED:-0}

---

## QUICK ACTIONS

- [ ] Mark all promotional as read
- [ ] Archive processed newsletters
- [ ] Schedule focus time for tomorrow

---

**Next Digest:** ${NEXT_DIGEST}

**Agent Notes:** Digest generated from triage, extraction, and calendar stage outputs.
EOF

    echo "Digest written to: ${output_file}"
}

# =============================================================================
# OUTPUT DELIVERY
# =============================================================================

send_via_email() {
    if [[ "${SEND_EMAIL}" != "true" ]]; then
        return
    fi

    if [[ -z "${EMAIL_RECIPIENT:-}" ]]; then
        echo "WARNING: EMAIL_RECIPIENT not configured. Skipping email delivery."
        return
    fi

    echo "Sending digest via email to ${EMAIL_RECIPIENT}..."

    # Use gws CLI for Gmail delivery (+send)
    local subject="Google Workspace Digest - ${DATE}"
    local body
    body=$(cat "${DIGEST_FILE}")

    # Try gws gmail +send first, fall back to mail command
    if command -v gws &> /dev/null; then
        echo "Sending via Gmail (+send)..."

        # Create temporary file with properly escaped body for JSON
        local temp_json
        temp_json=$(mktemp)
        jq -n \
            --arg to "${EMAIL_RECIPIENT}" \
            --arg subject "$subject" \
            --arg body "$body" \
            '{
                to: $to,
                subject: $subject,
                body: $body
            }' > "$temp_json"

        if gws gmail +send --json "$temp_json" 2>/dev/null; then
            echo "Email sent successfully via Gmail."
            rm -f "$temp_json"
            return 0
        else
            echo "WARNING: gws gmail +send failed, falling back to mail command."
            rm -f "$temp_json"
        fi
    fi

    # Fall back to mail command
    if command -v mail &> /dev/null; then
        mail -s "Google Workspace Digest - ${DATE}" "${EMAIL_RECIPIENT}" < "${DIGEST_FILE}"
        echo "Email sent successfully."
    else
        echo "WARNING: Neither 'gws' nor 'mail' available. Cannot send email."
        return 1
    fi
}

# =============================================================================
# Gmail +send Helper (Direct)
# =============================================================================

# Send an email using Gmail +send
# Usage: send_email <to> <subject> <body>
send_email() {
    local to="${1:-}"
    local subject="${2:-}"
    local body="${3:-}"

    if [[ -z "$to" || -z "$subject" ]]; then
        echo "ERROR: 'to' and 'subject' are required"
        echo "Usage: send_email <to> <subject> [body]"
        return 1
    fi

    # If body is a file path, read it
    if [[ -f "$body" ]]; then
        body=$(cat "$body")
    fi

    echo "Sending email to ${to}..."
    echo "Subject: ${subject}"

    # Create JSON payload
    local temp_json
    temp_json=$(mktemp)
    jq -n \
        --arg to "$to" \
        --arg subject "$subject" \
        --arg body "$body" \
        '{
            to: $to,
            subject: $subject,
            body: $body
        }' > "$temp_json"

    if gws gmail +send --json "$temp_json" 2>/dev/null; then
        echo "Email sent successfully."
        rm -f "$temp_json"
        return 0
    else
        echo "ERROR: Failed to send email."
        rm -f "$temp_json"
        return 1
    fi
}

# =============================================================================
# Reply to Email (+reply)
# =============================================================================

# Reply to an email using Gmail +reply
# Usage: reply_email <message_id> <body>
reply_email() {
    local message_id="${1:-}"
    local body="${2:-}"

    if [[ -z "$message_id" || -z "$body" ]]; then
        echo "ERROR: message_id and body are required"
        echo "Usage: reply_email <message_id> <body>"
        return 1
    fi

    echo "Replying to message: ${message_id}"

    # Create JSON payload
    local temp_json
    temp_json=$(mktemp)
    jq -n \
        --arg id "$message_id" \
        --arg body "$body" \
        '{
            messageId: $id,
            body: $body
        }' > "$temp_json"

    if gws gmail +reply --json "$temp_json" 2>/dev/null; then
        echo "Reply sent successfully."
        rm -f "$temp_json"
        return 0
    else
        echo "ERROR: Failed to send reply."
        rm -f "$temp_json"
        return 1
    fi
}

send_via_slack() {
    if [[ "${SEND_SLACK}" != "true" ]]; then
        return
    fi

    if [[ -z "${SLACK_WEBHOOK_URL:-}" ]]; then
        echo "WARNING: SLACK_WEBHOOK_URL not configured. Skipping Slack delivery."
        return
    fi

    echo "Sending digest via Slack..."

    # Format for Slack (simplified)
    local slack_message
    slack_message=$(cat << EOF
{
    "text": "*Google Workspace Digest - ${DATE}*",
    "blocks": [
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "*:rotating_light: ACTION REQUIRED*\n${CRITICAL_COUNT:-0} critical items\n\n*:calendar: Next up:* Check digest for details\n\n*:white_check_mark: Actions due:* ${ACTION_COUNT:-0}"
            }
        }
    ]
}
EOF
)

    curl -s -X POST -H 'Content-type: application/json' \
        --data "${slack_message}" \
        "${SLACK_WEBHOOK_URL}" > /dev/null

    echo "Slack notification sent."
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    # Check for command mode
    local command="${1:-}"

    case "$command" in
        send)
            # Direct send: ./run-digest.sh send <to> <subject> [body|file]
            shift
            local to="${1:-}"
            local subject="${2:-}"
            local body="${3:-}"

            if [[ -z "$to" || -z "$subject" ]]; then
                echo "Usage: $0 send <to> <subject> [body|file]"
                exit 1
            fi

            # If body is a file, read it; otherwise use as-is
            if [[ -n "$body" && -f "$body" ]]; then
                body=$(cat "$body")
            elif [[ -z "$body" ]]; then
                # Read body from stdin
                body=$(cat)
            fi

            check_dependencies
            send_email "$to" "$subject" "$body"
            ;;
        reply)
            # Reply to email: ./run-digest.sh reply <message_id> [body|file]
            shift
            local message_id="${1:-}"
            local body="${2:-}"

            if [[ -z "$message_id" ]]; then
                echo "Usage: $0 reply <message_id> [body|file]"
                exit 1
            fi

            # If body is a file, read it
            if [[ -n "$body" && -f "$body" ]]; then
                body=$(cat "$body")
            elif [[ -z "$body" ]]; then
                # Read body from stdin
                body=$(cat)
            fi

            check_dependencies
            reply_email "$message_id" "$body"
            ;;
        --help|-h)
            cat << EOF
Google Workspace Digest Generator

Usage: $0 [command] [options]

Commands:
  (default)              Generate and optionally deliver digest
  send <to> <subj> [body]  Send email via Gmail +send
  reply <msg_id> [body]    Reply to email via Gmail +reply

Options:
  --email         Send digest via email after generation
  --slack         Send digest via Slack after generation
  --date YYYYMMDD Process specific date (default: today)

Examples:
  $0                                    # Generate today's digest
  $0 --email                            # Generate and send via email
  $0 send user@example.com "Subject"    # Send email
  $0 send user@example.com "Subj" body.txt  # Send with body from file
  $0 reply 18a3b4 "Thanks!"             # Reply to message
EOF
            exit 0
            ;;
        *)
            # Default: generate digest
            main_digest "$@"
            ;;
    esac
}

# Original digest generation logic
main_digest() {
    echo "=========================================="
    echo "Google Workspace Digest Generator"
    echo "=========================================="
    echo ""
    echo "Date: ${DATE}"
    echo "Output: ${DIGEST_FILE}"
    echo ""

    # Step 1: Check dependencies
    echo "[1/8] Checking dependencies..."
    check_dependencies

    # Step 2: Load configuration
    echo "[2/8] Loading configuration..."
    load_config

    # Step 3: Read triage report
    echo "[3/8] Reading triage report..."
    read_triage_report

    # Step 4: Read extraction log
    echo "[4/8] Reading extraction log..."
    read_extraction_log

    # Step 5: Read calendar log
    echo "[5/8] Reading calendar log..."
    read_calendar_log

    # Step 6: Aggregate statistics
    echo "[6/8] Aggregating statistics..."
    aggregate_stats

    # Step 7: Format digest
    echo "[7/8] Formatting digest..."
    format_digest "${DIGEST_FILE}"

    # Step 8: Deliver (if configured)
    echo "[8/8] Delivering digest..."
    send_via_email
    send_via_slack

    echo ""
    echo "=========================================="
    echo "Digest Complete"
    echo "=========================================="
    echo ""
    echo "Output file: ${DIGEST_FILE}"
    echo ""
    echo "Summary:"
    echo "  - Critical items: ${CRITICAL_COUNT:-0}"
    echo "  - High priority: ${HIGH_COUNT:-0}"
    echo "  - Actions created: ${ACTION_COUNT:-0}"
    echo "  - Resources saved: ${RESOURCES_SAVED:-0}"
    echo "  - Events created: ${EVENTS_CREATED:-0}"
    echo ""
}

# Run main
main "$@"

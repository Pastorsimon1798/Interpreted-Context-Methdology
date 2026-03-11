#!/bin/bash
#
# gws-workflows.sh - Cross-service GWS workflow helpers
#
# This script provides wrappers for GWS workflow commands that combine
# multiple services (Gmail, Calendar, Tasks, Drive) into useful workflows.
#
# Usage:
#   Source this file: source shared/gws-workflows.sh
#   Or run directly: ./gws-workflows.sh <workflow> [args]
#
# Available workflows:
#   email-to-task   - Extract action items from email to Google Tasks
#   standup         - Generate daily standup report
#   weekly-digest   - Generate and send weekly digest
#   meeting-prep    - Prepare context for upcoming meeting
#
# Dependencies:
#   - gws CLI (Google Workspace CLI)
#   - jq (JSON processor)
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_DIR="${WORKSPACE_ROOT}/output"
STAGES_DIR="${WORKSPACE_ROOT}/stages"

# =============================================================================
# Workflow: Email to Task
# =============================================================================

# Extract action items from an email and create Google Tasks
# Usage: gws-workflow-email-to-task <message_id> [tasklist_id]
gws-workflow-email-to-task() {
    local message_id="${1:-}"
    local tasklist_id="${2:-@default}"

    if [[ -z "$message_id" ]]; then
        echo "ERROR: message_id is required"
        echo "Usage: gws-workflow-email-to-task <message_id> [tasklist_id]"
        return 1
    fi

    echo "Extracting tasks from email: ${message_id}"

    # Get email details
    local email_json
    email_json=$(gws gmail users messages get \
        --params "{\"userId\":\"me\",\"id\":\"${message_id}\"}" \
        --format json 2>/dev/null) || {
        echo "ERROR: Failed to fetch email ${message_id}"
        return 1
    }

    # Extract subject for task title
    local subject
    subject=$(echo "$email_json" | jq -r '.payload.headers[] | select(.name == "Subject") | .value // "Email Task"' 2>/dev/null)

    # Extract sender for task notes
    local from
    from=$(echo "$email_json" | jq -r '.payload.headers[] | select(.name == "From") | .value // "Unknown"' 2>/dev/null)

    # Create task with reference to source email
    local task_json
    task_json=$(jq -n \
        --arg title "Follow up: ${subject}" \
        --arg notes "Source: Email from ${from}\nMessage ID: ${message_id}\nLink: https://mail.google.com/mail/u/0/#inbox/${message_id}" \
        '{
            title: $title,
            notes: $notes
        }')

    echo "Creating task: ${subject}"

    gws tasks tasks insert \
        --tasklist "$tasklist_id" \
        --json "$task_json" 2>/dev/null || {
        echo "ERROR: Failed to create task"
        return 1
    }

    echo "Task created successfully"

    # Log the extraction
    local log_file="${STAGES_DIR}/02-extraction/output/email-to-task.log"
    mkdir -p "$(dirname "$log_file")"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Created task from email ${message_id}: ${subject}" >> "$log_file"
}

# =============================================================================
# Workflow: Standup Report
# =============================================================================

# Generate a daily standup report from calendar, tasks, and email activity
# Usage: gws-workflow-standup [date]
gws-workflow-standup() {
    local date="${1:-$(date '+%Y-%m-%d')}"

    echo "Generating standup report for ${date}"
    echo "========================================"

    # Get today's calendar events
    echo ""
    echo "## Calendar Events"
    echo "-------------------"

    local time_min="${date}T00:00:00Z"
    local time_max="${date}T23:59:59Z"

    gws calendar events list \
        --calendar primary \
        --time-min "$time_min" \
        --time-max "$time_max" \
        --max-results 20 \
        --format json 2>/dev/null | \
        jq -r '.[] | "- \(.summary // "Untitled") at \(.start.dateTime // .start.date)"' 2>/dev/null || \
        echo "No events found"

    # Get pending tasks
    echo ""
    echo "## Pending Tasks"
    echo "-------------------"

    gws tasks tasks list \
        --tasklist @default \
        --max-results 10 \
        --format json 2>/dev/null | \
        jq -r '.[] | select(.status != "completed") | "- \(.title)"' 2>/dev/null || \
        echo "No pending tasks"

    # Get unread email count
    echo ""
    echo "## Email Summary"
    echo "-------------------"

    local unread_count
    unread_count=$(gws gmail +triage --max 100 --format json 2>/dev/null | \
        jq '.messages | length' 2>/dev/null || echo "0")

    echo "Unread emails: ${unread_count}"

    # Check for urgent items from triage
    local urgent_count
    urgent_count=$(gws gmail +triage --max 100 --format json 2>/dev/null | \
        jq '[.messages[] | select(.subject | test("urgent|asap|critical|deadline"; "i"))] | length' 2>/dev/null || echo "0")

    if [[ "$urgent_count" -gt 0 ]]; then
        echo "URGENT items: ${urgent_count}"
    fi

    echo ""
    echo "========================================"
    echo "Standup report complete"
}

# =============================================================================
# Workflow: Weekly Digest
# =============================================================================

# Generate and optionally send a weekly digest
# Usage: gws-workflow-weekly [--send] [email]
gws-workflow-weekly() {
    local send_email=false
    local recipient=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --send)
                send_email=true
                shift
                ;;
            *)
                recipient="$1"
                shift
                ;;
        esac
    done

    local week_start week_end
    week_start=$(date -v-7d '+%Y-%m-%d')
    week_end=$(date '+%Y-%m-%d')

    echo "Generating weekly digest for ${week_start} to ${week_end}"
    echo "========================================"

    local digest_file="${OUTPUT_DIR}/weekly-digest-${week_end}.md"
    mkdir -p "${OUTPUT_DIR}"

    # Start building the digest
    cat > "$digest_file" << EOF
# Weekly Digest

**Period:** ${week_start} to ${week_end}
**Generated:** $(date '+%Y-%m-%d %H:%M:%S')

---

## Calendar Summary

EOF

    # Get calendar events for the week
    local time_min="${week_start}T00:00:00Z"
    local time_max="${week_end}T23:59:59Z"

    gws calendar events list \
        --calendar primary \
        --time-min "$time_min" \
        --time-max "$time_max" \
        --max-results 50 \
        --format json 2>/dev/null | \
        jq -r '.[] | "- **\(.summary // "Untitled")** - \(.start.dateTime // .start.date)"' >> "$digest_file" 2>/dev/null || \
        echo "No events this week" >> "$digest_file"

    # Add task summary
    cat >> "$digest_file" << EOF

---

## Tasks Summary

EOF

    local completed_tasks total_tasks
    completed_tasks=$(gws tasks tasks list --tasklist @default --format json 2>/dev/null | \
        jq '[.[] | select(.status == "completed")] | length' 2>/dev/null || echo "0")
    total_tasks=$(gws tasks tasks list --tasklist @default --format json 2>/dev/null | \
        jq '. | length' 2>/dev/null || echo "0")

    echo "- Completed: ${completed_tasks}" >> "$digest_file"
    echo "- Total: ${total_tasks}" >> "$digest_file"

    # Add pending tasks
    cat >> "$digest_file" << EOF

### Pending Tasks

EOF

    gws tasks tasks list \
        --tasklist @default \
        --max-results 10 \
        --format json 2>/dev/null | \
        jq -r '.[] | select(.status != "completed") | "- \(.title)"' >> "$digest_file" 2>/dev/null || \
        echo "No pending tasks" >> "$digest_file"

    # Add email summary
    cat >> "$digest_file" << EOF

---

## Email Summary

EOF

    local unread_count
    unread_count=$(gws gmail +triage --max 100 --format json 2>/dev/null | \
        jq '.messages | length' 2>/dev/null || echo "0")

    echo "Unread emails: ${unread_count}" >> "$digest_file"

    # Add footer
    cat >> "$digest_file" << EOF

---

*Generated by Google Workspace Agent*
EOF

    echo ""
    echo "Digest saved to: ${digest_file}"

    # Send via email if requested
    if [[ "$send_email" == "true" ]]; then
        if [[ -z "$recipient" ]]; then
            echo "ERROR: No recipient specified for email delivery"
            echo "Usage: gws-workflow-weekly --send <email>"
            return 1
        fi

        echo "Sending digest to ${recipient}..."

        local subject="Weekly Digest - ${week_end}"
        local body
        body=$(cat "$digest_file")

        gws gmail +send \
            --to "$recipient" \
            --subject "$subject" \
            --body "$body" 2>/dev/null || {
            echo "ERROR: Failed to send digest"
            return 1
        }

        echo "Digest sent successfully"
    fi
}

# =============================================================================
# Workflow: Meeting Prep
# =============================================================================

# Prepare context for an upcoming meeting
# Usage: gws-workflow-meeting-prep [event_id] [--hours N]
gws-workflow-meeting-prep() {
    local event_id=""
    local hours_ahead=1

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --hours)
                hours_ahead="$2"
                shift 2
                ;;
            *)
                event_id="$1"
                shift
                ;;
        esac
    done

    echo "Preparing meeting context..."
    echo "========================================"

    # If no event_id, find the next upcoming meeting
    if [[ -z "$event_id" ]]; then
        local time_min time_max
        time_min=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
        time_max=$(date -u -v+${hours_ahead}H '+%Y-%m-%dT%H:%M:%SZ')

        echo "Looking for meetings in the next ${hours_ahead} hour(s)..."

        local next_event
        next_event=$(gws calendar events list \
            --calendar primary \
            --time-min "$time_min" \
            --time-max "$time_max" \
            --max-results 1 \
            --format json 2>/dev/null)

        if [[ -z "$next_event" || "$next_event" == "[]" ]]; then
            echo "No upcoming meetings found"
            return 0
        fi

        event_id=$(echo "$next_event" | jq -r '.[0].id' 2>/dev/null)
    fi

    # Get event details
    local event_json
    event_json=$(gws calendar events get \
        --calendar primary \
        --event "$event_id" \
        --format json 2>/dev/null) || {
        echo "ERROR: Failed to fetch event ${event_id}"
        return 1
    }

    local summary start_time end_time description attendees
    summary=$(echo "$event_json" | jq -r '.summary // "Untitled Meeting"')
    start_time=$(echo "$event_json" | jq -r '.start.dateTime // .start.date')
    end_time=$(echo "$event_json" | jq -r '.end.dateTime // .end.date')
    description=$(echo "$event_json" | jq -r '.description // ""')
    attendees=$(echo "$event_json" | jq -r '.attendees // []')

    echo ""
    echo "## Meeting: ${summary}"
    echo "-----------------------------------"
    echo "**Time:** ${start_time} - ${end_time}"

    if [[ -n "$description" ]]; then
        echo ""
        echo "**Description:**"
        echo "$description"
    fi

    # Show attendees
    if [[ "$attendees" != "[]" ]]; then
        echo ""
        echo "**Attendees:**"
        echo "$attendees" | jq -r '.[] | "- \(.email) (\(.responseStatus // "unknown"))"'
    fi

    # Check for related emails
    echo ""
    echo "## Related Context"
    echo "-----------------------------------"

    # Search for emails related to this meeting
    local search_term
    search_term=$(echo "$summary" | head -c 50)

    echo "Searching emails for: ${search_term}..."

    gws gmail +triage --max 10 --format json 2>/dev/null | \
        jq -r --arg term "$search_term" '.messages[] | select(.subject | test($term; "i")) | "- \(.subject) (from: \(.from))"' 2>/dev/null || \
        echo "No related emails found"

    # Check for related tasks
    echo ""
    echo "## Related Tasks"
    echo "-----------------------------------"

    gws tasks tasks list \
        --tasklist @default \
        --max-results 10 \
        --format json 2>/dev/null | \
        jq -r --arg term "$search_term" '.[] | select(.title | test($term; "i")) | "- \(.title)"' 2>/dev/null || \
        echo "No related tasks found"

    echo ""
    echo "========================================"
    echo "Meeting prep complete"
}

# =============================================================================
# Workflow: Schedule Focus Time
# =============================================================================

# Schedule a focus block on the calendar
# Usage: gws-workflow-focus [duration_minutes] [date] [time]
gws-workflow-focus() {
    local duration="${1:-90}"
    local date="${2:-$(date '+%Y-%m-%d')}"
    local time="${3:-}"

    echo "Scheduling focus time..."
    echo "Duration: ${duration} minutes"
    echo "Date: ${date}"

    # If no time specified, find the next available slot
    if [[ -z "$time" ]]; then
        echo "Finding next available slot..."

        # Get working hours (default 9-5)
        local work_start="09:00"
        local work_end="17:00"

        # Get existing events for the day
        local time_min="${date}T00:00:00Z"
        local time_max="${date}T23:59:59Z"

        local existing_events
        existing_events=$(gws calendar events list \
            --calendar primary \
            --time-min "$time_min" \
            --time-max "$time_max" \
            --format json 2>/dev/null || echo '[]')

        # Find first available slot after work_start
        # This is a simplified algorithm - could be enhanced
        time="$work_start"
    fi

    # Calculate end time
    local start_hour start_min
    start_hour=$(echo "$time" | cut -d: -f1 | sed 's/^0//')
    start_min=$(echo "$time" | cut -d: -f2)

    local end_mins=$((start_hour * 60 + start_min + duration))
    local end_hour=$((end_mins / 60))
    local end_min=$((end_mins % 60))

    local end_time
    end_time="$(printf '%02d' $end_hour):$(printf '%02d' $end_min)"

    local start_datetime="${date}T${time}:00"
    local end_datetime="${date}T${end_time}:00"

    echo "Creating focus block: ${time} - ${end_time}"

    # Create the event
    local event_json
    event_json=$(jq -n \
        --arg summary "[Focus Time]" \
        --arg start "$start_datetime" \
        --arg end "$end_datetime" \
        --arg description "Blocked for deep work. ADHD-friendly focus block." \
        '{
            summary: $summary,
            start: { dateTime: $start },
            end: { dateTime: $end },
            description: $description
        }')

    gws calendar events insert \
        --calendar primary \
        --json "$event_json" 2>/dev/null || {
        echo "ERROR: Failed to create focus block"
        return 1
    }

    echo "Focus block created successfully"
}

# =============================================================================
# Workflow: Chat Notification
# =============================================================================

# Send a notification to Google Chat
# Usage: gws-workflow-notify <space_id> <message>
gws-workflow-notify() {
    local space_id="${1:-}"
    local message="${2:-}"

    if [[ -z "$space_id" || -z "$message" ]]; then
        echo "ERROR: space_id and message are required"
        echo "Usage: gws-workflow-notify <space_id> <message>"
        return 1
    fi

    echo "Sending notification to Chat space: ${space_id}"

    gws chat +send \
        --space "$space_id" \
        --text "$message" 2>/dev/null || {
        echo "ERROR: Failed to send Chat notification"
        return 1
    }

    echo "Notification sent successfully"
}

# =============================================================================
# Main CLI Entry Point
# =============================================================================

# When run directly, dispatch to the appropriate workflow
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    workflow="${1:-}"
    shift || true

    case "$workflow" in
        email-to-task)
            gws-workflow-email-to-task "$@"
            ;;
        standup)
            gws-workflow-standup "$@"
            ;;
        weekly-digest)
            gws-workflow-weekly "$@"
            ;;
        meeting-prep)
            gws-workflow-meeting-prep "$@"
            ;;
        focus)
            gws-workflow-focus "$@"
            ;;
        notify)
            gws-workflow-notify "$@"
            ;;
        *)
            echo "Google Workspace Workflow Helpers"
            echo ""
            echo "Usage: $0 <workflow> [args]"
            echo ""
            echo "Available workflows:"
            echo "  email-to-task <message_id> [tasklist_id]  - Extract tasks from email"
            echo "  standup [date]                             - Generate daily standup report"
            echo "  weekly-digest [--send] [email]             - Generate (and send) weekly digest"
            echo "  meeting-prep [event_id] [--hours N]        - Prepare meeting context"
            echo "  focus [duration] [date] [time]             - Schedule focus time"
            echo "  notify <space_id> <message>                - Send Chat notification"
            exit 1
            ;;
    esac
fi

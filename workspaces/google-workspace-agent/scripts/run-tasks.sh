#!/bin/bash
#
# run-tasks.sh - Google Tasks Management for Google Workspace Agent
#
# This script manages Google Tasks integration:
# - List task lists and tasks
# - Create tasks from action items
# - Sync with knowledge base items
# - Mark tasks complete
#
# Dependencies:
#   - gws CLI (Google Workspace CLI)
#   - jq (JSON processor)
#
# Usage:
#   ./run-tasks.sh list [tasklist_id]        - List tasks
#   ./run-tasks.sh tasklists                 - List all task lists
#   ./run-tasks.sh create <title> [options]  - Create a new task
#   ./run-tasks.sh complete <task_id>        - Mark task complete
#   ./run-tasks.sh sync                      - Sync from extraction log
#

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_DIR="${WORKSPACE_ROOT}/output"
STAGES_DIR="${WORKSPACE_ROOT}/stages"
SHARED_DIR="${WORKSPACE_ROOT}/shared"

# Default task list (can be overridden by config)
DEFAULT_TASKLIST="@default"

# Timestamp for logs
TIMESTAMP=$(date +"%Y%m%d-%H%M")
LOG_FILE="${STAGES_DIR}/02-extraction/output/tasks-log-${TIMESTAMP}.md"

# =============================================================================
# Helper Functions
# =============================================================================

log() {
    local level="$1"
    shift
    local message="$*"
    local ts=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[${ts}] [${level}] ${message}"
}

log_info() {
    log "INFO" "$@"
}

log_error() {
    log "ERROR" "$@" >&2
}

check_dependencies() {
    local missing=()

    if ! command -v gws &> /dev/null; then
        missing+=("gws CLI (Google Workspace CLI)")
    fi

    if ! command -v jq &> /dev/null; then
        missing+=("jq (JSON processor)")
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing dependencies:"
        printf '  - %s\n' "${missing[@]}"
        exit 1
    fi
}

# =============================================================================
# Task List Operations
# =============================================================================

# List all task lists
cmd_tasklists() {
    log_info "Fetching task lists..."

    local tasklists_json
    tasklists_json=$(gws tasks tasklists list --format json 2>/dev/null)

    if [[ -z "$tasklists_json" || "$tasklists_json" == "[]" ]]; then
        echo "No task lists found"
        return 0
    fi

    echo ""
    echo "Task Lists:"
    echo "-----------"

    echo "$tasklists_json" | jq -r '.[] | "- \(.title) (ID: \(.id))"'
}

# List tasks in a task list
cmd_list() {
    local tasklist_id="${1:-$DEFAULT_TASKLIST}"
    local show_completed="${2:-false}"

    log_info "Fetching tasks from: ${tasklist_id}"

    local tasks_json
    tasks_json=$(gws tasks tasks list \
        --tasklist "$tasklist_id" \
        --max-results 100 \
        --format json 2>/dev/null)

    if [[ -z "$tasks_json" || "$tasks_json" == "[]" ]]; then
        echo "No tasks found"
        return 0
    fi

    echo ""
    echo "Tasks:"
    echo "------"

    if [[ "$show_completed" == "true" ]]; then
        echo "$tasks_json" | jq -r '.[] | "[\(.status)] \(.title) (ID: \(.id))"'
    else
        echo "$tasks_json" | jq -r '.[] | select(.status != "completed") | "- \(.title) (ID: \(.id))"'
    fi

    # Show summary
    local total completed pending
    total=$(echo "$tasks_json" | jq '. | length')
    completed=$(echo "$tasks_json" | jq '[.[] | select(.status == "completed")] | length')
    pending=$((total - completed))

    echo ""
    echo "Summary: ${pending} pending, ${completed} completed, ${total} total"
}

# =============================================================================
# Task CRUD Operations
# =============================================================================

# Create a new task
cmd_create() {
    local title="${1:-}"
    local tasklist_id="${2:-$DEFAULT_TASKLIST}"
    local notes="${3:-}"
    local due_date="${4:-}"

    if [[ -z "$title" ]]; then
        log_error "Task title is required"
        echo "Usage: $0 create <title> [tasklist_id] [notes] [due_date]"
        return 1
    fi

    log_info "Creating task: ${title}"

    # Build task JSON
    local task_json
    task_json=$(jq -n \
        --arg title "$title" \
        --arg notes "$notes" \
        --arg due "$due_date" \
        '{
            title: $title,
            notes: (if $notes != "" then $notes else empty end),
            due: (if $due != "" then $due else empty end)
        } | with_entries(select(.value != null and .value != ""))')

    local result
    result=$(gws tasks tasks insert \
        --tasklist "$tasklist_id" \
        --json "$task_json" 2>/dev/null)

    if [[ $? -eq 0 ]]; then
        local task_id
        task_id=$(echo "$result" | jq -r '.id')
        log_info "Task created successfully: ${task_id}"

        # Log the creation
        mkdir -p "$(dirname "$LOG_FILE")"
        echo "- [CREATED] ${title} (ID: ${task_id})" >> "$LOG_FILE"

        echo "$result"
    else
        log_error "Failed to create task"
        return 1
    fi
}

# Mark a task as complete
cmd_complete() {
    local task_id="${1:-}"
    local tasklist_id="${2:-$DEFAULT_TASKLIST}"

    if [[ -z "$task_id" ]]; then
        log_error "Task ID is required"
        echo "Usage: $0 complete <task_id> [tasklist_id]"
        return 1
    fi

    log_info "Completing task: ${task_id}"

    # Build update JSON
    local task_json
    task_json='{"status": "completed"}'

    local result
    result=$(gws tasks tasks update \
        --tasklist "$tasklist_id" \
        --task "$task_id" \
        --json "$task_json" 2>/dev/null)

    if [[ $? -eq 0 ]]; then
        log_info "Task completed successfully"

        # Log the completion
        mkdir -p "$(dirname "$LOG_FILE")"
        echo "- [COMPLETED] Task ${task_id}" >> "$LOG_FILE"

        echo "Task ${task_id} marked as complete"
    else
        log_error "Failed to complete task"
        return 1
    fi
}

# Delete a task
cmd_delete() {
    local task_id="${1:-}"
    local tasklist_id="${2:-$DEFAULT_TASKLIST}"

    if [[ -z "$task_id" ]]; then
        log_error "Task ID is required"
        echo "Usage: $0 delete <task_id> [tasklist_id]"
        return 1
    fi

    log_info "Deleting task: ${task_id}"

    gws tasks tasks delete \
        --tasklist "$tasklist_id" \
        --task "$task_id" 2>/dev/null

    if [[ $? -eq 0 ]]; then
        log_info "Task deleted successfully"
        echo "Task ${task_id} deleted"
    else
        log_error "Failed to delete task"
        return 1
    fi
}

# =============================================================================
# Knowledge Base Sync
# =============================================================================

# Sync action items from extraction log to Google Tasks
cmd_sync() {
    local extraction_log="${STAGES_DIR}/01-triage/output/triage-report.md"

    if [[ ! -f "$extraction_log" ]]; then
        log_error "Triage report not found: ${extraction_log}"
        log_error "Run run-triage.sh first"
        return 1
    fi

    log_info "Syncing action items from triage report..."

    # Extract action items (lines starting with - [ ] in Action Required section)
    local action_items
    action_items=$(sed -n '/## Action Required/,/^## /p' "$extraction_log" | \
        grep '^\- \[ \]' | \
        sed 's/^- \[ \] //' | \
        sed 's/\*\*//g')

    if [[ -z "$action_items" ]]; then
        log_info "No action items found to sync"
        return 0
    fi

    local sync_count=0
    local skip_count=0

    # Initialize log file
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "# Tasks Sync Log - $(date)" > "$LOG_FILE"
    echo "" >> "$LOG_FILE"

    while IFS= read -r item; do
        [[ -z "$item" ]] && continue

        # Extract subject from the item
        local title
        title=$(echo "$item" | cut -d'(' -f1 | xargs)

        if [[ -z "$title" ]]; then
            continue
        fi

        # Check if similar task already exists
        local existing
        existing=$(gws tasks tasks list \
            --tasklist "$DEFAULT_TASKLIST" \
            --format json 2>/dev/null | \
            jq -r --arg title "$title" '.[] | select(.title | test($title; "i")) | .id' | head -1)

        if [[ -n "$existing" ]]; then
            log_info "Task already exists: ${title}"
            echo "- [SKIP] ${title} (already exists: ${existing})" >> "$LOG_FILE"
            ((skip_count++))
            continue
        fi

        # Create the task
        log_info "Creating task: ${title}"

        local notes="Synced from triage report"
        local message_id
        message_id=$(echo "$item" | grep -oE 'ID: [a-f0-9]+' | cut -d' ' -f2 || true)

        if [[ -n "$message_id" ]]; then
            notes="Source: Email ${message_id}\nLink: https://mail.google.com/mail/u/0/#inbox/${message_id}"
        fi

        local task_json
        task_json=$(jq -n \
            --arg title "$title" \
            --arg notes "$notes" \
            '{title: $title, notes: $notes}')

        local result
        result=$(gws tasks tasks insert \
            --tasklist "$DEFAULT_TASKLIST" \
            --json "$task_json" 2>/dev/null)

        if [[ $? -eq 0 ]]; then
            local task_id
            task_id=$(echo "$result" | jq -r '.id')
            echo "- [SYNCED] ${title} (Task ID: ${task_id})" >> "$LOG_FILE"
            ((sync_count++))
        else
            echo "- [FAILED] ${title}" >> "$LOG_FILE"
        fi

    done <<< "$action_items"

    echo ""
    echo "Sync complete: ${sync_count} synced, ${skip_count} skipped"
    echo "Log: ${LOG_FILE}"
}

# =============================================================================
# Quick Task Creation from Email
# =============================================================================

# Create task from an email message
cmd_from_email() {
    local message_id="${1:-}"
    local tasklist_id="${2:-$DEFAULT_TASKLIST}"

    if [[ -z "$message_id" ]]; then
        log_error "Message ID is required"
        echo "Usage: $0 from-email <message_id> [tasklist_id]"
        return 1
    fi

    log_info "Creating task from email: ${message_id}"

    # Get email details
    local email_json
    email_json=$(gws gmail users messages get \
        --params "{\"userId\":\"me\",\"id\":\"${message_id}\"}" \
        --format json 2>/dev/null)

    if [[ -z "$email_json" ]]; then
        log_error "Failed to fetch email ${message_id}"
        return 1
    fi

    # Extract subject and sender
    local subject from
    subject=$(echo "$email_json" | jq -r '.payload.headers[] | select(.name == "Subject") | .value // "Email Task"')
    from=$(echo "$email_json" | jq -r '.payload.headers[] | select(.name == "From") | .value // "Unknown"')

    # Create task
    local title="Follow up: ${subject}"
    local notes="Source: Email from ${from}\nMessage ID: ${message_id}\nLink: https://mail.google.com/mail/u/0/#inbox/${message_id}"

    cmd_create "$title" "$tasklist_id" "$notes"
}

# =============================================================================
# Agenda View
# =============================================================================

# Show today's tasks in agenda format
cmd_agenda() {
    local date="${1:-$(date '+%Y-%m-%d')}"

    log_info "Generating task agenda for ${date}"

    local tasks_json
    tasks_json=$(gws tasks tasks list \
        --tasklist "$DEFAULT_TASKLIST" \
        --max-results 50 \
        --format json 2>/dev/null)

    if [[ -z "$tasks_json" || "$tasks_json" == "[]" ]]; then
        echo "No tasks found"
        return 0
    fi

    echo ""
    echo "Task Agenda - ${date}"
    echo "===================="

    # Group by due date
    local overdue today upcoming no_due

    overdue=$(echo "$tasks_json" | jq -r --arg today "$date" \
        '.[] | select(.due != null and .due < $today and .status != "completed") | "- \(.title)"')

    today=$(echo "$tasks_json" | jq -r --arg today "$date" \
        '.[] | select(.due != null and .due == $today and .status != "completed") | "- \(.title)"')

    upcoming=$(echo "$tasks_json" | jq -r --arg today "$date" \
        '.[] | select(.due != null and .due > $today and .status != "completed") | "- \(.title) (due: \(.due))"')

    no_due=$(echo "$tasks_json" | jq -r \
        '.[] | select(.due == null and .status != "completed") | "- \(.title)"')

    if [[ -n "$overdue" ]]; then
        echo ""
        echo "OVERDUE:"
        echo "$overdue"
    fi

    if [[ -n "$today" ]]; then
        echo ""
        echo "DUE TODAY:"
        echo "$today"
    fi

    if [[ -n "$upcoming" ]]; then
        echo ""
        echo "UPCOMING:"
        echo "$upcoming" | head -10
    fi

    if [[ -n "$no_due" ]]; then
        echo ""
        echo "NO DUE DATE:"
        echo "$no_due" | head -10
    fi
}

# =============================================================================
# Main Entry Point
# =============================================================================

usage() {
    cat << EOF
Google Tasks Manager

Usage: $0 <command> [arguments]

Commands:
  list [tasklist_id]              List tasks (default: @default)
  tasklists                       List all task lists
  create <title> [list] [notes]   Create a new task
  complete <task_id> [list]       Mark task as complete
  delete <task_id> [list]         Delete a task
  sync                            Sync action items from triage report
  from-email <message_id> [list]  Create task from email
  agenda [date]                   Show task agenda for a date

Examples:
  $0 list                          # List all tasks
  $0 tasklists                     # List all task lists
  $0 create "Review document"      # Create a task
  $0 complete 12345                # Mark task 12345 complete
  $0 sync                          # Sync from triage report
  $0 agenda                        # Show today's task agenda
EOF
}

main() {
    check_dependencies

    local command="${1:-}"
    shift || true

    case "$command" in
        list)
            cmd_list "$@"
            ;;
        tasklists)
            cmd_tasklists "$@"
            ;;
        create)
            cmd_create "$@"
            ;;
        complete)
            cmd_complete "$@"
            ;;
        delete)
            cmd_delete "$@"
            ;;
        sync)
            cmd_sync "$@"
            ;;
        from-email)
            cmd_from_email "$@"
            ;;
        agenda)
            cmd_agenda "$@"
            ;;
        -h|--help|help)
            usage
            ;;
        *)
            log_error "Unknown command: ${command}"
            usage
            exit 1
            ;;
    esac
}

# Run main
main "$@"

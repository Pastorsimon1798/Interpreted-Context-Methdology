#!/bin/bash
#
# run-tasks.sh - Simple Google Tasks access via GWS-CLI
#
# This script is a thin wrapper around gws tasks commands.
# The AI agent does the intelligence work (prioritization, deadline decisions).
# Scripts just make the API calls.
#
# Note: Tasks API has no +helper commands. We use raw API.
#
# Usage:
#   ./run-tasks.sh list [tasklist_id]       - List tasks (default: @default)
#   ./run-tasks.sh tasklists                 - List all task lists
#   ./run-tasks.sh create <title> [notes]    - Create a new task
#   ./run-tasks.sh complete <task_id>        - Mark task complete
#   ./run-tasks.sh agenda [date]             - Show tasks grouped by due date
#
# GWS Tasks API Reference:
#   gws tasks tasklists list --params '{"maxResults":100}'
#   gws tasks tasks list --params '{"tasklist":"@default","maxResults":100}'
#   gws tasks tasks insert --params '{"tasklist":"@default"}' --json '{"title":"..."}'
#
# The AI agent should:
# 1. Call list to see current tasks
# 2. Analyze and prioritize using its intelligence
# 3. Create/complete tasks as needed
#

set -euo pipefail

# Filter out "Using keyring" messages from gws output
filter_gws_output() {
    grep -v "^Using keyring" || true
}

# List all task lists
cmd_tasklists() {
    gws tasks tasklists list --params '{"maxResults":100}' --format json 2>&1 | filter_gws_output
}

# List tasks in a task list
cmd_list() {
    local tasklist_id="${1:-@default}"
    gws tasks tasks list --params "{\"tasklist\":\"${tasklist_id}\",\"maxResults\":100}" --format json 2>&1 | filter_gws_output
}

# Create a new task
cmd_create() {
    local title="${1:-}"
    local notes="${2:-}"
    local tasklist_id="${3:-@default}"

    if [[ -z "$title" ]]; then
        echo '{"error": "Task title is required"}' >&2
        return 1
    fi

    # Build task JSON
    local task_json
    if [[ -n "$notes" ]]; then
        task_json=$(jq -n --arg title "$title" --arg notes "$notes" \
            '{title: $title, notes: $notes}')
    else
        task_json=$(jq -n --arg title "$title" '{title: $title}')
    fi

    gws tasks tasks insert --params "{\"tasklist\":\"${tasklist_id}\"}" --json "$task_json" --format json 2>&1 | filter_gws_output
}

# Mark a task as complete
cmd_complete() {
    local task_id="${1:-}"
    local tasklist_id="${2:-@default}"

    if [[ -z "$task_id" ]]; then
        echo '{"error": "Task ID is required"}' >&2
        return 1
    fi

    local task_json='{"status": "completed"}'

    gws tasks tasks update --params "{\"tasklist\":\"${tasklist_id}\",\"task\":\"${task_id}\"}" --json "$task_json" --format json 2>&1 | filter_gws_output
}

# Delete a task
cmd_delete() {
    local task_id="${1:-}"
    local tasklist_id="${2:-@default}"

    if [[ -z "$task_id" ]]; then
        echo '{"error": "Task ID is required"}' >&2
        return 1
    fi

    gws tasks tasks delete --params "{\"tasklist\":\"${tasklist_id}\",\"task\":\"${task_id}\"}" 2>&1 | filter_gws_output
}

# Show tasks grouped by due date (agenda view)
# Returns JSON for AI to process
cmd_agenda() {
    local date="${1:-$(date '+%Y-%m-%d')}"

    # Get tasks and let AI categorize them
    gws tasks tasks list --params '{"tasklist":"@default","maxResults":100}" --format json 2>&1 | filter_gws_output
}

usage() {
    cat << 'EOF'
Usage: run-tasks.sh <command> [arguments]

Commands:
  list [tasklist_id]              List tasks (default: @default)
  tasklists                       List all task lists
  create <title> [notes] [list]   Create a new task
  complete <task_id> [list]       Mark task complete
  delete <task_id> [list]         Delete a task
  agenda [date]                   Show task agenda (returns JSON for AI)

Examples:
  ./run-tasks.sh list                          # List all tasks
  ./run-tasks.sh tasklists                      # List all task lists
  ./run-tasks.sh create "Review document"       # Create a task
  ./run-tasks.sh complete "task_id_here"        # Mark task complete
  ./run-tasks.sh agenda                         # Show task agenda

Output is JSON. The AI agent interprets and acts on this data.
EOF
}

main() {
    local command="${1:-}"

    case "$command" in
        list)
            shift
            cmd_list "$@"
            ;;
        tasklists)
            cmd_tasklists
            ;;
        create)
            shift
            cmd_create "$@"
            ;;
        complete)
            shift
            cmd_complete "$@"
            ;;
        delete)
            shift
            cmd_delete "$@"
            ;;
        agenda)
            shift
            cmd_agenda "$@"
            ;;
        -h|--help|help)
            usage
            ;;
        *)
            # Default to list if no command
            if [[ -z "$command" ]]; then
                cmd_list
            else
                echo '{"error": "Unknown command: '"$command"'"}' >&2
                usage >&2
                exit 1
            fi
            ;;
    esac
}

main "$@"

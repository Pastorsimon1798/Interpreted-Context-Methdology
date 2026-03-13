#!/bin/bash
#
# run-calendar.sh - Simple calendar access using GWS-CLI helpers
#
# This script is a thin wrapper around gws calendar commands.
# The AI agent does the intelligence work (categorization, scheduling decisions).
# Scripts just make the API calls.
#
# Usage:
#   ./run-calendar.sh agenda [date]              - Show agenda for date
#   ./run-calendar.sh week                       - Show this week's agenda
#   ./run-calendar.sh insert <summary> [date] [time] [duration]  - Create event
#   ./run-calendar.sh freebusy [date]            - Check free/busy
#
# GWS-CLI +helpers are designed FOR AI agents. Use them directly:
#   gws calendar +agenda --today --format json
#   gws calendar +agenda --week --format json
#   gws calendar +insert --summary "Meeting" --start "2026-03-12T14:00:00"
#

set -euo pipefail

# Filter out "Using keyring" noise from gws output
filter_gws_output() {
    grep -v "^Using keyring" || true
}

# Show daily agenda using +agenda helper
cmd_agenda() {
    local date="${1:-}"
    local args=("+agenda" "--format" "json")

    if [[ -n "$date" ]]; then
        args+=("--date" "$date")
    else
        args+=("--today")
    fi

    gws calendar "${args[@]}" 2>/dev/null | filter_gws_output
}

# Show weekly agenda
cmd_week() {
    gws calendar +agenda --week --format json 2>/dev/null | filter_gws_output
}

# Insert event using +insert helper
cmd_insert() {
    local summary="${1:-}"
    local date="${2:-$(date '+%Y-%m-%d')}"
    local time="${3:-}"
    local duration="${4:-60}"

    if [[ -z "$summary" ]]; then
        echo "Error: Event summary required" >&2
        echo "Usage: $0 insert <summary> [date] [time] [duration]" >&2
        return 1
    fi

    # If no time specified, let +insert find a slot
    if [[ -n "$time" ]]; then
        local start_time="${date}T${time}:00"
        gws calendar +insert --summary "$summary" --start "$start_time" --duration "$duration" 2>/dev/null | filter_gws_output
    else
        # Let GWS find next available slot
        gws calendar +insert --summary "$summary" --date "$date" --duration "$duration" 2>/dev/null | filter_gws_output
    fi
}

# Check free/busy
cmd_freebusy() {
    local date="${1:-$(date '+%Y-%m-%d')}"
    local time_min="${date}T00:00:00Z"
    local time_max="${date}T23:59:59Z"

    gws calendar freebusy \
        --json "{\"items\": [{\"id\": \"primary\"}], \"timeMin\": \"${time_min}\", \"timeMax\": \"${time_max}\"}" \
        --format json 2>/dev/null | filter_gws_output
}

# Usage help
usage() {
    cat << EOF
Calendar access via GWS-CLI helpers

Usage: $0 <command> [options]

Commands:
  agenda [date]                           Show daily agenda (default: today)
  week                                    Show weekly agenda
  insert <summary> [date] [time] [dur]    Create event (smart scheduling if no time)
  freebusy [date]                         Check free/busy times

Examples:
  $0 agenda                              # Today's agenda as JSON
  $0 agenda 2026-03-15                   # Specific date
  $0 week                                # This week
  $0 insert "Team meeting"               # Auto-schedule meeting
  $0 insert "Focus time" 2026-03-12 14:00  # Specific time
  $0 freebusy                            # Today's availability

Note: Output is JSON. The AI agent interprets and acts on the data.
EOF
}

# Main entry point
main() {
    local command="${1:-}"

    case "$command" in
        agenda)
            shift
            cmd_agenda "$@"
            ;;
        week)
            cmd_week
            ;;
        insert)
            shift
            cmd_insert "$@"
            ;;
        freebusy|busy)
            shift
            cmd_freebusy "$@"
            ;;
        -h|--help|help)
            usage
            ;;
        *)
            # Default to agenda if no command
            if [[ -z "$command" ]]; then
                cmd_agenda
            else
                echo "Unknown command: $command" >&2
                usage
                exit 1
            fi
            ;;
    esac
}

main "$@"

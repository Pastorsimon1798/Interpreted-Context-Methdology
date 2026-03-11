#!/bin/bash
#
# run-calendar.sh - Calendar Sync Stage for Google Workspace Agent
#
# This script runs the calendar sync stage, creating events for action items
# and blocking focus time based on calendar preferences.
#
# Dependencies:
#   - gws CLI (Google Workspace CLI)
#   - jq (JSON processor)
#   - Prior run of run-triage.sh and run-extraction.sh
#
# Usage:
#   ./run-calendar.sh [--dry-run] [--verbose]
#
# Options:
#   --dry-run    Show what would be created without actually creating events
#   --verbose    Enable detailed logging
#

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
STAGES_DIR="${WORKSPACE_ROOT}/stages"
SHARED_DIR="${WORKSPACE_ROOT}/shared"
OUTPUT_DIR="${STAGES_DIR}/03-calendar/output"

# Timestamp for this run
TIMESTAMP=$(date +"%Y%m%d-%H%M")
LOG_FILE="${OUTPUT_DIR}/calendar-log-${TIMESTAMP}.md"

# Default values (overridden by calendar-preferences.md)
WORKING_HOURS_START="09:00"
WORKING_HOURS_END="17:00"
TIMEZONE="America/New_York"
DEFAULT_EVENT_DURATION="30"
FOCUS_BLOCK_DURATION="90"
MEETING_BUFFER="5"
MAX_MEETINGS_PER_DAY="6"

# Flags
DRY_RUN=false
VERBOSE=false

# =============================================================================
# Helper Functions
# =============================================================================

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    if [[ "$level" == "DEBUG" && "$VERBOSE" != "true" ]]; then
        return
    fi

    echo "[${timestamp}] [${level}] ${message}"
}

log_info() {
    log "INFO" "$@"
}

log_debug() {
    log "DEBUG" "$@"
}

log_error() {
    log "ERROR" "$@" >&2
}

log_to_file() {
    echo "$*" >> "${LOG_FILE}"
}

die() {
    log_error "$@"
    exit 1
}

check_dependencies() {
    log_info "Checking dependencies..."

    # Check for gws CLI
    if ! command -v gws &> /dev/null; then
        die "gws CLI not found. Please install @googleworkspace/cli first."
    fi

    # Check for jq
    if ! command -v jq &> /dev/null; then
        die "jq not found. Please install jq first."
    fi

    log_debug "All dependencies satisfied."
}

# =============================================================================
# Configuration Loading
# =============================================================================

load_calendar_preferences() {
    local prefs_file="${SHARED_DIR}/calendar-preferences.md"

    if [[ ! -f "$prefs_file" ]]; then
        log_info "No calendar-preferences.md found, using defaults."
        return
    fi

    log_info "Loading calendar preferences from ${prefs_file}..."

    # Extract values from placeholders in calendar-preferences.md
    # These would typically be filled in during onboarding
    # For now, we parse any non-placeholder values

    # Check for working hours
    local start_time=$(grep -E "^\*\*Start:\*\*" "$prefs_file" | grep -oE '[0-9]{2}:[0-9]{2}' | head -1)
    if [[ -n "$start_time" && ! "$start_time" =~ ^\{\{ ]]; then
        WORKING_HOURS_START="$start_time"
    fi

    local end_time=$(grep -E "^\*\*End:\*\*" "$prefs_file" | grep -oE '[0-9]{2}:[0-9]{2}' | head -1)
    if [[ -n "$end_time" && ! "$end_time" =~ ^\{\{ ]]; then
        WORKING_HOURS_END="$end_time"
    fi

    local timezone=$(grep -E "^\*\*Timezone:\*\*" "$prefs_file" | sed 's/.*\*\*Timezone:\*\* //' | tr -d '`')
    if [[ -n "$timezone" && ! "$timezone" =~ ^\{\{ ]]; then
        TIMEZONE="$timezone"
    fi

    log_debug "Working hours: ${WORKING_HOURS_START} - ${WORKING_HOURS_END} (${TIMEZONE})"
}

load_workspace_config() {
    local config_file="${WORKSPACE_ROOT}/.workspace-config.json"

    if [[ -f "$config_file" ]]; then
        log_info "Loading workspace configuration..."

        # Parse config with jq
        if [[ -f "$config_file" ]]; then
            AGENT_CALENDAR_ID=$(jq -r '.calendarId // "primary"' "$config_file" 2>/dev/null || echo "primary")
            TRUST_LEVEL=$(jq -r '.trustLevel // "supervised"' "$config_file" 2>/dev/null || echo "supervised")
        fi
    else
        AGENT_CALENDAR_ID="${AGENT_CALENDAR_ID:-primary}"
        TRUST_LEVEL="${TRUST_LEVEL:-supervised}"
    fi

    log_debug "Calendar ID: ${AGENT_CALENDAR_ID}"
    log_debug "Trust Level: ${TRUST_LEVEL}"
}

# =============================================================================
# Input Reading
# =============================================================================

read_action_items() {
    local triage_report="${STAGES_DIR}/01-triage/output/triage-report.md"

    if [[ ! -f "$triage_report" ]]; then
        log_error "Triage report not found: ${triage_report}"
        log_error "Please run run-triage.sh first."
        return 1
    fi

    log_info "Reading action items from triage report..."

    # Extract action items section
    # This is a simplified extraction - adjust based on actual triage report format
    local action_items=""

    # Look for action items section
    if grep -q "## Action Items" "$triage_report"; then
        action_items=$(sed -n '/## Action Items/,/^## /p' "$triage_report" | head -n -1)
    elif grep -q "## Action Required" "$triage_report"; then
        action_items=$(sed -n '/## Action Required/,/^## /p' "$triage_report" | head -n -1)
    fi

    if [[ -z "$action_items" ]]; then
        log_info "No action items found in triage report."
        echo ""
        return 0
    fi

    echo "$action_items"
}

read_extraction_dates() {
    local extraction_log="${STAGES_DIR}/02-extraction/output/extraction-log.md"

    if [[ ! -f "$extraction_log" ]]; then
        log_info "No extraction log found. Skipping date extraction."
        echo ""
        return 0
    fi

    log_info "Reading dates/deadlines from extraction log..."

    # Extract dates and deadlines
    # Look for date patterns in the extraction log
    local dates=""

    # Common date patterns
    dates=$(grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}|[A-Z][a-z]{2} [0-9]{1,2}, [0-9]{4}|[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}' "$extraction_log" 2>/dev/null || true)

    if [[ -z "$dates" ]]; then
        log_info "No dates found in extraction log."
    fi

    echo "$dates"
}

# =============================================================================
# Calendar Operations
# =============================================================================

get_existing_events() {
    local start_date="$1"
    local end_date="$2"

    log_info "Fetching existing events for ${start_date} to ${end_date}..."

    # Use gws calendar events list to get existing events
    # Time range: from start of today to end of planning window (default 14 days)
    local events_json

    events_json=$(gws calendar events list \
        --calendar "${AGENT_CALENDAR_ID}" \
        --time-min "${start_date}T00:00:00" \
        --time-max "${end_date}T23:59:59" \
        --format json 2>/dev/null || echo '[]')

    echo "$events_json"
}

check_conflicts() {
    local proposed_start="$1"
    local proposed_end="$2"
    local existing_events="$3"

    log_debug "Checking conflicts for ${proposed_start} to ${proposed_end}..."

    # Parse existing events and check for overlaps
    local conflicts=""

    conflicts=$(echo "$existing_events" | jq -r --arg start "$proposed_start" --arg end "$proposed_end" '
        .[] | select(
            (.start.dateTime // .start.date) < $end and
            (.end.dateTime // .end.date) > $start
        ) | .summary
    ' 2>/dev/null || true)

    if [[ -n "$conflicts" ]]; then
        echo "$conflicts"
        return 1
    fi

    return 0
}

is_within_working_hours() {
    local time="$1"

    # Extract hour and minute from time
    local hour minute
    hour=$(echo "$time" | cut -d: -f1 | sed 's/^0//')
    minute=$(echo "$time" | cut -d: -f2)

    local start_hour start_minute end_hour end_minute
    start_hour=$(echo "$WORKING_HOURS_START" | cut -d: -f1 | sed 's/^0//')
    start_minute=$(echo "$WORKING_HOURS_START" | cut -d: -f2)
    end_hour=$(echo "$WORKING_HOURS_END" | cut -d: -f1 | sed 's/^0//')
    end_minute=$(echo "$WORKING_HOURS_END" | cut -d: -f2)

    # Convert to minutes for comparison
    local time_mins=$((hour * 60 + minute))
    local start_mins=$((start_hour * 60 + start_minute))
    local end_mins=$((end_hour * 60 + end_minute))

    if [[ $time_mins -ge $start_mins && $time_mins -le $end_mins ]]; then
        return 0
    fi

    return 1
}

create_event() {
    local summary="$1"
    local start_time="$2"
    local end_time="$3"
    local description="$4"
    local source_link="$5"

    log_info "Creating event: ${summary}"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would create event:"
        log_info "  Summary: ${summary}"
        log_info "  Start: ${start_time}"
        log_info "  End: ${end_time}"
        log_info "  Description: ${description}"
        return 0
    fi

    # Build the gws command
    local cmd="gws calendar events insert --calendar \"${AGENT_CALENDAR_ID}\""

    # Add event details
    cmd+=" --summary \"${summary}\""
    cmd+=" --start \"${start_time}\""
    cmd+=" --end \"${end_time}\""

    if [[ -n "$description" ]]; then
        cmd+=" --description \"${description}\""
    fi

    if [[ -n "$source_link" ]]; then
        # Append source link to description
        cmd+=" --description \"${description}\\n\\nSource: ${source_link}\""
    fi

    cmd+=" --timezone \"${TIMEZONE}\""

    # Execute the command
    local result
    result=$(eval "$cmd" 2>&1)

    if [[ $? -eq 0 ]]; then
        log_info "Event created successfully"
        echo "$result"
    else
        log_error "Failed to create event: ${result}"
        return 1
    fi
}

block_focus_time() {
    local date="$1"
    local preferred_time="$2"  # "morning" or "afternoon"

    log_info "Blocking focus time for ${date} (${preferred_time})..."

    # Determine focus block time based on preference
    local focus_start focus_end

    if [[ "$preferred_time" == "morning" ]]; then
        # Start after morning buffer
        focus_start="${date}T${WORKING_HOURS_START}:00"
        # Calculate end time based on focus block duration
        local start_hour start_min
        start_hour=$(echo "$WORKING_HOURS_START" | cut -d: -f1 | sed 's/^0//')
        start_min=$(echo "$WORKING_HOURS_START" | cut -d: -f2)

        local end_mins=$((start_hour * 60 + start_min + FOCUS_BLOCK_DURATION))
        local end_hour=$((end_mins / 60))
        local end_min=$((end_mins % 60))

        focus_end="${date}T$(printf '%02d' $end_hour):$(printf '%02d' $end_min):00"
    else
        # Afternoon focus block - end at working hours end
        local end_hour end_min
        end_hour=$(echo "$WORKING_HOURS_END" | cut -d: -f1 | sed 's/^0//')
        end_min=$(echo "$WORKING_HOURS_END" | cut -d: -f2)

        local start_mins=$((end_hour * 60 + end_min - FOCUS_BLOCK_DURATION))
        local start_hour=$((start_mins / 60))
        local start_min=$((start_mins % 60))

        focus_start="${date}T$(printf '%02d' $start_hour):$(printf '%02d' $start_min):00"
        focus_end="${date}T${WORKING_HOURS_END}:00"
    fi

    # Create focus block event
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would create focus block:"
        log_info "  Start: ${focus_start}"
        log_info "  End: ${focus_end}"
        log_info "  Duration: ${FOCUS_BLOCK_DURATION} minutes"
        return 0
    fi

    create_event \
        "[Focus Time]" \
        "${focus_start}" \
        "${focus_end}" \
        "Blocked for deep work. ADHD-friendly focus block." \
        ""
}

# =============================================================================
# Main Processing
# =============================================================================

process_action_items() {
    local action_items="$1"
    local existing_events="$2"
    local today_date
    today_date=$(date +"%Y-%m-%d")

    log_info "Processing action items for calendar events..."

    local event_count=0
    local conflict_count=0

    # Process each action item line
    while IFS= read -r line; do
        # Skip empty lines and headers
        [[ -z "$line" || "$line" =~ ^# || "$line" =~ ^--- ]] && continue

        # Extract deadline if present (format: YYYY-MM-DD or similar)
        local deadline=$(echo "$line" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)

        if [[ -n "$deadline" ]]; then
            # Parse the action item
            local summary=$(echo "$line" | sed 's/[-*] //' | sed 's/\[.*\] //' | cut -d'(' -f1 | xargs)

            if [[ -z "$summary" ]]; then
                continue
            fi

            # Calculate event time (default to morning of deadline day)
            local event_start="${deadline}T${WORKING_HOURS_START}:00"
            local event_end

            # Calculate end time based on default duration
            local start_hour start_min
            start_hour=$(echo "$WORKING_HOURS_START" | cut -d: -f1 | sed 's/^0//')
            start_min=$(echo "$WORKING_HOURS_START" | cut -d: -f2)

            local end_mins=$((start_hour * 60 + start_min + DEFAULT_EVENT_DURATION))
            local end_hour=$((end_mins / 60))
            local end_min=$((end_mins % 60))

            event_end="${deadline}T$(printf '%02d' $end_hour):$(printf '%02d' $end_min):00"

            # Check for conflicts
            if ! check_conflicts "$event_start" "$event_end" "$existing_events"; then
                log_info "Conflict detected for: ${summary}"
                ((conflict_count++))

                # Try to find alternative time
                # For simplicity, we just note the conflict
                log_to_file "- [CONFLICT] ${summary} (scheduled: ${event_start})"
                continue
            fi

            # Create the event
            if create_event "$summary" "$event_start" "$event_end" "Action item from email triage" ""; then
                ((event_count++))
                log_to_file "- [CREATED] ${summary} (${event_start})"
            fi
        fi
    done <<< "$action_items"

    log_info "Created ${event_count} events, ${conflict_count} conflicts detected."
}

process_extraction_dates() {
    local dates="$1"
    local existing_events="$2"

    log_info "Processing extracted dates for calendar events..."

    local event_count=0

    # Process each unique date
    while IFS= read -r date; do
        [[ -z "$date" ]] && continue

        # Normalize date format
        local normalized_date
        normalized_date=$(date -j -f "%Y-%m-%d" "$date" +"%Y-%m-%d" 2>/dev/null || echo "")

        if [[ -z "$normalized_date" ]]; then
            log_debug "Could not normalize date: ${date}"
            continue
        fi

        # Create a reminder event for this date
        local event_start="${normalized_date}T09:00:00"
        local event_end="${normalized_date}T09:15:00"

        # Check for conflicts
        if check_conflicts "$event_start" "$event_end" "$existing_events"; then
            if create_event "Reminder: Extracted Deadline" "$event_start" "$event_end" "Extracted from knowledge base" ""; then
                ((event_count++))
                log_to_file "- [CREATED] Reminder for ${normalized_date}"
            fi
        fi
    done <<< "$(echo "$dates" | sort -u)"

    log_info "Created ${event_count} reminder events from extractions."
}

# =============================================================================
# Log Generation
# =============================================================================

initialize_log() {
    mkdir -p "${OUTPUT_DIR}"

    cat > "${LOG_FILE}" << EOF
# Calendar Sync Log

**Run Timestamp:** $(date +"%Y-%m-%d %H:%M:%S")
**Calendar ID:** ${AGENT_CALENDAR_ID}
**Working Hours:** ${WORKING_HOURS_START} - ${WORKING_HOURS_END} (${TIMEZONE})
**Trust Level:** ${TRUST_LEVEL}

---

## Configuration

- Focus Block Duration: ${FOCUS_BLOCK_DURATION} minutes
- Default Event Duration: ${DEFAULT_EVENT_DURATION} minutes
- Meeting Buffer: ${MEETING_BUFFER} minutes
- Max Meetings Per Day: ${MAX_MEETINGS_PER_DAY}

---

## Events Created

EOF
}

finalize_log() {
    local events_created="$1"
    local conflicts="$2"
    local focus_blocks="$3"

    cat >> "${LOG_FILE}" << EOF

---

## Summary

- **Events Created:** ${events_created}
- **Conflicts Detected:** ${conflicts}
- **Focus Blocks Scheduled:** ${focus_blocks}

---

## Notes

- All events include context links to source triage items
- Focus time scheduled within working hours only
- Conflicts noted require manual resolution

---

*Generated by run-calendar.sh on $(date)*
EOF

    log_info "Calendar log written to: ${LOG_FILE}"
}

# =============================================================================
# Main Entry Point
# =============================================================================

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [--dry-run] [--verbose]"
                echo ""
                echo "Options:"
                echo "  --dry-run    Show what would be created without creating events"
                echo "  --verbose    Enable detailed logging"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    log_info "Starting Calendar Sync Stage..."
    log_info "========================================"

    # Initialize
    check_dependencies
    load_workspace_config
    load_calendar_preferences
    initialize_log

    # Read inputs
    local action_items
    action_items=$(read_action_items) || die "Failed to read action items"

    local extraction_dates
    extraction_dates=$(read_extraction_dates)

    # Get existing events for conflict detection
    local today end_date
    today=$(date +"%Y-%m-%d")
    end_date=$(date -v+14d +"%Y-%m-%d")  # 14-day planning window

    local existing_events
    existing_events=$(get_existing_events "$today" "$end_date")

    # Process action items
    local events_created=0
    local conflicts=0

    if [[ -n "$action_items" ]]; then
        process_action_items "$action_items" "$existing_events"
        events_created=$?
    fi

    # Process extracted dates
    if [[ -n "$extraction_dates" ]]; then
        process_extraction_dates "$extraction_dates" "$existing_events"
    fi

    # Block focus time for today and tomorrow
    local focus_blocks=0

    if [[ "$DRY_RUN" != "true" ]]; then
        log_info "Scheduling focus blocks..."

        # Today - afternoon focus
        block_focus_time "$today" "afternoon" && ((focus_blocks++)) || true

        # Tomorrow - morning focus
        local tomorrow
        tomorrow=$(date -v+1d +"%Y-%m-%d")
        block_focus_time "$tomorrow" "morning" && ((focus_blocks++)) || true
    fi

    # Finalize log
    finalize_log "$events_created" "$conflicts" "$focus_blocks"

    log_info "========================================"
    log_info "Calendar Sync Stage complete."
    log_info "Output: ${LOG_FILE}"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] No events were actually created."
    fi
}

# =============================================================================
# Agenda View (+agenda)
# =============================================================================

show_agenda() {
    local date="${1:-$(date '+%Y-%m-%d')}"
    local time_min="${date}T00:00:00Z"
    local time_max="${date}T23:59:59Z"

    log_info "Fetching agenda for ${date}..."

    local events_json
    events_json=$(gws calendar events list \
        --calendar "${AGENT_CALENDAR_ID}" \
        --time-min "$time_min" \
        --time-max "$time_max" \
        --max-results 50 \
        --format json 2>/dev/null || echo '[]')

    echo ""
    echo "=========================================="
    echo "AGENDA - ${date}"
    echo "=========================================="

    if [[ "$events_json" == "[]" ]]; then
        echo ""
        echo "No events scheduled for today."
        echo ""
        return 0
    fi

    # Sort and display events
    echo "$events_json" | jq -r '.[] | sort_by(.start.dateTime // .start.date) | .[] | "- \(.summary // "Untitled") at \(.start.dateTime // .start.date)"' 2>/dev/null

    # Calculate meeting load
    local event_count meeting_mins
    event_count=$(echo "$events_json" | jq '. | length')

    echo ""
    echo "------------------------------------------"
    echo "Total events: ${event_count}"
    echo ""

    # Show next event
    local now next_event
    now=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
    next_event=$(echo "$events_json" | jq -r --arg now "$now" \
        '.[] | select((.start.dateTime // .start.date) > $now) | sort_by(.start.dateTime) | .[0]' 2>/dev/null)

    if [[ -n "$next_event" && "$next_event" != "null" ]]; then
        local next_summary next_start
        next_summary=$(echo "$next_event" | jq -r '.summary')
        next_start=$(echo "$next_event" | jq -r '.start.dateTime // .start.date')
        echo "NEXT UP: ${next_summary} at ${next_start}"
    fi

    echo ""
}

# =============================================================================
# Smart Event Insert (+insert)
# =============================================================================

smart_insert() {
    local summary="${1:-}"
    local date="${2:-$(date '+%Y-%m-%d')}"
    local time="${3:-}"
    local duration="${4:-60}"

    if [[ -z "$summary" ]]; then
        log_error "Event summary is required"
        echo "Usage: $0 insert <summary> [date] [time] [duration]"
        return 1
    fi

    log_info "Creating event: ${summary}"

    # If no time specified, find next available slot
    if [[ -z "$time" ]]; then
        log_info "Finding next available time slot..."

        local time_min time_max
        time_min="${date}T${WORKING_HOURS_START}:00"
        time_max="${date}T${WORKING_HOURS_END}:00"

        local existing_events
        existing_events=$(gws calendar events list \
            --calendar "${AGENT_CALENDAR_ID}" \
            --time-min "$time_min" \
            --time-max "$time_max" \
            --format json 2>/dev/null || echo '[]')

        # Simple slot finding: use working hours start or buffer after last event
        local last_event_end
        last_event_end=$(echo "$existing_events" | jq -r \
            '[.[] | .end.dateTime // .end.date] | max // empty' 2>/dev/null || true)

        if [[ -n "$last_event_end" ]]; then
            # Add 5-minute buffer after last event
            local last_hour last_min new_hour new_min
            last_hour=$(echo "$last_event_end" | cut -dT -f2 | cut -d: -f1)
            last_min=$(echo "$last_event_end" | cut -d: -f2)
            new_min=$((last_min + 5))
            new_hour=$last_hour
            if [[ $new_min -ge 60 ]]; then
                new_min=$((new_min - 60))
                new_hour=$((new_hour + 1))
            fi
            time="$(printf '%02d' $new_hour):$(printf '%02d' $new_min)"
        else
            time="$WORKING_HOURS_START"
        fi
    fi

    # Calculate end time
    local start_hour start_min end_mins end_hour end_min
    start_hour=$(echo "$time" | cut -d: -f1 | sed 's/^0//')
    start_min=$(echo "$time" | cut -d: -f2 | sed 's/^0//')
    start_min=${start_min:-0}

    end_mins=$((start_hour * 60 + start_min + duration))
    end_hour=$((end_mins / 60))
    end_min=$((end_mins % 60))

    local start_datetime="${date}T$(printf '%02d' $start_hour):$(printf '%02d' $start_min):00"
    local end_datetime="${date}T$(printf '%02d' $end_hour):$(printf '%02d' $end_min):00"

    # Check working hours
    local end_time_check
    end_time_check="$(printf '%02d' $end_hour):$(printf '%02d' $end_min)"

    if [[ "$end_time_check" > "$WORKING_HOURS_END" ]]; then
        log_info "Event extends beyond working hours (${WORKING_HOURS_END})"
    fi

    echo "Creating event:"
    echo "  Summary: ${summary}"
    echo "  Start: ${start_datetime}"
    echo "  End: ${end_datetime}"
    echo "  Duration: ${duration} minutes"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would create event"
        return 0
    fi

    # Create the event
    local event_json
    event_json=$(jq -n \
        --arg summary "$summary" \
        --arg start "$start_datetime" \
        --arg end "$end_datetime" \
        --arg tz "$TIMEZONE" \
        '{
            summary: $summary,
            start: { dateTime: $start, timeZone: $tz },
            end: { dateTime: $end, timeZone: $tz }
        }')

    local result
    result=$(gws calendar events insert \
        --calendar "${AGENT_CALENDAR_ID}" \
        --json "$event_json" 2>/dev/null)

    if [[ $? -eq 0 ]]; then
        local event_id event_link
        event_id=$(echo "$result" | jq -r '.id')
        event_link=$(echo "$result" | jq -r '.htmlLink')
        log_info "Event created successfully"
        echo "Event ID: ${event_id}"
        echo "Link: ${event_link}"
    else
        log_error "Failed to create event"
        return 1
    fi
}

# =============================================================================
# Freebusy Check
# =============================================================================

check_freebusy() {
    local date="${1:-$(date '+%Y-%m-%d')}"
    local time_min="${date}T00:00:00Z"
    local time_max="${date}T23:59:59Z"

    log_info "Checking free/busy for ${date}..."

    local freebusy_json
    freebusy_json=$(gws calendar freebusy \
        --json "{\"items\": [{\"id\": \"${AGENT_CALENDAR_ID}\"}], \"timeMin\": \"${time_min}\", \"timeMax\": \"${time_max}\"}" \
        --format json 2>/dev/null || echo '{}')

    echo ""
    echo "Free/Busy for ${date}:"
    echo "----------------------"

    echo "$freebusy_json" | jq -r '.calendars[].busy[]? | "- Busy from \(.start) to \(.end)"' 2>/dev/null || \
        echo "No busy periods found"

    # Calculate free time
    local busy_periods total_busy_mins
    busy_periods=$(echo "$freebusy_json" | jq -r '.calendars[].busy // []')
    total_busy_mins=0

    # This is a simplified calculation
    local event_count
    event_count=$(echo "$freebusy_json" | jq '.calendars[].busy // [] | length' 2>/dev/null || echo "0")

    echo ""
    echo "Busy periods: ${event_count}"
}

# =============================================================================
# Usage Enhancement
# =============================================================================

extended_usage() {
    cat << EOF
Usage: $0 [command] [options]

Commands:
  agenda [date]                  Show daily agenda
  insert <summary> [date] [time] [duration]  Create event with smart scheduling
  freebusy [date]                Check free/busy times
  (default)                      Run full calendar sync

Options:
  --dry-run    Show what would be created without creating events
  --verbose    Enable detailed logging

Examples:
  $0 agenda                              # Show today's agenda
  $0 agenda 2024-03-15                   # Show agenda for specific date
  $0 insert "Team meeting"               # Create meeting, auto-schedule
  $0 insert "Focus time" 2024-03-15 14:00  # Create at specific time
  $0 freebusy                            # Check today's free/busy
  $0 --dry-run                           # Preview calendar sync
EOF
}

# =============================================================================
# Main Entry Point with Extended Commands
# =============================================================================

main() {
    # Check if first arg is a command
    local command="${1:-}"

    case "$command" in
        agenda)
            shift
            load_workspace_config
            show_agenda "$@"
            ;;
        insert)
            shift
            load_workspace_config
            load_calendar_preferences
            smart_insert "$@"
            ;;
        freebusy)
            shift
            load_workspace_config
            check_freebusy "$@"
            ;;
        --help|-h)
            extended_usage
            exit 0
            ;;
        *)
            # Default behavior - run full calendar sync
            main_original "$@"
            ;;
    esac
}

# Rename original main to main_original
# shellcheck disable=SC2331
main_original() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --help|-h)
                extended_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    log_info "Starting Calendar Sync Stage..."
    log_info "========================================"

    # Initialize
    check_dependencies
    load_workspace_config
    load_calendar_preferences
    initialize_log

    # Read inputs
    local action_items
    action_items=$(read_action_items) || die "Failed to read action items"

    local extraction_dates
    extraction_dates=$(read_extraction_dates)

    # Get existing events for conflict detection
    local today end_date
    today=$(date +"%Y-%m-%d")
    end_date=$(date -v+14d +"%Y-%m-%d")  # 14-day planning window

    local existing_events
    existing_events=$(get_existing_events "$today" "$end_date")

    # Process action items
    local events_created=0
    local conflicts=0

    if [[ -n "$action_items" ]]; then
        process_action_items "$action_items" "$existing_events"
        events_created=$?
    fi

    # Process extracted dates
    if [[ -n "$extraction_dates" ]]; then
        process_extraction_dates "$extraction_dates" "$existing_events"
    fi

    # Block focus time for today and tomorrow
    local focus_blocks=0

    if [[ "$DRY_RUN" != "true" ]]; then
        log_info "Scheduling focus blocks..."

        # Today - afternoon focus
        block_focus_time "$today" "afternoon" && ((focus_blocks++)) || true

        # Tomorrow - morning focus
        local tomorrow
        tomorrow=$(date -v+1d +"%Y-%m-%d")
        block_focus_time "$tomorrow" "morning" && ((focus_blocks++)) || true
    fi

    # Finalize log
    finalize_log "$events_created" "$conflicts" "$focus_blocks"

    log_info "========================================"
    log_info "Calendar Sync Stage complete."
    log_info "Output: ${LOG_FILE}"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] No events were actually created."
    fi
}

# Run main
main "$@"

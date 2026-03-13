#!/bin/bash
#
# run-triage.sh - Simple inbox triage using GWS-CLI +triage helper
#
# This script is a thin wrapper around gws gmail +triage.
# The AI agent does the intelligence work (categorization, archiving decisions).
# Scripts just make the API calls.
#
# Usage:
#   ./run-triage.sh [max_results]              - Get inbox summary for AI
#   ./run-triage.sh archive <message_id> <label_id>  - Archive email with label
#
# GWS-CLI +helpers are designed FOR AI agents. Use them directly:
#   gws gmail +triage --max 100 --format json       - Get inbox summary
#   gws gmail +send --to "user@example.com" ...     - Send AI-composed email
#   gws gmail +reply --message-id "..." --body "..." - Reply to thread
#
# The AI agent should:
# 1. Call +triage to get inbox summary
# 2. Categorize emails using its intelligence (not bash regex)
# 3. Decide what to archive using shared/prioritization-rules.md
# 4. Archive emails by calling this script or directly via gws
#

set -euo pipefail

# Filter out "Using keyring" messages from gws output
filter_gws_output() {
    grep -v "^Using keyring" || true
}

# Get inbox summary using +triage helper
# Returns JSON with: id, subject, from, date for each email
cmd_triage() {
    local max_results="${1:-100}"
    gws gmail +triage --max "$max_results" --format json 2>&1 | filter_gws_output
}

# Archive an email (remove from inbox, optionally apply label)
# Label IDs from shared/drive-ids.sh or discovered via gws gmail labels list
cmd_archive() {
    local message_id="${1:-}"
    local label_id="${2:-Label_19}"  # Default to Low-Priority

    if [[ -z "$message_id" ]]; then
        echo '{"error": "Message ID is required"}' >&2
        return 1
    fi

    # Build the modify request
    local json_body
    json_body=$(jq -n --arg label "$label_id" \
        '{"removeLabelIds":["INBOX"],"addLabelIds":[$label]}')

    gws gmail users messages modify \
        --params "{\"userId\":\"me\",\"id\":\"${message_id}\"}" \
        --json "$json_body" \
        --format json 2>&1 | filter_gws_output
}

# Get full email details
cmd_get() {
    local message_id="${1:-}"

    if [[ -z "$message_id" ]]; then
        echo '{"error": "Message ID is required"}' >&2
        return 1
    fi

    gws gmail users messages get \
        --params "{\"userId\":\"me\",\"id\":\"${message_id}\"}" \
        --format json 2>&1 | filter_gws_output
}

# List labels (to discover label IDs)
cmd_labels() {
    gws gmail users labels list \
        --params '{"userId":"me"}' \
        --format json 2>&1 | filter_gws_output
}

usage() {
    cat << 'EOF'
Usage: run-triage.sh <command> [arguments]

Commands:
  triage [max]                Get inbox summary for AI (default: 100 emails)
  get <message_id>            Get full email details
  archive <message_id> [label_id]  Archive email with optional label
  labels                      List all labels (to discover label IDs)

Examples:
  ./run-triage.sh triage 50             # Get last 50 inbox emails
  ./run-triage.sh get 18a5b3c123abc     # Get email details
  ./run-triage.sh archive 18a5b3c123abc # Archive to Low-Priority
  ./run-triage.sh archive 18a5b3c123abc Label_7  # Archive to Newsletters

Label Reference (typical):
  Label_6  = Receipts
  Label_7  = Newsletters
  Label_10 = Jobs
  Label_11 = Promos
  Label_18 = Social
  Label_19 = Low-Priority

Use 'labels' command to discover your actual label IDs.

Output is JSON. The AI agent interprets and acts on this data.
EOF
}

main() {
    local command="${1:-}"

    case "$command" in
        triage)
            shift
            cmd_triage "$@"
            ;;
        get)
            shift
            cmd_get "$@"
            ;;
        archive)
            shift
            cmd_archive "$@"
            ;;
        labels)
            cmd_labels
            ;;
        -h|--help|help)
            usage
            ;;
        *)
            # Default to triage if no command
            if [[ -z "$command" ]]; then
                cmd_triage
            else
                echo '{"error": "Unknown command: '"$command"'"}' >&2
                usage >&2
                exit 1
            fi
            ;;
    esac
}

main "$@"

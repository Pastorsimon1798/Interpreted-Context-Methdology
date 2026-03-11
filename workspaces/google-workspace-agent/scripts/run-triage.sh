#!/usr/bin/env bash
#
# run-triage.sh - Gmail Inbox Triage for Google Workspace Agent
#
# This script performs automated inbox triage by:
# 1. Loading configuration from ~/.config/gws-agent/config.sh
# 2. Fetching unread emails from Gmail API via gws CLI
# 3. Categorizing emails based on prioritization rules
# 4. Identifying action items and urgent items
# 5. Generating a triage report and extraction candidates
#
# Dependencies:
#   - gws CLI (Google Workspace CLI) installed and authenticated
#   - jq (JSON processor)
#   - Configuration file at ~/.config/gws-agent/config.sh
#
# Required config variables (sourced from config.sh):
#   - KNOWLEDGE_BASE_PATH
#   - URGENT_KEYWORDS
#   - IMPORTANT_SENDERS
#   - TRUST_LEVEL
#
# Output files:
#   - output/triage-report-YYYYMMDD-HHMM.md
#   - output/extraction-candidates.json
#
# Usage:
#   ./run-triage.sh [--dry-run] [--verbose]
#
# Options:
#   --dry-run    Show what would be done without making changes
#   --verbose    Enable verbose logging
#
# Compatibility: macOS and Linux
#
# Author: Google Workspace Agent
# Version: 1.0.0
#

set -euo pipefail

# ==============================================================================
# Constants and Configuration
# ==============================================================================

readonly SCRIPT_NAME="run-triage.sh"
readonly SCRIPT_VERSION="1.0.0"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly OUTPUT_DIR="${WORKSPACE_ROOT}/output"
readonly SHARED_DIR="${WORKSPACE_ROOT}/shared"
readonly CONFIG_FILE="${HOME}/.config/gws-agent/config.sh"

# Source label IDs
if [[ -f "${SHARED_DIR}/drive-ids.sh" ]]; then
    source "${SHARED_DIR}/drive-ids.sh"
fi
readonly TIMESTAMP=$(date +"%Y%m%d-%H%M")
readonly DATE_DISPLAY=$(date +"%Y-%m-%d %H:%M:%S")

# Output files
readonly TRIAGE_REPORT="${OUTPUT_DIR}/triage-report-${TIMESTAMP}.md"
readonly EXTRACTION_CANDIDATES="${OUTPUT_DIR}/extraction-candidates.json"
readonly LOG_FILE="${OUTPUT_DIR}/triage-${TIMESTAMP}.log"

# Default values (overridden by config.sh)
KNOWLEDGE_BASE_PATH="${HOME}/knowledge-base"
URGENT_KEYWORDS="urgent,asap,emergency,critical,today,now,immediately,deadline,overdue"
IMPORTANT_SENDERS=""
TRUST_LEVEL="supervised"

# Command-line options
DRY_RUN=false
VERBOSE=false

# ==============================================================================
# Logging Functions
# ==============================================================================

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[${timestamp}] [${level}] ${message}" | tee -a "${LOG_FILE}"
}

log_info() {
    log "INFO" "$@"
}

log_warn() {
    log "WARN" "$@"
}

log_error() {
    log "ERROR" "$@"
}

log_debug() {
    if [[ "${VERBOSE}" == "true" ]]; then
        log "DEBUG" "$@"
    fi
}

# ==============================================================================
# Utility Functions
# ==============================================================================

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Display usage information
usage() {
    cat << EOF
Usage: ${SCRIPT_NAME} [OPTIONS]

Options:
    --dry-run       Show what would be done without making changes
    --verbose       Enable verbose logging
    -h, --help      Show this help message
    -v, --version   Show version information

Examples:
    ${SCRIPT_NAME}                  # Run normal triage
    ${SCRIPT_NAME} --dry-run        # Preview without changes
    ${SCRIPT_NAME} --verbose        # Run with debug output

Configuration file: ${CONFIG_FILE}
Output directory: ${OUTPUT_DIR}
EOF
}

# Display version information
version() {
    echo "${SCRIPT_NAME} version ${SCRIPT_VERSION}"
}

# Parse command-line arguments
parse_args() {
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
            -h|--help)
                usage
                exit 0
                ;;
            -v|--version)
                version
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
}

# ==============================================================================
# Dependency Checking
# ==============================================================================

check_dependencies() {
    log_info "Checking dependencies..."

    local missing_deps=()

    # Check for gws CLI
    if ! command_exists gws; then
        missing_deps+=("gws (Google Workspace CLI)")
    fi

    # Check for jq
    if ! command_exists jq; then
        missing_deps+=("jq (JSON processor)")
    fi

    # Check for curl (used for API calls fallback)
    if ! command_exists curl; then
        missing_deps+=("curl")
    fi

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing required dependencies:"
        for dep in "${missing_deps[@]}"; do
            log_error "  - ${dep}"
        done
        log_error ""
        log_error "Please install missing dependencies and try again."
        exit 1
    fi

    log_info "All dependencies satisfied."
}

# ==============================================================================
# Configuration Loading
# ==============================================================================

load_config() {
    log_info "Loading configuration from ${CONFIG_FILE}..."

    if [[ ! -f "${CONFIG_FILE}" ]]; then
        log_warn "Configuration file not found at ${CONFIG_FILE}"
        log_warn "Using default values. Run 'setup' to create configuration."
        return 0
    fi

    # Source the configuration file
    # shellcheck source=/dev/null
    source "${CONFIG_FILE}"

    log_info "Configuration loaded successfully."
    log_debug "KNOWLEDGE_BASE_PATH: ${KNOWLEDGE_BASE_PATH}"
    log_debug "TRUST_LEVEL: ${TRUST_LEVEL}"
}

# ==============================================================================
# Authentication Check
# ==============================================================================

check_authentication() {
    log_info "Verifying gws authentication..."

    # Check if gws is authenticated
    # The gws CLI stores auth tokens; we verify by checking auth status
    if ! gws auth status >/dev/null 2>&1; then
        log_error "Not authenticated with Google Workspace."
        log_error "Please run: gws auth login"
        exit 1
    fi

    log_info "Authentication verified."
}

# ==============================================================================
# Gmail API Interaction
# ==============================================================================

# Fetch unread emails from Gmail
fetch_unread_emails() {
    log_info "Fetching unread emails from Gmail..."

    local emails_json
    local max_results=${MAX_RESULTS:-50}

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_info "[DRY-RUN] Would fetch up to ${max_results} unread emails"
        emails_json='{"messages":[]}'
    else
        # Use gws gmail +triage helper for efficient unread email summary
        # Note: gws outputs "Using keyring backend" to stderr, which we suppress
        emails_json=$(gws gmail +triage \
            --max "${max_results}" \
            --format json 2>/dev/null)

        if [[ -z "${emails_json}" ]]; then
            log_warn "Empty response from Gmail API - no emails returned"
            log_debug "Raw output: ${emails_json}"
            return 0  # Return empty messages array, not an error
        fi

        log_info "Successfully retrieved $(echo "${emails_json}" | jq -r '.messages | length') emails"
    fi

    echo "${emails_json}"
}

# Fetch detailed information for a specific email
fetch_email_details() {
    local message_id="$1"

    if [[ "${DRY_RUN}" == "true" ]]; then
        echo '{"id":"dummy","subject":"[DRY-RUN] Sample Email","from":"sample@example.com","body":"Sample body"}'
        return 0
    fi

    # Get full message details using gws CLI
    local message_json
    message_json=$(gws gmail users messages get \
        --params "{\"userId\":\"me\",\"id\":\"${message_id}\"}" \
        --format json 2>/dev/null) || {
        log_warn "Failed to fetch details for message ${message_id}"
        return 1
    }

    # Parse Gmail API response to extract subject, from, and body
    local subject from body

    # Extract subject from headers
    subject=$(echo "${message_json}" | jq -r '.payload.headers[] | select(.name == "Subject") | .value // "No Subject"' 2>/dev/null)

    # Extract from from headers
    from=$(echo "${message_json}" | jq -r '.payload.headers[] | select(.name == "From") | .value // "Unknown Sender"' 2>/dev/null)

    # Extract body - try plain text first, then HTML, then snippet
    body=$(echo "${message_json}" | jq -r '.payload.body.data // .payload.parts[]?.body.data // .snippet // ""' 2>/dev/null | head -c 2000)

    # Build simplified JSON for categorization
    jq -n \
        --arg id "${message_id}" \
        --arg subject "${subject}" \
        --arg from "${from}" \
        --arg body "${body}" \
        '{id: $id, subject: $subject, from: $from, body: $body}'
}

# Check if email has a skip label (e.g., AI-Digest)
check_skip_label() {
    local message_id="$1"
    local skip_label_id="${GMAIL_LABEL_AI_DIGEST:-Label_16}"

    if [[ "${DRY_RUN}" == "true" ]]; then
        return 1  # Don't skip in dry-run
    fi

    # Fetch message metadata to check labels
    local message_metadata
    message_metadata=$(gws gmail users messages get \
        --params "{\"userId\":\"me\",\"id\":\"${message_id}\",\"format\":\"metadata\",\"metadataHeaders\":[\"Subject\"]}" \
        --format json 2>/dev/null) || return 1

    # Check if skip label is in the label IDs
    if echo "${message_metadata}" | jq -e --arg label "${skip_label_id}" '.labelIds | index($label)' >/dev/null 2>&1; then
        return 0  # Has skip label
    fi

    return 1  # No skip label
}

# ==============================================================================
# Email Categorization
# ==============================================================================

# Convert comma-separated keywords to regex pattern
build_keyword_pattern() {
    local keywords="$1"
    echo "${keywords}" | tr ',' '|' | sed 's/|/\\|/g'
}

# Check if email matches urgent criteria
check_urgency() {
    local subject="$1"
    local body="$2"

    local urgent_pattern
    urgent_pattern=$(build_keyword_pattern "${URGENT_KEYWORDS}")

    # Check subject for urgent keywords (case-insensitive)
    if echo "${subject}" | grep -iqE "${urgent_pattern}"; then
        return 0
    fi

    # Check body for urgent keywords (case-insensitive)
    if echo "${body}" | grep -iqE "${urgent_pattern}"; then
        return 0
    fi

    return 1
}

# Check if sender is in important senders list
check_important_sender() {
    local sender="$1"
    local sender_email
    sender_email=$(echo "${sender}" | grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' | head -1)

    # Convert important senders to patterns
    local patterns
    patterns=$(echo "${IMPORTANT_SENDERS}" | tr ',' '\n' | grep -v '^$')

    while IFS= read -r pattern; do
        # Support wildcard patterns like *@domain.com
        if [[ "${pattern}" == *@* ]]; then
            local domain_pattern="${pattern#*@}"
            if [[ "${sender_email}" == *@"${domain_pattern}" ]] || [[ "${sender_email}" == "${pattern}" ]]; then
                return 0
            fi
        elif [[ "${sender_email}" == "${pattern}" ]]; then
            return 0
        fi
    done <<< "${patterns}"

    return 1
}

# Categorize a single email (from full details)
categorize_email() {
    local email_json="$1"

    local subject from body message_id
    subject=$(echo "${email_json}" | jq -r '.subject // "No Subject"' 2>/dev/null)
    from=$(echo "${email_json}" | jq -r '.from // "Unknown Sender"' 2>/dev/null)
    body=$(echo "${email_json}" | jq -r '.body // ""' 2>/dev/null)
    message_id=$(echo "${email_json}" | jq -r '.id // "unknown"' 2>/dev/null)

    local category="low-priority"
    local priority_score=0
    local is_urgent=false
    local is_important=false
    local has_action=false

    # Check for urgency
    if check_urgency "${subject}" "${body}"; then
        is_urgent=true
        priority_score=$((priority_score + 3))
    fi

    # Check for important sender
    if check_important_sender "${from}"; then
        is_important=true
        priority_score=$((priority_score + 2))
    fi

    # Detect action-required patterns
    local action_patterns="please review|please approve|please respond|action required|response needed|confirm|deadline|rsvp"
    if echo "${subject} ${body}" | grep -iqE "${action_patterns}"; then
        has_action=true
        category="action-required"
        priority_score=$((priority_score + 2))
    fi

    # Detect promotional emails
    if echo "${body}" | grep -iq "unsubscribe"; then
        category="promotional"
        priority_score=$((priority_score - 1))
    fi

    # Detect newsletters
    if echo "${from}${subject}" | grep -iqE "newsletter|digest|weekly|monthly|update"; then
        if [[ "${category}" != "action-required" ]]; then
            category="newsletter"
        fi
    fi

    # Detect reference emails (receipts, confirmations)
    if echo "${subject}" | grep -iqE "receipt|confirmation|booking|order|invoice|receipt"; then
        if [[ "${category}" != "action-required" ]]; then
            category="reference"
        fi
    fi

    # If action required detected, override category
    if [[ "${has_action}" == "true" ]]; then
        category="action-required"
    fi

    # Build result JSON
    jq -n \
        --arg id "${message_id}" \
        --arg subject "${subject}" \
        --arg from "${from}" \
        --arg category "${category}" \
        --argjson score "${priority_score}" \
        --argjson urgent "${is_urgent}" \
        --argjson important "${is_important}" \
        --argjson action_required "${has_action}" \
        '{
            id: $id,
            subject: $subject,
            from: $from,
            category: $category,
            priority_score: $score,
            is_urgent: $urgent,
            is_important: $important,
            action_required: $action_required
        }'
}

# Categorize email from triage output (subject + from only, no body)
categorize_email_from_triage() {
    local email_json="$1"

    local subject from date message_id
    subject=$(echo "${email_json}" | jq -r '.subject // "No Subject"' 2>/dev/null)
    from=$(echo "${email_json}" | jq -r '.from // "Unknown Sender"' 2>/dev/null)
    date=$(echo "${email_json}" | jq -r '.date // ""' 2>/dev/null)
    message_id=$(echo "${email_json}" | jq -r '.id // "unknown"' 2>/dev/null)

    local category="low-priority"
    local priority_score=0
    local is_urgent=false
    local is_important=false
    local has_action=false

    # Check for urgency in subject only
    local urgent_pattern
    urgent_pattern=$(build_keyword_pattern "${URGENT_KEYWORDS}")
    if echo "${subject}" | grep -iqE "${urgent_pattern}"; then
        is_urgent=true
        priority_score=$((priority_score + 3))
    fi

    # Check for important sender
    if check_important_sender "${from}"; then
        is_important=true
        priority_score=$((priority_score + 2))
    fi

    # Detect action-required patterns in subject
    local action_patterns="please review|please approve|please respond|action required|response needed|confirm|deadline|rsvp|next steps|follow.?up"
    if echo "${subject}" | grep -iqE "${action_patterns}"; then
        has_action=true
        category="action-required"
        priority_score=$((priority_score + 2))
    fi

    # Detect promotional emails from sender patterns
    if echo "${from}" | grep -iqE "noreply|no-reply|newsletter|updates|promo|marketing|offers|deals"; then
        category="promotional"
        priority_score=$((priority_score - 1))
    fi

    # Detect newsletters from subject/sender
    if echo "${from}${subject}" | grep -iqE "newsletter|digest|weekly|monthly|substack"; then
        if [[ "${category}" != "action-required" ]]; then
            category="newsletter"
        fi
    fi

    # Detect job alerts
    if echo "${from}${subject}" | grep -iqE "job alert|job opening|hiring|career|recruiter|application"; then
        if [[ "${category}" != "action-required" ]]; then
            category="job-alert"
        fi
    fi

    # Detect reference emails (receipts, confirmations)
    if echo "${subject}" | grep -iqE "receipt|confirmation|booking|order|invoice|your receipt|statement"; then
        if [[ "${category}" != "action-required" ]]; then
            category="reference"
        fi
    fi

    # If action required detected, override category
    if [[ "${has_action}" == "true" ]]; then
        category="action-required"
    fi

    # Build result JSON
    jq -n \
        --arg id "${message_id}" \
        --arg subject "${subject}" \
        --arg from "${from}" \
        --arg date "${date}" \
        --arg category "${category}" \
        --argjson score "${priority_score}" \
        --argjson urgent "${is_urgent}" \
        --argjson important "${is_important}" \
        --argjson action_required "${has_action}" \
        '{
            id: $id,
            subject: $subject,
            from: $from,
            date: $date,
            category: $category,
            priority_score: $score,
            is_urgent: $urgent,
            is_important: $important,
            action_required: $action_required
        }'
}

# ==============================================================================
# Report Generation
# ==============================================================================

# Generate the triage report markdown
generate_triage_report() {
    local categorized_emails="$1"
    local total_count="$2"
    local urgent_count="$3"
    local action_count="$4"

    log_info "Generating triage report..."

    # Create report header
    cat > "${TRIAGE_REPORT}" << EOF
# Triage Report

**Generated:** ${DATE_DISPLAY}
**Trust Level:** ${TRUST_LEVEL}
**Total Emails Processed:** ${total_count}

---

## Summary

| Metric | Count |
|--------|-------|
| Total Unread | ${total_count} |
| Urgent | ${urgent_count} |
| Action Required | ${action_count} |

---

## Urgent Items

EOF

    # Add urgent items
    local urgent_items
    urgent_items=$(echo "${categorized_emails}" | jq -c '.[] | select(.is_urgent == true)')

    if [[ -n "${urgent_items}" ]]; then
        echo "${urgent_items}" | while IFS= read -r item; do
            local subject from id
            subject=$(echo "${item}" | jq -r '.subject')
            from=$(echo "${item}" | jq -r '.from')
            id=$(echo "${item}" | jq -r '.id')
            cat >> "${TRIAGE_REPORT}" << EOF
### ${subject}

- **From:** ${from}
- **Message ID:** ${id}
- **Priority:** URGENT

EOF
        done
    else
        echo "No urgent items found." >> "${TRIAGE_REPORT}"
        echo "" >> "${TRIAGE_REPORT}"
    fi

    # Add Action Required section
    cat >> "${TRIAGE_REPORT}" << EOF

---

## Action Required

EOF

    local action_items
    action_items=$(echo "${categorized_emails}" | jq -c '.[] | select(.action_required == true and .is_urgent == false)')

    if [[ -n "${action_items}" ]]; then
        echo "${action_items}" | while IFS= read -r item; do
            local subject from id category
            subject=$(echo "${item}" | jq -r '.subject')
            from=$(echo "${item}" | jq -r '.from')
            id=$(echo "${item}" | jq -r '.id')
            category=$(echo "${item}" | jq -r '.category')
            cat >> "${TRIAGE_REPORT}" << EOF
- [ ] **${subject}** (from: ${from})
  - Category: ${category}
  - ID: ${id}

EOF
        done
    else
        echo "No action items found." >> "${TRIAGE_REPORT}"
        echo "" >> "${TRIAGE_REPORT}"
    fi

    # Add Category Breakdown
    cat >> "${TRIAGE_REPORT}" << EOF

---

## Category Breakdown

EOF

    # Get unique categories and counts
    local categories
    categories=$(echo "${categorized_emails}" | jq -r '.[].category' | sort | uniq -c | sort -rn)

    if [[ -n "${categories}" ]]; then
        echo '```' >> "${TRIAGE_REPORT}"
        echo "${categories}" >> "${TRIAGE_REPORT}"
        echo '```' >> "${TRIAGE_REPORT}"
    else
        echo "No emails categorized." >> "${TRIAGE_REPORT}"
    fi

    # Add footer
    cat >> "${TRIAGE_REPORT}" << EOF

---

## Processing Details

- **Configuration:** ${CONFIG_FILE}
- **Knowledge Base:** ${KNOWLEDGE_BASE_PATH}
- **Dry Run:** ${DRY_RUN}

---

*Report generated by Google Workspace Agent v${SCRIPT_VERSION}*
EOF

    log_info "Triage report saved to: ${TRIAGE_REPORT}"
}

# Generate extraction candidates JSON
generate_extraction_candidates() {
    local categorized_emails="$1"

    log_info "Generating extraction candidates..."

    # Filter emails that are candidates for knowledge extraction
    # These include: reference emails, important emails, and action items
    local candidates
    candidates=$(echo "${categorized_emails}" | jq -c '.[] |
        select(.category == "reference" or .is_important == true or .action_required == true)')

    # Build the output JSON
    local timestamp_iso
    timestamp_iso=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_info "[DRY-RUN] Would save extraction candidates to ${EXTRACTION_CANDIDATES}"
        return 0
    fi

    jq -n \
        --arg timestamp "${timestamp_iso}" \
        --arg report_path "${TRIAGE_REPORT}" \
        --argjson candidates "${candidates:-[]}" \
        '{
            generated_at: $timestamp,
            source_report: $report_path,
            total_candidates: ($candidates | length),
            candidates: $candidates
        }' > "${EXTRACTION_CANDIDATES}"

    log_info "Extraction candidates saved to: ${EXTRACTION_CANDIDATES}"
    log_info "Found $(echo "${candidates}" | wc -l | tr -d ' ') candidates for extraction."
}

# ==============================================================================
# Main Execution
# ==============================================================================

main() {
    parse_args "$@"

    log_info "=========================================="
    log_info "Google Workspace Agent - Inbox Triage"
    log_info "Version: ${SCRIPT_VERSION}"
    log_info "=========================================="
    log_info ""

    # Ensure output directory exists
    mkdir -p "${OUTPUT_DIR}"

    # Check dependencies
    check_dependencies

    # Load configuration
    load_config

    # Check authentication
    check_authentication

    # Fetch unread emails
    local emails_json
    emails_json=$(fetch_unread_emails)

    # Process emails directly from +triage output
    log_info "Processing and categorizing emails..."

    local categorized_emails="[]"
    local total_count=0
    local urgent_count=0
    local action_count=0

    # The +triage output already has id, subject, from, date
    # Process each message from the triage output
    local messages
    messages=$(echo "${emails_json}" | jq -c '.messages[]')

    if [[ -n "${messages}" ]]; then
        while IFS= read -r msg; do
            [[ -z "${msg}" ]] && continue

            log_debug "Processing message: $(echo "${msg}" | jq -r '.id')"

            # Skip emails with AI-Digest label
            if check_skip_label "$(echo "${msg}" | jq -r '.id')"; then
                log_debug "Skipping email with AI-Digest label: $(echo "${msg}" | jq -r '.id')"
                continue
            fi

            # Categorize using the triage output (subject + from) without fetching full details
            local categorized
            categorized=$(categorize_email_from_triage "${msg}")
            categorized_emails=$(echo "${categorized_emails}" | jq --argjson email "${categorized}" '. + [$email]')
            total_count=$((total_count + 1))

            # Count urgent and action items
            if echo "${categorized}" | jq -e '.is_urgent == true' >/dev/null; then
                urgent_count=$((urgent_count + 1))
            fi
            if echo "${categorized}" | jq -e '.action_required == true' >/dev/null; then
                action_count=$((action_count + 1))
            fi
        done <<< "${messages}"
    fi

    log_info "Processed ${total_count} emails"

    # Generate reports
    if [[ "${DRY_RUN}" == "true" ]]; then
        log_info "[DRY-RUN] Would generate triage report and extraction candidates"
        log_info "[DRY-RUN] Summary: ${total_count} emails, ${urgent_count} urgent, ${action_count} action items"
    else
        generate_triage_report "${categorized_emails}" "${total_count}" "${urgent_count}" "${action_count}"
        generate_extraction_candidates "${categorized_emails}"
    fi

    log_info ""
    log_info "=========================================="
    log_info "Triage Complete"
    log_info "=========================================="
    log_info "Report: ${TRIAGE_REPORT}"
    log_info "Candidates: ${EXTRACTION_CANDIDATES}"
    log_info "Log: ${LOG_FILE}"

    # Return appropriate exit code
    if [[ "${DRY_RUN}" == "true" ]]; then
        exit 0
    fi

    # If trust level is supervised and there are urgent/action items, suggest review
    if [[ "${TRUST_LEVEL}" == "supervised" ]] && [[ ${urgent_count} -gt 0 || ${action_count} -gt 0 ]]; then
        log_info ""
        log_info "NOTE: Trust level is 'supervised'. Please review the triage report before proceeding."
    fi
}

# Run main function
main "$@"

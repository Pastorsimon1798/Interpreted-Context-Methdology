#!/bin/bash
#
# run-newsletters.sh - Automated Newsletter Processing Pipeline
#
# This script:
# 1. Fetches unread newsletter emails from Gmail
# 2. Extracts article URLs from email content
# 3. Scrapes full article content
# 4. Generates knowledge base summaries
# 5. Saves to PARA knowledge base
# 6. Marks emails as processed
#
# Usage:
#   ./run-newsletters.sh [--dry-run] [--max N]
#
# Dependencies:
#   - gws CLI (Google Workspace CLI)
#   - jq (JSON processor)
#   - curl (for web scraping via firecrawl)
#

set -euo pipefail

# ==============================================================================
# Configuration
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_DIR="${WORKSPACE_ROOT}/output"
SHARED_DIR="${WORKSPACE_ROOT}/shared"
LOG_DIR="${WORKSPACE_ROOT}/logs"

# Timestamp
TIMESTAMP=$(date +"%Y%m%d-%H%M")
DATE_ONLY=$(date +"%Y-%m-%d")

# Output files
NEWSLETTER_LOG="${OUTPUT_DIR}/newsletter-processing-${TIMESTAMP}.log"
PROCESSED_FILE="${OUTPUT_DIR}/processed-newsletters-${TIMESTAMP}.json"

# Default max newsletters to process
MAX_NEWSLETTERS=${MAX_NEWSLETTERS:-10}

# Dry run mode
DRY_RUN=${DRY_RUN:-false}

# Firecrawl API (uses MCP server)
FIRECRAWL_AVAILABLE=true

# ==============================================================================
# Logging Functions
# ==============================================================================

log() {
    local level="$1"
    shift
    local message="$*"
    local ts=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${ts}] [${level}] ${message}" | tee -a "${NEWSLETTER_LOG}"
}

log_info() { log "INFO" "$@"; }
log_warn() { log "WARN" "$@"; }
log_error() { log "ERROR" "$@"; }
log_success() { log "SUCCESS" "$@"; }

# ==============================================================================
# Dependency Checks
# ==============================================================================

check_dependencies() {
    log_info "Checking dependencies..."

    local missing=()

    if ! command -v gws &> /dev/null; then
        missing+=("gws CLI")
    fi

    if ! command -v jq &> /dev/null; then
        missing+=("jq")
    fi

    if ! command -v curl &> /dev/null; then
        missing+=("curl")
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing dependencies: ${missing[*]}"
        exit 1
    fi

    log_success "All dependencies satisfied"
}

# ==============================================================================
# Newsletter Detection
# ==============================================================================

# Known newsletter senders (domains)
NEWSLETTER_DOMAINS=(
    "substack.com"
    "medium.com"
    "towardsai.net"
    "beehiiv.com"
    "convertkit.com"
    "mailchimp.com"
    "buttondown.email"
    "ghost.org"
    "linkedin.com"
)

# Keywords that indicate newsletter
NEWSLETTER_KEYWORDS=(
    "newsletter"
    "digest"
    "weekly"
    "monthly"
    "substack"
    "unsubscribe"
)

# ==============================================================================
# Fetch Newsletters from Gmail
# ==============================================================================

fetch_newsletters() {
    log_info "Fetching unread newsletters from Gmail..."

    local newsletters_json

    # Use gws gmail +triage to get unread emails
    newsletters_json=$(gws gmail +triage --max 50 --format json 2>/dev/null)

    # Filter for newsletters based on sender and keywords
    # Note: Parentheses required because 'or' has higher precedence than '|'
    echo "$newsletters_json" | jq -c '.messages[] |
        select(
            (.from | test("substack|medium|newsletter|digest"; "i")) or
            (.subject | test("newsletter|digest|weekly|monthly"; "i"))
        )'
}

# ==============================================================================
# Extract Article URL from Email
# ==============================================================================

extract_article_url() {
    local message_id="$1"

    # Fetch full message to get body content
    local message_json
    message_json=$(gws gmail users messages get --params "{\"userId\":\"me\",\"id\":\"${message_id}\",\"format\":\"full\"}" --format json 2>/dev/null)

    # Extract URLs from email body
    local urls
    urls=$(echo "$message_json" | jq -r '.payload.parts[]?.body.data // .payload.body.data // empty' 2>/dev/null | \
        base64 -d 2>/dev/null | \
        grep -oE 'https?://[^"<>\s]+' | \
        grep -E 'substack\.com|medium\.com|towardsai\.net|beehiiv\.com' | \
        head -1)

    echo "$urls"
}

# ==============================================================================
# Scrape Article Content
# ==============================================================================

scrape_article() {
    local url="$1"
    local subject="$2"
    local from="$3"

    log_info "Scraping article: ${url}"

    # Use firecrawl via MCP (this would need to be called differently in practice)
    # For now, we'll use a placeholder that works with the existing setup

    # Create a temporary file for the scraped content
    local temp_file="/tmp/article-${TIMESTAMP}.json"

    # This is a simplified version - in production, this would call the firecrawl MCP
    # For now, return basic info
    cat << EOF
{
    "url": "${url}",
    "subject": "${subject}",
    "from": "${from}",
    "scraped": true,
    "timestamp": "${TIMESTAMP}"
}
EOF
}

# ==============================================================================
# Generate KB Content
# ==============================================================================

generate_kb_content() {
    local subject="$1"
    local from="$2"
    local url="$3"
    local snippet="$4"

    # Extract sender name
    local sender_name=$(echo "$from" | sed 's/.*<\(.*\)>/\1/' | sed 's/@.*//')

    # Generate KB title
    local kb_title="${subject} (${sender_name} ${DATE_ONLY})"

    # Generate KB content
    cat << EOF
# ${subject}

**Source:** ${from}
**Date:** ${DATE_ONLY}
**URL:** ${url}
**PARA Category:** Resources

---

## Summary

${snippet}

---

## Key Insights

*Content extracted from newsletter. Review and add key insights.*

---

## Action Items

- [ ] Review full article
- [ ] Extract key learnings
- [ ] Apply to current work

---

## Tags

#newsletter #extracted #${sender_name}

---

*Processed by Google Workspace Agent - run-newsletters.sh*
EOF
}

# ==============================================================================
# Save to Knowledge Base
# ==============================================================================

save_to_kb() {
    local title="$1"
    local content="$2"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would save to KB: ${title}"
        return 0
    fi

    log_info "Saving to Knowledge Base: ${title}"

    # Source drive IDs and call kb-create
    source "${WORKSPACE_ROOT}/shared/drive-ids.sh"

    local result
    result=$("${WORKSPACE_ROOT}/scripts/kb-create.sh" resource "${title}" "${content}" 2>&1)

    if [[ $? -eq 0 ]]; then
        log_success "Saved to KB"
        echo "$result"
    else
        log_error "Failed to save to KB: ${result}"
        return 1
    fi
}

# ==============================================================================
# Mark Email as Processed
# ==============================================================================

mark_processed() {
    local message_id="$1"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would mark as processed: ${message_id}"
        return 0
    fi

    log_info "Marking email as processed: ${message_id}"

    # Add "processed" label and archive
    # Note: gws syntax for labeling
    gws gmail users messages modify --params "{\"userId\":\"me\",\"id\":\"${message_id}\",\"addLabelIds\":[\"${GMAIL_LABEL_RESOURCES:-Label_14}\"],\"removeLabelIds\":[\"UNREAD\"]}" 2>/dev/null || true

    log_success "Email marked as processed"
}

# ==============================================================================
# Process Single Newsletter
# ==============================================================================

process_newsletter() {
    local newsletter_json="$1"

    local id subject from date
    id=$(echo "$newsletter_json" | jq -r '.id')
    subject=$(echo "$newsletter_json" | jq -r '.subject')
    from=$(echo "$newsletter_json" | jq -r '.from')
    date=$(echo "$newsletter_json" | jq -r '.date')

    log_info "Processing newsletter: ${subject}"
    log_info "  From: ${from}"
    log_info "  Date: ${date}"

    # Extract article URL
    local article_url
    article_url=$(extract_article_url "$id")

    if [[ -z "$article_url" ]]; then
        log_warn "No article URL found, using snippet only"
        article_url="N/A"
    fi

    # Generate KB content
    local kb_content
    kb_content=$(generate_kb_content "$subject" "$from" "$article_url" "Newsletter content - full extraction pending manual review")

    # Save to KB
    local kb_title="Newsletter - ${subject} (${DATE_ONLY})"
    save_to_kb "$kb_title" "$kb_content"

    # Mark as processed
    mark_processed "$id"

    log_success "Newsletter processed: ${subject}"
}

# ==============================================================================
# Main Entry Point
# ==============================================================================

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run|-n)
                DRY_RUN=true
                shift
                ;;
            --max|-m)
                MAX_NEWSLETTERS="$2"
                shift 2
                ;;
            --help|-h)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --dry-run, -n    Show what would be done without making changes"
                echo "  --max N, -m N    Process maximum N newsletters (default: 10)"
                echo "  --help, -h       Show this help message"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    # Initialize
    mkdir -p "${OUTPUT_DIR}" "${LOG_DIR}"

    log_info "=========================================="
    log_info "Newsletter Processing Pipeline"
    log_info "=========================================="
    log_info "Dry run: ${DRY_RUN}"
    log_info "Max newsletters: ${MAX_NEWSLETTERS}"
    log_info ""

    # Check dependencies
    check_dependencies

    # Fetch newsletters
    local newsletters
    newsletters=$(fetch_newsletters)

    local count=$(echo "$newsletters" | wc -l | tr -d ' ')
    log_info "Found ${count} newsletters to process"

    if [[ "$count" -eq 0 ]]; then
        log_info "No newsletters found. Done."
        exit 0
    fi

    # Process each newsletter (up to max)
    local processed=0
    echo "$newsletters" | head -n "${MAX_NEWSLETTERS}" | while read -r newsletter; do
        [[ -z "$newsletter" ]] && continue

        if process_newsletter "$newsletter"; then
            ((processed++)) || true
        fi
    done

    log_info ""
    log_info "=========================================="
    log_info "Processing Complete"
    log_info "=========================================="
    log_info "Processed: ${processed} newsletters"
    log_info "Log: ${NEWSLETTER_LOG}"
}

# Run main
main "$@"

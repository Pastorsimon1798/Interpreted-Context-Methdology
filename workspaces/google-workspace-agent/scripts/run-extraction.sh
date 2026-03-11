#!/bin/bash
#
# run-extraction.sh - Knowledge Extraction Stage for Google Workspace Agent
#
# This script extracts valuable information from emails flagged during triage
# and creates markdown files in the PARA knowledge base structure.
#
# Dependencies:
#   - gws CLI (Google Workspace CLI)
#   - jq (JSON processor)
#   - Prior run of run-triage.sh (requires extraction-candidates.json)
#
# Usage:
#   ./run-extraction.sh [--config CONFIG_PATH] [--dry-run]
#

set -euo pipefail

# ==============================================================================
# Configuration
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(dirname "$SCRIPT_DIR")"
STAGES_DIR="$WORKSPACE_ROOT/stages"
SHARED_DIR="$WORKSPACE_ROOT/shared"
TRIAGE_OUTPUT="$STAGES_DIR/01-triage/output"
EXTRACTION_OUTPUT="$STAGES_DIR/02-extraction/output"

# Default config file location
CONFIG_FILE="${CONFIG_FILE:-$WORKSPACE_ROOT/config.json}"

# Dry run mode (default: false)
DRY_RUN="${DRY_RUN:-false}"

# Timestamp for this run
TIMESTAMP=$(date +"%Y%m%d-%H%M")
DATE_ONLY=$(date +"%Y-%m-%d")

# Log file
LOG_FILE="$EXTRACTION_OUTPUT/extraction-log-${TIMESTAMP}.md"

# Knowledge base path (will be read from config)
KNOWLEDGE_BASE_PATH="${KNOWLEDGE_BASE_PATH:-}"

# ==============================================================================
# Logging Functions
# ==============================================================================

log_info() {
    local msg="$1"
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $msg"
    echo "- **[$(date '+%H:%M:%S')]** $msg" >> "$LOG_FILE"
}

log_error() {
    local msg="$1"
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $msg" >&2
    echo "- **[$(date '+%H:%M:%S')] ERROR: $msg" >> "$LOG_FILE"
}

log_success() {
    local msg="$1"
    echo "[SUCCESS] $(date '+%Y-%m-%d %H:%M:%S') - $msg"
    echo "- **[$(date '+%H:%M:%S')] SUCCESS: $msg" >> "$LOG_FILE"
}

log_warn() {
    local msg="$1"
    echo "[WARN] $(date '+%Y-%m-%d %H:%M:%S') - $msg"
    echo "- **[$(date '+%H:%M:%S')] WARN: $msg" >> "$LOG_FILE"
}

# ==============================================================================
# Dependency Checks
# ==============================================================================

check_dependencies() {
    log_info "Checking dependencies..."

    # Check for gws CLI
    if ! command -v gws &> /dev/null; then
        log_error "gws CLI not found. Please install @googleworkspace/cli"
        exit 1
    fi

    # Check for jq
    if ! command -v jq &> /dev/null; then
        log_error "jq not found. Please install jq"
        exit 1
    fi

    log_success "All dependencies satisfied"
}

# ==============================================================================
# Configuration Loading
# ==============================================================================

load_config() {
    log_info "Loading configuration from $CONFIG_FILE..."

    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_error "Configuration file not found: $CONFIG_FILE"
        log_info "Creating default configuration file..."
        create_default_config
    fi

    # Read configuration values
    KNOWLEDGE_BASE_PATH=$(jq -r '.knowledge_base_path // empty' "$CONFIG_FILE" 2>/dev/null || echo "")

    if [[ -z "$KNOWLEDGE_BASE_PATH" ]]; then
        log_warn "KNOWLEDGE_BASE_PATH not configured. Extractions will only be logged."
    else
        log_info "Knowledge base path: $KNOWLEDGE_BASE_PATH"
    fi

    log_success "Configuration loaded"
}

create_default_config() {
    cat > "$CONFIG_FILE" << 'EOF'
{
  "knowledge_base_path": "",
  "trust_level": "supervised",
  "extraction_settings": {
    "max_items_per_run": 50,
    "skip_duplicates": true,
    "auto_archive_extracted": false
  }
}
EOF
    log_info "Default configuration created at $CONFIG_FILE"
}

# ==============================================================================
# Input Validation
# ==============================================================================

validate_inputs() {
    log_info "Validating inputs..."

    # Check for extraction candidates from triage stage
    local candidates_file="$TRIAGE_OUTPUT/extraction-candidates.json"

    if [[ ! -f "$candidates_file" ]]; then
        log_error "Extraction candidates file not found: $candidates_file"
        log_error "Please run run-triage.sh first"
        exit 1
    fi

    # Check if candidates file is valid JSON
    if ! jq empty "$candidates_file" 2>/dev/null; then
        log_error "Invalid JSON in extraction candidates file"
        exit 1
    fi

    # Check if there are candidates to process
    local candidate_count=$(jq 'length' "$candidates_file" 2>/dev/null || echo "0")

    if [[ "$candidate_count" -eq 0 ]]; then
        log_info "No extraction candidates found. Nothing to process."
        exit 0
    fi

    log_success "Found $candidate_count extraction candidates"
}

# ==============================================================================
# PARA Category Determination
# ==============================================================================

determine_para_category() {
    local subject="$1"
    local sender="$2"
    local labels="$3"
    local content_type="$4"

    # Read extraction rules for category mapping
    local extraction_rules="$SHARED_DIR/extraction-rules.md"

    # Default category logic (can be enhanced with rules from extraction-rules.md)
    local category="Resources"

    # Check for project-related keywords
    if echo "$subject" | grep -qiE '\b(project|launch|sprint|milestone|deadline)\b'; then
        category="Projects"
    # Check for area-related keywords
    elif echo "$subject" | grep -qiE '\b(team|management|health|finance|career|learning)\b'; then
        category="Areas"
    # Check for action items
    elif echo "$content_type" | grep -qiE 'action|todo|task'; then
        category="Projects"
    # Newsletter and reference content
    elif echo "$content_type" | grep -qiE 'newsletter|article|resource|link'; then
        category="Resources"
    fi

    echo "$category"
}

get_para_subfolder() {
    local category="$1"
    local content_type="$2"
    local subject="$3"

    local subfolder=""

    case "$category" in
        "Projects")
            # Extract project name from subject or use default
            subfolder="Inbox"
            ;;
        "Areas")
            # Determine area from content
            subfolder="General"
            ;;
        "Resources")
            # Determine resource type
            case "$content_type" in
                *link*|*url*) subfolder="Links" ;;
                *newsletter*) subfolder="Newsletters" ;;
                *guide*|*how-to*) subfolder="Guides" ;;
                *news*|*announcement*) subfolder="News" ;;
                *contact*) subfolder="Contacts" ;;
                *) subfolder="General" ;;
            esac
            ;;
        "Archive")
            subfolder=""
            ;;
        *)
            subfolder="General"
            ;;
    esac

    echo "$subfolder"
}

# ==============================================================================
# Email Content Fetching
# ==============================================================================

fetch_email_content() {
    local message_id="$1"

    log_info "Fetching full content for message: $message_id"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would fetch email content for $message_id"
        echo '{"id": "'"$message_id"'", "subject": "[Dry Run] Test Subject", "from": "test@example.com", "body": "Test body content"}'
        return 0
    fi

    # Fetch full email content using gws
    local email_data
    email_data=$(gws gmail messages get "$message_id" --format=json 2>&1)

    if [[ $? -ne 0 ]]; then
        log_error "Failed to fetch email $message_id: $email_data"
        return 1
    fi

    echo "$email_data"
}

# ==============================================================================
# Content Extraction
# ==============================================================================

extract_valuable_content() {
    local email_data="$1"
    local extraction_rules="$SHARED_DIR/extraction-rules.md"

    # Extract key fields from email
    local subject=$(echo "$email_data" | jq -r '.subject // .payload.headers[] | select(.name == "Subject") | .value // "No Subject"')
    local from=$(echo "$email_data" | jq -r '.from // .payload.headers[] | select(.name == "From") | .value // "Unknown Sender"')
    local body=$(echo "$email_data" | jq -r '.body // .payload.body.data // ""')
    local message_id=$(echo "$email_data" | jq -r '.id // "unknown"')

    # Extract links from body
    local links=$(echo "$body" | grep -oE 'https?://[^[:space:]]+' | head -20 || true)

    # Extract potential quotes (lines starting with > or containing quotes)
    local quotes=$(echo "$body" | grep -E '^(>|"|\p{Pi})' | head -10 || true)

    # Extract action items (lines with TODO, please, action required)
    local action_items=$(echo "$body" | grep -iE '(TODO|please|action required|deadline|by \d)' | head -10 || true)

    # Extract numbers/metrics
    local metrics=$(echo "$body" | grep -oE '\b\d+([.,]\d+)?%?\b' | head -10 || true)

    # Determine content type
    local content_type="general"
    if [[ -n "$links" ]]; then
        content_type="links"
    elif [[ -n "$action_items" ]]; then
        content_type="action-items"
    elif echo "$subject" | grep -qiE 'newsletter|update|digest'; then
        content_type="newsletter"
    elif echo "$subject" | grep -qiE 'announcement|new|launch'; then
        content_type="announcement"
    fi

    # Determine PARA category
    local para_category=$(determine_para_category "$subject" "$from" "" "$content_type")
    local para_subfolder=$(get_para_subfolder "$para_category" "$content_type" "$subject")

    # Create extraction record
    cat << EOF
{
  "message_id": "$message_id",
  "subject": "$subject",
  "from": "$from",
  "date": "$DATE_ONLY",
  "content_type": "$content_type",
  "para_category": "$para_category",
  "para_subfolder": "$para_subfolder",
  "links": $(echo "$links" | jq -Rs 'split("\n") | map(select(length > 0))'),
  "action_items": $(echo "$action_items" | jq -Rs 'split("\n") | map(select(length > 0))'),
  "metrics": $(echo "$metrics" | jq -Rs 'split("\n") | map(select(length > 0))'),
  "body_preview": $(echo "$body" | head -c 500 | jq -Rs '.')
}
EOF
}

# ==============================================================================
# Markdown File Creation
# ==============================================================================

create_markdown_file() {
    local extraction="$1"
    local output_path="$2"

    local subject=$(echo "$extraction" | jq -r '.subject')
    local from=$(echo "$extraction" | jq -r '.from')
    local date=$(echo "$extraction" | jq -r '.date')
    local content_type=$(echo "$extraction" | jq -r '.content_type')
    local para_category=$(echo "$extraction" | jq -r '.para_category')
    local para_subfolder=$(echo "$extraction" | jq -r '.para_subfolder')
    local message_id=$(echo "$extraction" | jq -r '.message_id')
    local links=$(echo "$extraction" | jq -r '.links[]?' 2>/dev/null || echo "")
    local action_items=$(echo "$extraction" | jq -r '.action_items[]?' 2>/dev/null || echo "")
    local body_preview=$(echo "$extraction" | jq -r '.body_preview')

    # Sanitize subject for filename
    local safe_subject=$(echo "$subject" | sed 's/[^a-zA-Z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')
    local filename="${TIMESTAMP}-${safe_subject}.md"
    local filepath="$output_path/$filename"

    # Create directory if it doesn't exist
    mkdir -p "$output_path"

    # Generate markdown content
    cat > "$filepath" << EOF
# ${subject}

**Source Email ID:** \`${message_id}\`
**From:** ${from}
**Extracted:** ${date}
**Category:** ${content_type}
**PARA:** ${para_category}/${para_subfolder}

---

## Extracted Content

${body_preview}

EOF

    # Add links section if present
    if [[ -n "$links" ]]; then
        echo "### Links" >> "$filepath"
        echo "" >> "$filepath"
        echo "$links" | while read -r link; do
            if [[ -n "$link" ]]; then
                echo "- ${link}" >> "$filepath"
            fi
        done
        echo "" >> "$filepath"
    fi

    # Add action items section if present
    if [[ -n "$action_items" ]]; then
        echo "### Action Items" >> "$filepath"
        echo "" >> "$filepath"
        echo "$action_items" | while read -r item; do
            if [[ -n "$item" ]]; then
                echo "- [ ] ${item}" >> "$filepath"
            fi
        done
        echo "" >> "$filepath"
    fi

    # Add metadata footer
    cat >> "$filepath" << EOF

---

## Metadata

| Field | Value |
|-------|-------|
| Source Email | [\`${message_id}\`](gmail://message/${message_id}) |
| PARA Category | ${para_category} |
| Subfolder | ${para_subfolder} |
| Extracted On | ${date} |

**Tags:** #extracted #${content_type} #${para_category,,}

---
*Generated by Google Workspace Agent - run-extraction.sh*
EOF

    echo "$filepath"
}

# ==============================================================================
# Attachment Handling
# ==============================================================================

copy_attachments() {
    local message_id="$1"
    local destination="$2"

    if [[ -z "$KNOWLEDGE_BASE_PATH" ]]; then
        log_warn "Knowledge base path not configured, skipping attachments"
        return 0
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would copy attachments for $message_id to $destination"
        return 0
    fi

    log_info "Processing attachments for message: $message_id"

    # Get attachment list from email
    local attachments
    attachments=$(gws gmail messages attachments list "$message_id" --format=json 2>&1)

    if [[ $? -ne 0 ]]; then
        log_warn "Could not fetch attachments for $message_id"
        return 0
    fi

    local attachment_count=$(echo "$attachments" | jq 'length' 2>/dev/null || echo "0")

    if [[ "$attachment_count" -eq 0 ]]; then
        log_info "No attachments found for $message_id"
        return 0
    fi

    # Create attachments directory
    local attach_dir="$destination/attachments"
    mkdir -p "$attach_dir"

    # Download each attachment
    echo "$attachments" | jq -c '.[]' 2>/dev/null | while read -r attachment; do
        local attach_id=$(echo "$attachment" | jq -r '.id')
        local filename=$(echo "$attachment" | jq -r '.filename')

        if [[ -n "$filename" && "$filename" != "null" ]]; then
            log_info "Downloading attachment: $filename"
            gws gmail messages attachments get "$message_id" "$attach_id" > "$attach_dir/$filename" 2>&1 || \
                log_warn "Failed to download attachment: $filename"
        fi
    done

    log_success "Processed $attachment_count attachments"
}

# ==============================================================================
# Main Processing Loop
# ==============================================================================

process_candidates() {
    local candidates_file="$TRIAGE_OUTPUT/extraction-candidates.json"
    local processed_count=0
    local error_count=0
    local skipped_count=0

    log_info "Processing extraction candidates..."

    # Read candidates
    local candidates=$(cat "$candidates_file")

    # Process each candidate
    echo "$candidates" | jq -c '.[]' 2>/dev/null | while read -r candidate; do
        local message_id=$(echo "$candidate" | jq -r '.message_id // .id')
        local priority=$(echo "$candidate" | jq -r '.priority // "normal"')
        local category=$(echo "$candidate" | jq -r '.category // "general"')

        log_info "Processing message $message_id (priority: $priority, category: $category)"

        # Fetch full email content
        local email_data
        email_data=$(fetch_email_content "$message_id")

        if [[ $? -ne 0 ]]; then
            log_error "Skipping $message_id due to fetch error"
            ((error_count++)) || true
            continue
        fi

        # Extract valuable content
        local extraction
        extraction=$(extract_valuable_content "$email_data")

        if [[ $? -ne 0 ]]; then
            log_error "Failed to extract content from $message_id"
            ((error_count++)) || true
            continue
        fi

        # Determine output path
        local para_category=$(echo "$extraction" | jq -r '.para_category')
        local para_subfolder=$(echo "$extraction" | jq -r '.para_subfolder')
        local output_path=""

        if [[ -n "$KNOWLEDGE_BASE_PATH" ]]; then
            case "$para_category" in
                "Projects")
                    output_path="$KNOWLEDGE_BASE_PATH/Projects/$para_subfolder"
                    ;;
                "Areas")
                    output_path="$KNOWLEDGE_BASE_PATH/Areas/$para_subfolder"
                    ;;
                "Resources")
                    output_path="$KNOWLEDGE_BASE_PATH/Resources/$para_subfolder"
                    ;;
                "Archive")
                    output_path="$KNOWLEDGE_BASE_PATH/Archive/Extractions"
                    ;;
                *)
                    output_path="$KNOWLEDGE_BASE_PATH/Resources/General"
                    ;;
            esac
        else
            # Default to local output directory
            output_path="$EXTRACTION_OUTPUT/extractions/$para_category/$para_subfolder"
        fi

        # Create markdown file
        if [[ "$DRY_RUN" == "true" ]]; then
            log_info "[DRY RUN] Would create markdown file in $output_path"
        else
            local filepath
            filepath=$(create_markdown_file "$extraction" "$output_path")
            log_success "Created extraction: $filepath"

            # Copy attachments if knowledge base path exists
            if [[ -n "$KNOWLEDGE_BASE_PATH" ]]; then
                copy_attachments "$message_id" "$output_path"
            fi
        fi

        ((processed_count++)) || true
    done

    log_info "Processing complete: $processed_count processed, $error_count errors, $skipped_count skipped"
}

# ==============================================================================
# Extraction Log Generation
# ==============================================================================

initialize_log() {
    mkdir -p "$EXTRACTION_OUTPUT"

    cat > "$LOG_FILE" << EOF
# Extraction Log - ${TIMESTAMP}

**Run Date:** $(date '+%Y-%m-%d %H:%M:%S')
**Script:** run-extraction.sh
**Dry Run:** ${DRY_RUN}

---

## Configuration

| Setting | Value |
|---------|-------|
| Knowledge Base Path | ${KNOWLEDGE_BASE_PATH:-Not configured} |
| Config File | ${CONFIG_FILE} |
| Extraction Rules | ${SHARED_DIR}/extraction-rules.md |

---

## Processing Log

EOF
}

finalize_log() {
    local end_time=$(date '+%Y-%m-%d %H:%M:%S')

    cat >> "$LOG_FILE" << EOF

---

## Summary

**End Time:** ${end_time}

### Statistics

| Metric | Count |
|--------|-------|
| Processed | ${processed_count:-0} |
| Errors | ${error_count:-0} |
| Skipped | ${skipped_count:-0} |

---

*Generated by run-extraction.sh*
EOF

    log_success "Extraction log saved to: $LOG_FILE"
}

# ==============================================================================
# Cleanup
# ==============================================================================

cleanup() {
    local exit_code=$?
    log_info "Cleaning up..."
    finalize_log
    exit $exit_code
}

trap cleanup EXIT

# ==============================================================================
# Argument Parsing
# ==============================================================================

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --config|-c)
                CONFIG_FILE="$2"
                shift 2
                ;;
            --dry-run|-n)
                DRY_RUN="true"
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --config, -c PATH    Path to configuration file"
                echo "  --dry-run, -n        Run without making changes"
                echo "  --help, -h           Show this help message"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
}

# ==============================================================================
# Main Entry Point
# ==============================================================================

main() {
    parse_args "$@"

    echo "=============================================="
    echo "  Google Workspace Agent - Extraction Stage"
    echo "=============================================="
    echo ""

    # Initialize log
    initialize_log

    # Run pipeline
    check_dependencies
    load_config
    validate_inputs
    process_candidates

    log_success "Extraction stage completed successfully"
}

# Run main
main "$@"

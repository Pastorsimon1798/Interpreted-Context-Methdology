#!/bin/bash

#===============================================================================
# Google Workspace Agent - Cron Job Installer
#===============================================================================
#
# Description:
#   Installs cron jobs for the Google Workspace Agent with split scheduling:
#   - Triage: runs frequently (default: every 30 minutes)
#   - Digest: runs twice a day (9am and 5pm) only if there's valuable content
#
# Usage:
#   ./install-cron.sh [OPTIONS]
#
# Options:
#   --triage-interval MINUTES  Triage run interval (default: 30)
#   --digest-times HH:MM,HH:MM  Digest times (default: 09:00,17:00)
#   --uninstall                Remove all cron jobs
#   --status                   Show current cron status
#   --help                     Display this help message
#
# Examples:
#   ./install-cron.sh                           # Default: triage every 30min, digest 9am/5pm
#   ./install-cron.sh --triage-interval 15      # Triage every 15 minutes
#   ./install-cron.sh --digest-times 08:00,18:00 # Digest at 8am and 6pm
#   ./install-cron.sh --uninstall               # Remove all cron jobs
#
#===============================================================================

set -euo pipefail

#-------------------------------------------------------------------------------
# Configuration
#-------------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TRIAGE_SCRIPT="${SCRIPT_DIR}/run-triage.sh"
DIGEST_SCRIPT="${SCRIPT_DIR}/run-digest.sh"
NEWSLETTER_SCRIPT="${SCRIPT_DIR}/run-newsletters.sh"
LOG_DIR="${WORKSPACE_ROOT}/logs"

# Cron markers
TRIAGE_MARKER="GWS_AGENT_TRIAGE"
DIGEST_MARKER="GWS_AGENT_DIGEST"
NEWSLETTER_MARKER="GWS_AGENT_NEWSLETTER"

# Default schedules
DEFAULT_TRIAGE_INTERVAL=30
DEFAULT_DIGEST_TIMES="09:00,17:00"
DEFAULT_NEWSLETTER_TIMES="10:00,14:00"

#-------------------------------------------------------------------------------
# Color Output
#-------------------------------------------------------------------------------

if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    NC=''
fi

#-------------------------------------------------------------------------------
# Helper Functions
#-------------------------------------------------------------------------------

log_info() {
    echo -e "${GREEN}✓${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}!${NC} $*"
}

log_error() {
    echo -e "${RED}✗${NC} $*"
}

show_help() {
    cat << EOF
Google Workspace Agent - Cron Job Installer

Installs split-schedule cron jobs:
  - Triage: frequent monitoring (default: every 30 minutes)
  - Digest: twice-daily summaries (default: 9am and 5pm)

Usage: $(basename "$0") [OPTIONS]

Options:
    --triage-interval MINUTES   Triage interval (default: 30)
    --digest-times HH:MM,HH:MM  Digest times (default: 09:00,17:00)
    --uninstall                 Remove all cron jobs
    --status                    Show current cron status
    --help                      Display this help message

Examples:
    $(basename "$0")                              # Defaults
    $(basename "$0") --triage-interval 15         # Triage every 15 min
    $(basename "$0") --digest-times 08:00,20:00   # Digest at 8am and 8pm
    $(basename "$0") --uninstall                  # Remove all jobs

EOF
}

get_current_cron() {
    crontab -l 2>/dev/null || echo ""
}

cron_entry_exists() {
    local marker="$1"
    local current_cron
    current_cron=$(get_current_cron)
    echo "${current_cron}" | grep -q "${marker}"
    return $?
}

# Convert time like "09:00" to cron format "0 9 * * *"
time_to_cron() {
    local time="$1"
    local hour="${time%%:*}"
    local min="${time##*:}"
    # Remove leading zeros for hour
    hour=$((10#$hour))
    echo "${min} ${hour} * * *"
}

install_cron() {
    local triage_interval="$1"
    local digest_times="$2"

    echo ""
    echo -e "${CYAN}Installing cron jobs...${NC}"
    echo ""

    # Create log directory
    mkdir -p "${LOG_DIR}"

    # Get current crontab
    local current_cron
    current_cron=$(get_current_cron)

    # Remove existing entries
    current_cron=$(echo "${current_cron}" | grep -v "${TRIAGE_MARKER}" | grep -v "${DIGEST_MARKER}")

    # Build triage cron entry (every N minutes)
    local triage_cron="*/${triage_interval} * * * *"
    local triage_entry="${triage_cron} ${TRIAGE_MARKER} cd ${WORKSPACE_ROOT} && ${TRIAGE_SCRIPT} >> ${LOG_DIR}/triage.log 2>&1 # Triage"

    # Build digest cron entries (multiple times per day)
    local digest_entries=""
    IFS=',' read -ra TIMES <<< "${digest_times}"
    for time in "${TIMES[@]}"; do
        time=$(echo "$time" | tr -d ' ')
        local digest_cron
        digest_cron=$(time_to_cron "$time")
        local digest_entry="${digest_cron} ${DIGEST_MARKER} cd ${WORKSPACE_ROOT} && ${DIGEST_SCRIPT} >> ${LOG_DIR}/digest.log 2>&1 # Digest"
        if [[ -z "${digest_entries}" ]]; then
            digest_entries="${digest_entry}"
        else
            digest_entries="${digest_entries}"$'\n'"${digest_entry}"
        fi
    done

    # Combine all entries
    local new_cron
    if [[ -z "${current_cron}" ]]; then
        new_cron="${triage_entry}"$'\n'"${digest_entries}"
    else
        new_cron="${current_cron}"$'\n'"${triage_entry}"$'\n'"${digest_entries}"
    fi

    # Install new crontab
    echo "${new_cron}" | crontab -

    log_info "Triage: every ${triage_interval} minutes"
    log_info "Digest: ${digest_times}"
    echo ""
    log_info "Cron jobs installed!"
    log_info "Logs: ${LOG_DIR}/"
}

uninstall_cron() {
    log_info "Removing cron jobs..."

    local current_cron
    current_cron=$(get_current_cron)

    # Remove both markers
    local new_cron
    new_cron=$(echo "${current_cron}" | grep -v "${TRIAGE_MARKER}" | grep -v "${DIGEST_MARKER}")

    if [[ -z "${new_cron// }" ]]; then
        crontab -r 2>/dev/null || true
        log_info "Crontab cleared"
    else
        echo "${new_cron}" | crontab -
        log_info "Cron jobs removed (other entries preserved)"
    fi
}

show_status() {
    echo ""
    echo -e "${CYAN}Google Workspace Agent - Cron Status${NC}"
    echo "=========================================="
    echo ""

    local current_cron
    current_cron=$(get_current_cron)

    if echo "${current_cron}" | grep -q "${TRIAGE_MARKER}"; then
        log_info "Triage job: INSTALLED"
        echo "${current_cron}" | grep "${TRIAGE_MARKER}" | sed 's/^/  /'
    else
        log_warn "Triage job: NOT INSTALLED"
    fi

    echo ""

    if echo "${current_cron}" | grep -q "${DIGEST_MARKER}"; then
        log_info "Digest job: INSTALLED"
        echo "${current_cron}" | grep "${DIGEST_MARKER}" | sed 's/^/  /'
    else
        log_warn "Digest job: NOT INSTALLED"
    fi

    echo ""
    echo "Log files:"
    if [[ -f "${LOG_DIR}/triage.log" ]]; then
        echo "  Triage: ${LOG_DIR}/triage.log ($(wc -l < "${LOG_DIR}/triage.log") lines)"
    fi
    if [[ -f "${LOG_DIR}/digest.log" ]]; then
        echo "  Digest: ${LOG_DIR}/digest.log ($(wc -l < "${LOG_DIR}/digest.log") lines)"
    fi
    echo ""
}

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------

main() {
    local triage_interval="${DEFAULT_TRIAGE_INTERVAL}"
    local digest_times="${DEFAULT_DIGEST_TIMES}"
    local action="install"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --triage-interval)
                shift
                triage_interval="$1"
                shift
                ;;
            --digest-times)
                shift
                digest_times="$1"
                shift
                ;;
            --uninstall)
                action="uninstall"
                shift
                ;;
            --status)
                action="status"
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    case "${action}" in
        install)
            install_cron "${triage_interval}" "${digest_times}"
            ;;
        uninstall)
            uninstall_cron
            ;;
        status)
            show_status
            ;;
    esac
}

main "$@"

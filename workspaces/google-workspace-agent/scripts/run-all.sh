#!/bin/bash

#===============================================================================
# Google Workspace Agent - Master Pipeline Runner
#===============================================================================
#
# Description:
#   Runs all Google Workspace Agent stages in sequence:
#   1. Triage    - Categorizes and prioritizes incoming items
#   2. Extraction - Extracts action items and key information
#   3. Calendar   - Creates calendar events from extracted items
#   4. Digest     - Generates daily/weekly digest summaries
#
# Usage:
#   ./run-all.sh [OPTIONS]
#
# Options:
#   --dry-run     Show what would be done without executing
#   --help        Display this help message
#
# Examples:
#   ./run-all.sh                  # Run full pipeline
#   ./run-all.sh --dry-run        # Preview pipeline execution
#
# Exit Codes:
#   0 - Success
#   1 - General error
#   2 - Dependency missing
#   3 - Stage execution failed
#
#===============================================================================

set -euo pipefail

#-------------------------------------------------------------------------------
# Configuration
#-------------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LOG_DIR="${WORKSPACE_ROOT}/logs"
LOG_FILE="${LOG_DIR}/pipeline-$(date +%Y%m%d-%H%M%S).log"

# Stages in execution order
STAGES=("triage" "extraction" "calendar" "digest")

# Minimum required commands
REQUIRED_COMMANDS=("python3" "pip3")

#-------------------------------------------------------------------------------
# Color Output (disable if not a terminal)
#-------------------------------------------------------------------------------

if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

#-------------------------------------------------------------------------------
# Logging Functions
#-------------------------------------------------------------------------------

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "[${timestamp}] [${level}] ${message}" | tee -a "${LOG_FILE}"
}

log_info() {
    log "INFO" "${GREEN}✓${NC} $*"
}

log_warn() {
    log "WARN" "${YELLOW}!${NC} $*"
}

log_error() {
    log "ERROR" "${RED}✗${NC} $*"
}

log_stage() {
    log "STAGE" "${BLUE}▶${NC} $*"
}

#-------------------------------------------------------------------------------
# Help Function
#-------------------------------------------------------------------------------

show_help() {
    cat << EOF
Google Workspace Agent - Master Pipeline Runner

Usage: $(basename "$0") [OPTIONS]

Options:
    --dry-run     Show what would be done without executing
    --help        Display this help message

Stages Executed (in order):
    1. triage      - Categorize and prioritize incoming items
    2. extraction  - Extract action items and key information
    3. calendar    - Create calendar events from extracted items
    4. digest      - Generate daily/weekly digest summaries

Examples:
    $(basename "$0")                  # Run full pipeline
    $(basename "$0") --dry-run        # Preview pipeline execution

Exit Codes:
    0 - Success
    1 - General error
    2 - Dependency missing
    3 - Stage execution failed

EOF
}

#-------------------------------------------------------------------------------
# Dependency Checking
#-------------------------------------------------------------------------------

check_dependencies() {
    log_info "Checking dependencies..."

    local missing=()

    for cmd in "${REQUIRED_COMMANDS[@]}"; do
        if ! command -v "${cmd}" &> /dev/null; then
            missing+=("${cmd}")
        fi
    done

    # Check for Python virtual environment or required packages
    if [[ ! -f "${WORKSPACE_ROOT}/requirements.txt" ]]; then
        log_warn "No requirements.txt found, skipping Python package check"
    fi

    # Check for credentials directory
    if [[ ! -d "${WORKSPACE_ROOT}/credentials" ]]; then
        log_warn "Credentials directory not found at ${WORKSPACE_ROOT}/credentials"
        log_warn "Google Workspace API authentication may fail"
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing required commands: ${missing[*]}"
        log_error "Please install them and try again"
        return 1
    fi

    log_info "All dependencies satisfied"
    return 0
}

#-------------------------------------------------------------------------------
# Stage Execution
#-------------------------------------------------------------------------------

run_stage() {
    local stage="$1"
    local dry_run="${2:-false}"
    local stage_script="${WORKSPACE_ROOT}/stages/${stage}/run.py"
    local start_time end_time duration

    log_stage "Starting stage: ${stage}"
    start_time=$(date +%s)

    if [[ "${dry_run}" == "true" ]]; then
        log_info "[DRY-RUN] Would execute: python3 ${stage_script}"
        return 0
    fi

    # Check if stage script exists
    if [[ ! -f "${stage_script}" ]]; then
        # Try shell script alternative
        stage_script="${WORKSPACE_ROOT}/stages/${stage}/run.sh"
        if [[ ! -f "${stage_script}" ]]; then
            log_error "Stage script not found: ${stage_script}"
            return 1
        fi
    fi

    # Execute the stage
    if python3 "${stage_script}" 2>&1 | tee -a "${LOG_FILE}"; then
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        log_info "Stage ${stage} completed in ${duration}s"
        return 0
    else
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        log_error "Stage ${stage} failed after ${duration}s"
        return 1
    fi
}

#-------------------------------------------------------------------------------
# Main Pipeline
#-------------------------------------------------------------------------------

main() {
    local dry_run=false
    local pipeline_start pipeline_end total_duration
    local failed_stages=()

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)
                dry_run=true
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

    # Initialize logging
    mkdir -p "${LOG_DIR}"
    log_info "=========================================="
    log_info "Google Workspace Agent Pipeline Started"
    log_info "=========================================="
    log_info "Dry run: ${dry_run}"
    log_info "Workspace: ${WORKSPACE_ROOT}"
    log_info "Log file: ${LOG_FILE}"

    pipeline_start=$(date +%s)

    # Check dependencies
    if ! check_dependencies; then
        log_error "Dependency check failed"
        exit 2
    fi

    # Run each stage in sequence
    for stage in "${STAGES[@]}"; do
        if ! run_stage "${stage}" "${dry_run}"; then
            failed_stages+=("${stage}")
            log_error "Pipeline stopped due to failure in stage: ${stage}"
            # Continue to collect all failed stages or break?
            # Breaking here to prevent cascading failures
            break
        fi
    done

    pipeline_end=$(date +%s)
    total_duration=$((pipeline_end - pipeline_start))

    # Summary
    log_info "=========================================="
    log_info "Pipeline Summary"
    log_info "=========================================="
    log_info "Total runtime: ${total_duration}s"

    if [[ ${#failed_stages[@]} -eq 0 ]]; then
        log_info "Status: ${GREEN}SUCCESS${NC} - All stages completed"
        log_info "=========================================="
        exit 0
    else
        log_error "Status: ${RED}FAILED${NC} - Stages failed: ${failed_stages[*]}"
        log_info "=========================================="
        exit 3
    fi
}

#-------------------------------------------------------------------------------
# Entry Point
#-------------------------------------------------------------------------------

main "$@"

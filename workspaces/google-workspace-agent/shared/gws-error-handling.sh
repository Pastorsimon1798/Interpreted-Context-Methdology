#!/usr/bin/env bash
#
# gws-error-handling.sh - Shared error handling for gws CLI calls
#
# Source this file in any script that uses gws:
#   source "${SHARED_DIR}/gws-error-handling.sh"
#
# This ensures consistent error handling and prevents silent failures.

# Check if a gws response contains an error
# Usage: check_gws_error "$response" "context description"
# Exits with code 1 if error found, returns 0 otherwise
check_gws_error() {
    local response="$1"
    local context="${2:-gws API call}"

    # Check for auth errors and API errors
    if echo "${response}" | grep -q "invalid_grant\|authError\|Authentication failed\|\"code\": 401\|\"code\":403\|\"error\""; then
        echo "==========================================" >&2
        echo "ERROR: ${context}" >&2
        echo "==========================================" >&2
        echo "" >&2
        echo "Google API Error:" >&2
        echo "${response}" | head -10 >&2
        echo "" >&2
        echo "Your Google token may have expired." >&2
        echo "Run: gws auth login" >&2
        return 1
    fi

    return 0
}

# Run a gws command with proper error checking
# Usage: gws_safe "context" gws command args...
# Returns the response on success, exits on error
gws_safe() {
    local context="$1"
    shift

    local response
    response=$("$@" 2>&1)
    local exit_code=$?

    # Check command exit code
    if [[ $exit_code -ne 0 ]]; then
        # Check if it's an auth error in the response
        if check_gws_error "${response}" "${context}"; then
            # Non-auth error, still report it
            echo "ERROR: ${context}" >&2
            echo "Command failed with exit code ${exit_code}" >&2
            echo "Response: ${response}" >&2
            return 1
        fi
        return 1
    fi

    # Check response for errors even if exit code was 0
    if ! check_gws_error "${response}" "${context}"; then
        return 1
    fi

    echo "${response}"
    return 0
}

# Filter out the "Using keyring" message but preserve errors
# Usage: response=$(gws ... | filter_gws_output)
filter_gws_output() {
    grep -v "^Using keyring"
}

# Check if response is valid JSON with expected structure
# Usage: validate_json "$response" ".messages"  # checks for .messages array
validate_json() {
    local response="$1"
    local path="${2:-.}"

    if ! echo "${response}" | jq -e "${path}" >/dev/null 2>&1; then
        echo "ERROR: Invalid JSON response - expected path: ${path}" >&2
        echo "Response: ${response:0:200}" >&2
        return 1
    fi

    return 0
}

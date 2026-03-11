#!/bin/bash
# kb-create.sh - Create a knowledge base document
# Usage: ./kb-create.sh <category> <title> [content]
#
# Categories: inbox, project, area, resource, archive

set -e

# Load config
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../shared/drive-ids.sh"

CATEGORY="$1"
TITLE="$2"
CONTENT="${3:-}"

if [[ -z "$CATEGORY" || -z "$TITLE" ]]; then
    echo "Usage: $0 <category> <title> [content]"
    echo "Categories: inbox, project, area, resource, archive"
    exit 1
fi

# Map category to folder ID
case "$CATEGORY" in
  inbox)     FOLDER_ID="$INBOX_ID" ;;
  project)   FOLDER_ID="$PROJECTS_ID" ;;
  area)      FOLDER_ID="$AREAS_ID" ;;
  resource)  FOLDER_ID="$RESOURCES_ID" ;;
  archive)   FOLDER_ID="$ARCHIVE_ID" ;;
  *)
    echo "Unknown category: $CATEGORY"
    echo "Valid categories: inbox, project, area, resource, archive"
    exit 1
    ;;
esac

# Generate KB ID
DOC_ID="KB-$(date +%Y%m%d-%H%M%S)-$(echo "$TITLE" | tr -cd 'a-zA-Z0-9' | head -c 20)"

echo "Creating document: $TITLE"
echo "Category: $CATEGORY"
echo "KB ID: $DOC_ID"

# Create document
RESULT=$(gws drive files create --params '{"fields":"id,name"}' --json "{
  \"name\": \"$TITLE\",
  \"mimeType\": \"application/vnd.google-apps.document\",
  \"parents\": [\"$FOLDER_ID\"]
}")

DRIVE_ID=$(echo "$RESULT" | jq -r '.id')

if [[ -z "$DRIVE_ID" || "$DRIVE_ID" == "null" ]]; then
    echo "Error: Failed to create document"
    echo "$RESULT"
    exit 1
fi

# Add content if provided
if [[ -n "$CONTENT" ]]; then
    echo "Adding content to document..."
    gws docs +write --document "$DRIVE_ID" --text "$CONTENT" > /dev/null 2>&1 || true
fi

# Add to index sheet
DOC_URL="https://docs.google.com/document/d/$DRIVE_ID/edit"
TODAY=$(date +%Y-%m-%d)

echo "Adding to Master Index..."
gws sheets +append --spreadsheet "$INDEX_SHEET_ID" --json-values "[[\"$DOC_ID\",\"$TITLE\",\"$CATEGORY\",\"$DRIVE_ID\",\"$DOC_URL\",\"\",\"manual\",\"\",\"$TODAY\",\"$TODAY\",\"\"]]" > /dev/null

echo ""
echo "=== Document Created ==="
echo "URL: $DOC_URL"
echo "KB ID: $DOC_ID"
echo "Drive ID: $DRIVE_ID"

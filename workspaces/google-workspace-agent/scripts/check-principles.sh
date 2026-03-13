#!/bin/bash
# Simple check: ensure scripts stay under size limits

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPTS_DIR"

echo "Script Size Check (PRINCIPLES.md limits)"
echo "=========================================="

# Check line counts
for f in run-triage.sh run-calendar.sh run-tasks.sh kb-create.sh; do
    if [ -f "$f" ]; then
        lines=$(wc -l < "$f" | tr -d ' ')
        echo "$f: $lines lines"
        if [ "$f" = "run-triage.sh" ] && [ "$lines" -gt 200 ]; then
            echo "  ⚠️  EXCEEDS 200 LINE LIMIT"
        fi
        if [ "$f" = "run-calendar.sh" ] && [ "$lines" -gt 200 ]; then
            echo "  ⚠️  EXCEEDS 200 LINE LIMIT"
        fi
        if [ "$f" = "run-tasks.sh" ] && [ "$lines" -gt 200 ]; then
            echo "  ⚠️  EXCEEDS 200 LINE LIMIT"
        fi
    fi
done

echo ""
echo "See PRINCIPLES.md for guidelines"

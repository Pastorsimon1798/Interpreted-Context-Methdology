#!/bin/bash
# run-monitor.sh - Autonomous research monitor (no Claude needed)
# Fetches from APIs, filters by keywords, emails digest
#
# Usage:
#   ./run-monitor.sh am|pm|install|test

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PIPELINE_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
LOG_DIR="$PIPELINE_ROOT/logs"
OUTPUT_DIR="$SCRIPT_DIR/../output"
TODAY=$(date +%Y-%m-%d)
PERIOD="${1:-$(date +%H | awk '{if($1>=17) print "pm"; else print "am"}')}"

# Config
RECIPIENT="simon@puenteworks.com"
KNOWLEDGE_BASE="$HOME/knowledge-base"
OUTPUT_FILE="$OUTPUT_DIR/raw-$TODAY-$PERIOD.md"

mkdir -p "$LOG_DIR" "$OUTPUT_DIR"

# Keywords from knowledge base structure
KEYWORDS="agent|multi-agent|LangGraph|LLM|GPT|Claude|RAG|prompt|fine-tuning|embedding|retrieval|OpenAI|Anthropic|machine learning|AI"

log() { echo "[$(date '+%H:%M:%S')] $1"; }

# Fetch from arXiv (last 24h papers in cs.AI, cs.CL, cs.LG)
fetch_arxiv() {
    log "Fetching arXiv papers..."
    local xml=$(curl -s "http://export.arxiv.org/api/query?search_query=cat:cs.AI+OR+cat:cs.CL+OR+cat:cs.LG&start=0&max_results=10&sortBy=submittedDate&sortOrder=descending")

    # Parse XML using sed/awk (no jq needed for XML)
    echo "$xml" | awk '
    BEGIN { title=""; link=""; in_entry=0 }
    /<entry>/ { in_entry=1; title=""; link="" }
    /<\/entry>/ {
        if (in_entry && title != "") {
            # Filter by keywords
            if (tolower(title) ~ /agent|llm|language model|rag|prompt|multi/ ) {
                print "- **" title "**"
                print "  Link: " link
                print ""
            }
        }
        in_entry=0
    }
    /<title>/ && in_entry {
        gsub(/<title>|<\/title>/, "")
        gsub(/^[ \t]+|[ \t]+$/, "")
        if (title == "") title = $0
    }
    /<id>/ && in_entry && link == "" {
        gsub(/<id>|<\/id>/, "")
        gsub(/^[ \t]+|[ \t]+$/, "")
        link = $0
    }
    ' | head -20
}

# Fetch from Hacker News (top AI stories)
fetch_hn() {
    log "Fetching Hacker News..."
    local stories=$(curl -s "https://hacker-news.firebaseio.com/v0/topstories.json" | tr ',' '\n' | tr -d '[] ' | head -50)
    local count=0

    for id in $stories; do
        if [[ $count -ge 10 ]]; then break; fi

        local story=$(curl -s "https://hacker-news.firebaseio.com/v0/item/$id.json")
        local title=$(echo "$story" | grep -oE '"title":"[^"]*"' | sed 's/"title":"//; s/"$//')
        local score=$(echo "$story" | grep -oE '"score":[0-9]+' | sed 's/"score"://')
        local url=$(echo "$story" | grep -oE '"url":"[^"]*"' | sed 's/"url":"//; s/"$//')

        # Filter by keywords and minimum score
        if [[ -n "$title" ]] && [[ $score -ge 50 ]]; then
            if echo "$title" | grep -iE "$KEYWORDS" > /dev/null 2>&1; then
                echo "- **$title** (Score: $score)"
                if [[ -n "$url" ]]; then
                    echo "  Link: $url"
                fi
                echo ""
                ((count++))
            fi
        fi
    done
}

# Fetch from Reddit (hot posts from AI subreddits)
fetch_reddit() {
    log "Fetching Reddit..."
    local subreddits=("LocalLLaMA" "MachineLearning" "AI_Agents")

    for sub in "${subreddits[@]}"; do
        local data=$(curl -s "https://www.reddit.com/r/$sub/hot.json?limit=5" -A "ResearchMonitor/1.0" 2>/dev/null)

        if [[ -n "$data" ]]; then
            echo "### r/$sub"
            echo "$data" | grep -oE '"title":"[^"]*"' | sed 's/"title":"//; s/"$//' | while read -r title; do
                # Filter by keywords
                if echo "$title" | grep -iE "$KEYWORDS" > /dev/null 2>&1; then
                    echo "- $title"
                fi
            done | head -3
            echo ""
        fi
    done
}

# Fetch Karpathy's repos (dedicated tracker)
fetch_karpathy() {
    log "Fetching Karpathy releases..."
    local data=$(curl -s "https://api.github.com/users/karpathy/repos?sort=updated&per_page=10" 2>/dev/null)

    if [[ -n "$data" ]]; then
        echo "### Andrej Karpathy's Repos"
        echo ""
        echo "$data" | grep -E '"name"|"description"|"stargazers_count"|"html_url"|"pushed_at"' | \
        awk '
        /"name"/ { name = $0; gsub(/.*"name": "|".*/, "", name) }
        /"description"/ { desc = $0; gsub(/.*"description": "|".*/, "", desc) }
        /"stargazers_count"/ { stars = $0; gsub(/.*"stargazers_count": |,.*/, "", stars) }
        /"html_url"/ { url = $0; gsub(/.*"html_url": "|".*/, "", url) }
        /"pushed_at"/ {
            pushed = $0; gsub(/.*"pushed_at": "|".*/, "", pushed)
            gsub(/T.*/, "", pushed)
            if (name != "") {
                print "- **" name "** (⭐ " stars ", updated: " pushed ")"
                if (desc != "" && desc != "null") print "  " desc
                print "  Link: " url
                print ""
            }
            name = ""; desc = ""; stars = ""; url = ""; pushed = ""
        }
        ' | head -10
    fi
}

# Fetch from GitHub (trending repos in ai-agents topic)
fetch_github() {
    log "Fetching GitHub..."
    local query="ai-agents+OR+langgraph+OR+llm-agent+OR+rag"
    local data=$(curl -s "https://api.github.com/search/repositories?q=topic:($query)&sort=updated&order=desc&per_page=10" 2>/dev/null)

    if [[ -n "$data" ]]; then
        echo "$data" | grep -E '"full_name"|"description"|"stargazers_count"|"html_url"' | \
        awk '
        /"full_name"/ { name = $0; gsub(/.*"full_name": "|".*/, "", name) }
        /"description"/ { desc = $0; gsub(/.*"description": "|".*/, "", desc) }
        /"stargazers_count"/ { stars = $0; gsub(/.*"stargazers_count": |,.*/, "", stars) }
        /"html_url"/ {
            url = $0; gsub(/.*"html_url": "|".*/, "", url)
            if (name != "" && stars > 10) {
                print "- **" name "** (⭐ " stars ")"
                if (desc != "" && desc != "null") print "  " desc
                print "  Link: " url
                print ""
            }
            name = ""; desc = ""; stars = ""; url = ""
        }
        ' | head -15
    fi
}

# Read knowledge base structure for context
read_kb_structure() {
    log "Reading knowledge base structure..."
    if [[ -d "$KNOWLEDGE_BASE" ]]; then
        find "$KNOWLEDGE_BASE" -type d -maxdepth 2 2>/dev/null |
        grep -v "^\.$" |
        sed "s|$KNOWLEDGE_BASE/||" |
        grep -v "^$" |
        sort
    else
        echo "Knowledge base not found at $KNOWLEDGE_BASE"
    fi
}

# Build the digest
build_digest() {
    local kb_structure=$(read_kb_structure)
    local kb_topics=$(echo "$kb_structure" | grep -E "resources|areas" | head -10)

    log "Building digest..."

    cat > "$OUTPUT_FILE" << EOF
# AI Discovery Digest - $TODAY ($PERIOD)

## Your Knowledge Base Topics
$(echo "$kb_structure" | head -15)

---

## Hacker News (AI-related, Score ≥50)

$(fetch_hn)

---

## Reddit Hot Posts

$(fetch_reddit)

---

## arXiv Papers (Recent)

$(fetch_arxiv)

---

## GitHub Repos (AI Agents)

$(fetch_github)

---

## Karpathy Watch

$(fetch_karpathy)

---

*Generated: $(date)*
*Say "monitor" in Claude to get enhanced digest with scoring*
EOF

    log "Digest saved to $OUTPUT_FILE"
}

# Send email via GWS
send_email() {
    if [[ ! -f "$OUTPUT_FILE" ]]; then
        log "ERROR: No digest file found"
        return 1
    fi

    local body=$(cat "$OUTPUT_FILE")
    local subject="🔬 AI Discovery Digest - $TODAY ($PERIOD)"

    log "Sending email to $RECIPIENT..."

    echo "$body" | gws gmail +send \
        --to "$RECIPIENT" \
        --subject "$subject" \
        --body "$(cat)" 2>&1 | tee -a "$LOG_DIR/email.log"

    if [[ ${PIPESTATUS[1]} -eq 0 ]]; then
        log "Email sent successfully"
        return 0
    else
        log "Email failed - digest saved locally at $OUTPUT_FILE"
        return 1
    fi
}

# Install cron job
install_cron() {
    local script_path="$SCRIPT_DIR/run-monitor.sh"

    # Remove old entry if exists
    crontab -l 2>/dev/null | grep -v "run-monitor.sh" | crontab -

    # Add new entries
    (crontab -l 2>/dev/null
     echo "# Research Pipeline Monitor - runs twice daily"
     echo "0 9 * * * $script_path am >> $LOG_DIR/monitor-am.log 2>&1"
     echo "0 17 * * * $script_path pm >> $LOG_DIR/monitor-pm.log 2>&1"
    ) | crontab -

    log "Cron installed. Monitor runs at 9 AM and 5 PM daily."
    echo ""
    echo "Current crontab:"
    crontab -l | grep -A2 "Research Pipeline"
    echo ""
    echo "Logs: $LOG_DIR/"
    echo "To uninstall: crontab -e and remove the lines"
}

# Main
case "${1:-}" in
    am|pm)
        log "=== Running $PERIOD discovery scan ==="
        build_digest
        # Email handled by Claude via "monitor email" command
        ;;
    install)
        install_cron
        ;;
    test)
        log "=== Test run ==="
        PERIOD="test"
        build_digest
        # Email handled by Claude via "monitor email" command
        ;;
    status)
        echo "=== Cron Jobs ==="
        crontab -l 2>/dev/null | grep -E "run-monitor|Research" || echo "None installed"
        echo ""
        echo "=== Recent Digests ==="
        ls -lt "$OUTPUT_DIR"/*.md 2>/dev/null | head -5 || echo "None yet"
        echo ""
        echo "=== Last Log ==="
        tail -20 "$LOG_DIR/monitor-am.log" 2>/dev/null || echo "No logs yet"
        ;;
    *)
        echo "Usage: $0 [am|pm|install|test|status]"
        echo ""
        echo "Commands:"
        echo "  am|pm   - Run discovery scan (saves raw data, no email)"
        echo "  install - Install cron jobs (9 AM + 5 PM daily)"
        echo "  test    - Test run now"
        echo "  status  - Show installed jobs and recent digests"
        echo ""
        echo "Email workflow:"
        echo "  Say 'monitor' in Claude to get AI-enhanced digest"
        echo "  Say 'monitor email' to send enhanced digest via email"
        ;;
esac

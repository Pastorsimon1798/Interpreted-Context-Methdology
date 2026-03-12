# Plan: Autonomous Research Monitor with LM Studio

## Context

**Problem:** The current `run-monitor.sh` script fetches raw data but lacks AI-powered relevance scoring and personalization. User wants fully autonomous operation (cron → AI processing → email digest) without using Anthropic API.

**Solution:** Integrate LM Studio as local AI backend. Cron triggers script → LM Studio processes raw data with local model → enhanced digest emailed automatically.

**User Preferences:**
- Local inference (privacy, no per-run cost)
- LM Studio as backend (Anthropic-compatible API)
- Full KB content mining (not just folder names)
- Twice-daily operation (9 AM, 5 PM)

---

## Part 1: LM Studio Setup

### 1.1 Install LM Studio
```bash
# Download from lmstudio.ai or use Homebrew
brew install --cask lm-studio
```

### 1.2 Download a Model
Recommended models for Mac Mini:
- **Qwen 2.5 14B** - Good balance of quality/speed
- **Llama 3.2 11B** - Strong reasoning
- **Mistral Nemo 12B** - Fast and capable

In LM Studio: Search → Download (Q4_K_M quantization recommended)

### 1.3 Start API Server
```bash
# CLI approach
lms server start --model qwen2.5-14b

# Or enable in LM Studio GUI: Developer tab → Start server
# Default: http://localhost:1234
```

### 1.4 Test Connection
```bash
curl http://localhost:1234/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "local-model", "messages": [{"role": "user", "content": "Hello"}]}'
```

---

## Part 2: Modify run-monitor.sh

### 2.1 Add AI Processing Function

**File:** `stages/00-monitor/scripts/run-monitor.sh`

Add new function `enhance_with_ai()`:
```bash
# AI enhancement using LM Studio
enhance_with_ai() {
    local raw_file="$1"
    local output_file="$2"
    local kb_topics=$(mine_kb_content)

    log "Enhancing with LM Studio..."

    # Build prompt for AI
    local prompt=$(cat << ENDPROMPT
You are a research curator. Analyze this raw discovery data and create a prioritized digest.

## Knowledge Base Topics (for relevance scoring)
$kb_topics

## Raw Discovery Data
$(cat "$raw_file")

## Task
1. Score each item for relevance to the KB topics (1-10)
2. Group into tiers: MUST KNOW (8+), WORTH TIME (5-7), BACKGROUND (3-4)
3. Identify knowledge gaps (items that match interests but missing from KB)
4. Output formatted digest with scores and brief relevance explanations
ENDPROMPT
)

    # Call LM Studio API
    curl -s http://localhost:1234/v1/chat/completions \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"local-model\",
            \"messages\": [{\"role\": \"user\", \"content\": $(echo "$prompt" | jq -Rs .)}],
            \"temperature\": 0.3,
            \"max_tokens\": 4000
        }" | jq -r '.choices[0].message.content' > "$output_file"
}
```

### 2.2 Add KB Content Mining

Add function `mine_kb_content()`:
```bash
# Mine knowledge base for topic context
mine_kb_content() {
    local kb_path="$HOME/knowledge-base"

    if [[ ! -d "$kb_path" ]]; then
        echo "Knowledge base not found"
        return
    fi

    # Extract titles, headers, and first paragraph from each file
    find "$kb_path" -name "*.md" -type f 2>/dev/null | head -50 | while read -r file; do
        # Get filename as topic
        local topic=$(basename "$file" .md)

        # Get first H1 or H2 header
        local header=$(grep -m1 "^#" "$file" 2>/dev/null | sed 's/^#* //')

        # Get first paragraph (non-empty, non-header lines)
        local desc=$(awk '/^$/ {if(p) exit; next} /^#/ {next} {p=1; print; if(length>100) exit}' "$file" 2>/dev/null | head -2)

        if [[ -n "$header" ]]; then
            echo "- **$topic**: $header"
            [[ -n "$desc" ]] && echo "  $desc"
        fi
    done
}
```

### 2.3 Update Main Flow

Modify the main case statement:
```bash
case "${1:-}" in
    am|pm)
        log "=== Running $PERIOD discovery scan ==="
        build_digest  # Creates raw-YYYY-MM-DD-*.md

        # NEW: AI enhancement
        local raw_file="$OUTPUT_FILE"
        local enhanced_file="$OUTPUT_DIR/discovery-$TODAY-$PERIOD.md"
        enhance_with_ai "$raw_file" "$enhanced_file"

        # Email the enhanced version
        send_email "$enhanced_file"
        ;;
    # ... rest unchanged
esac
```

---

## Part 3: Cron Setup

### 3.1 Ensure LM Studio Server Starts on Boot

Create launch agent (macOS):
```xml
<!-- ~/Library/LaunchAgents/com.lmstudio.server.plist -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.lmstudio.server</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/lms</string>
        <string>server</string>
        <string>start</string>
        <string>--model</string>
        <string>qwen2.5-14b</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
```

Load it:
```bash
launchctl load ~/Library/LaunchAgents/com.lmstudio.server.plist
```

### 3.2 Install Monitor Cron Jobs

```bash
./stages/00-monitor/scripts/run-monitor.sh install
```

This adds:
```
0 9 * * * /path/to/run-monitor.sh am
0 17 * * * /path/to/run-monitor.sh pm
```

---

## Part 4: Run KB Research Topics

After monitor is set up, execute the 5 pending research topics:

| # | Command | Output Location |
|---|---------|-----------------|
| 1 | `research evaluation paradigms for AI output` | `~/knowledge-base/research/evaluation-paradigms.md` |
| 2 | `research neurodiversity cognitive advantages AI assistance` | `~/knowledge-base/research/neurodiversity-ai.md` |
| 3 | `research model selection criteria Claude GPT task matching` | `~/knowledge-base/research/model-selection.md` |
| 4 | `research human AI task delegation boundaries skills` | `~/knowledge-base/research/skills-inventory.md` |
| 5 | `research 90 day AI collaboration skill development plan` | `~/knowledge-base/planning/90-day-roadmap.md` |

---

## Files to Modify

| File | Changes |
|------|---------|
| `stages/00-monitor/scripts/run-monitor.sh` | Add `enhance_with_ai()`, `mine_kb_content()`, update main flow |
| `stages/00-monitor/CONTEXT.md` | Document LM Studio integration |
| `~/Library/LaunchAgents/com.lmstudio.server.plist` | NEW - Auto-start LM Studio server |

---

## Verification

1. **Test LM Studio server:**
   ```bash
   lms server start
   curl http://localhost:1234/v1/models
   ```

2. **Test KB mining:**
   ```bash
   ./stages/00-monitor/scripts/run-monitor.sh test
   # Check output/raw-* and output/discovery-* files
   ```

3. **Test email:**
   ```bash
   ./stages/00-monitor/scripts/run-monitor.sh test
   # Verify email received with enhanced digest
   ```

4. **Verify cron:**
   ```bash
   ./stages/00-monitor/scripts/run-monitor.sh status
   crontab -l | grep run-monitor
   ```

---

## Execution Order

1. Install LM Studio + download model
2. Test LM Studio API server
3. Modify `run-monitor.sh` with AI enhancement
4. Test locally with `./run-monitor.sh test`
5. Set up launch agent for LM Studio
6. Install cron jobs
7. Run KB research topics (5 sequential pipelines)

---

## Prerequisites

- [ ] LM Studio installed
- [ ] Model downloaded (Qwen 2.5 14B or equivalent)
- [ ] `jq` installed for JSON processing (`brew install jq`)
- [ ] `~/knowledge-base/` directory exists with some content
- [ ] GWS CLI configured for email sending

---

## Notes for Future Agent

- LM Studio CLI is already installed at: `/Users/simongonzalezdecruz/.lmstudio/bin/lms`
- The current `run-monitor.sh` has 286 lines and includes functions: `fetch_arxiv()`, `fetch_hn()`, `fetch_reddit()`, `fetch_github()`, `read_kb_structure()`, `build_digest()`, `send_email()`, `install_cron()`
- This plan enables fully autonomous operation without Anthropic API costs

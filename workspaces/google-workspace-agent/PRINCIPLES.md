# GWS Agent Principles

These principles prevent the workspace from becoming over-engineered again.

## The Core Rule

> **Use the tool as designed. GWS-CLI has `+` helpers FOR AI agents.**

## What Went Wrong Before

The previous implementation tried to make **scripts** smart instead of making the **AI** smart:

| Wrong | Right |
|-------|-------|
| Bash has 50+ regex patterns for "urgent" | AI reads rules and decides what's urgent |
| `run-triage.sh` was 1074 lines | `run-triage.sh` is 147 lines (calls `+triage`) |
| 54 log files generated in one day | AI processes once, writes one report |
| Scripts retry on failure in loops | AI handles errors intelligently |

## The Ceramics-Instagram Comparison

| Metric | GWS (Failed) | Instagram (Success) |
|--------|--------------|---------------------|
| Script size | 1,000+ line monolith | 6 focused scripts |
| AI's role | Offloaded to bash regex | AI does creative work |
| Tool usage | Ignored `+triage` helper | Uses appropriate tools |

## Script Size Limits

| Script | Max Lines | Reason |
|--------|-----------|--------|
| `run-triage.sh` | 200 | Just calls `+triage`, returns JSON |
| `run-calendar.sh` | 200 | Just calls `+agenda`, returns JSON |
| `run-tasks.sh` | 200 | Just calls raw API, returns JSON |
| `run-digest.sh` | 750 | More complex but still AI-driven |

**If a script exceeds these limits, it's doing too much.**

## What Scripts Do

Scripts are **thin wrappers** that:
1. Call GWS-CLI helpers
2. Return JSON for AI to process
3. Handle auth errors gracefully

Scripts do NOT:
- ❌ Embed categorization logic in bash
- ❌ Use regex to detect "urgent" or "promotional"
- ❌ Retry in loops that create 50+ log files
- ❌ Make decisions - AI makes decisions

## What AI Does

AI is **intelligent** and:
1. Reads JSON from scripts
2. Applies rules from `shared/*.md` files
3. Makes categorization decisions
4. Decides what to archive/schedule/create
5. Calls scripts to execute decisions

## Red Flags

If you see these, STOP and reconsider:

| Red Flag | What It Means |
|----------|---------------|
| Script over 200 lines | Logic belongs in AI, not bash |
| Regex patterns in bash | AI should categorize, not regex |
| Retry loops | AI should handle errors, not loops |
| Multiple log files per run | One report per run, not many logs |
| "Smart" script logic | Intelligence belongs in AI |

## GWS-CLI Helper Reference

```bash
# Gmail - designed for AI agents
gws gmail +triage --max 100 --format json     # Inbox summary
gws gmail +send --to "..." --subject "..."    # Send AI email
gws gmail +reply --message-id "..." --body "..."  # Reply

# Calendar - designed for AI agents
gws calendar +agenda --today --format json    # Today's schedule
gws calendar +agenda --week --format json     # Week's schedule
gws calendar +insert --summary "..." --start "..."  # Create event

# Drive - designed for AI agents
gws drive +upload --file "..." --name "..."   # Upload file

# Tasks - no helpers, use raw API
gws tasks tasks list --params '{"tasklist":"@default"}'
gws tasks tasks insert --params '{"tasklist":"@default"}' --json '{...}'
```

## When In Doubt

Ask: **"Is the script doing intelligent work, or just returning data?"**

- If script is intelligent → Move logic to AI
- If script returns data → Keep it thin

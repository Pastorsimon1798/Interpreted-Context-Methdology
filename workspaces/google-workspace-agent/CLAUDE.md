# Google Workspace Agent

An ADHD-friendly agent that monitors inbox, triages emails, extracts valuable information for a knowledge base, and manages calendaring. Read-only by default.

## Key Principle

> **Use the tool as designed. GWS-CLI has `+` helpers FOR AI agents.**

The `+` prefix commands are specifically for common AI tasks:
- `gws gmail +triage` - Get inbox summary for AI to process
- `gws calendar +agenda` - Get schedule for AI to analyze
- `gws gmail +send` - Send AI-composed email

**The AI categorizes, decides, and acts. Scripts are thin wrappers that just call GWS helpers.**

## Folder Map

```
google-workspace-agent/
├── CLAUDE.md              (you are here)
├── CONTEXT.md             (start here for task routing)
├── setup/                 (onboarding questionnaire and gws setup)
├── skills/                (persona and workflow skills)
│   └── persona-adhd-assistant/
├── stages/
│   ├── 01-triage/         (inbox monitoring and prioritization)
│   ├── 02-extraction/     (knowledge extraction to PARA folders)
│   ├── 03-calendar/       (event creation and focus time)
│   └── 04-digest/         (consolidated activity summary)
└── shared/                (cross-stage reference files)
```

## Triggers

| Keyword | Action |
|---------|--------|
| `setup` | Run onboarding questionnaire and configure workspace |
| `status` | Show pipeline completion for all stages |
| `resume` | Read PROGRESS.md and continue from last checkpoint |
| `triage` | Run inbox triage immediately |
| `digest` | Generate digest from last run |
| `standup` | Generate daily standup report (emails, tasks, calendar) |
| `agenda` | Show today's calendar agenda |
| `focus` | Schedule focus time block |
| `tasks` | Show/sync tasks from triage |
| `prep` | Prepare context for next meeting |

## GWS-CLI Helper Reference

### Gmail Helpers (for AI)
```bash
# Get inbox for AI to triage - AI categorizes using its intelligence
gws gmail +triage --max 100 --format json

# Send AI-composed email
gws gmail +send --to "user@example.com" --subject "Hello" --body "..."

# Reply to thread (handles threading automatically)
gws gmail +reply --message-id "..." --body "..."

# Archive email with label (AI decides category)
gws gmail users messages modify \
  --params '{"userId":"me","id":"MESSAGE_ID"}' \
  --json '{"removeLabelIds":["INBOX"],"addLabelIds":["Label_7"]}'
```

### Calendar Helpers (for AI)
```bash
# Get schedule for AI to analyze
gws calendar +agenda --today --format json
gws calendar +agenda --week --format json
gws calendar +agenda --days 3 --calendar "Work"

# Create event (AI can schedule)
gws calendar +insert --summary "Meeting" --start "2026-03-12T14:00:00"
```

### Drive Helpers (for AI)
```bash
# Upload file with auto metadata
gws drive +upload --file "./report.pdf" --name "Report"
```

### Raw API (Tasks - no helpers)
```bash
# Tasks - use raw API directly
gws tasks tasks list --params '{"tasklist":"@default","maxResults":100}'
gws tasks tasks insert --params '{"tasklist":"@default"}' --json '{"title":"..."}'
```

## AI-Driven Workflow

### Triage Inbox

**The AI does the work:**
1. Call `gws gmail +triage --max 100 --format json`
2. AI reads `shared/prioritization-rules.md` and `shared/email-categories.md`
3. AI categorizes each email using its intelligence (not bash regex)
4. AI decides what to archive based on rules
5. AI archives by calling `gws gmail users messages modify`

**NOT:**
- ❌ Running bash scripts with 50+ regex patterns
- ❌ Complex shell logic for categorization
- ❌ Retry loops that create 54 log files

### Schedule Calendar

**The AI does the work:**
1. Call `gws calendar +agenda --today --format json`
2. AI reads `shared/calendar-preferences.md`
3. AI identifies gaps and decides when to schedule
4. AI creates events via `gws calendar +insert`

## Label Reference (For AI Categorization)

| Label ID | Name | Use For |
|----------|------|---------|
| Label_10 | Jobs | LinkedIn, job alerts, career |
| Label_7 | Newsletters | Substack, digests, regular updates |
| Label_11 | Promos | Marketing, offers, unsubscribe links |
| Label_6 | Receipts | Orders, confirmations, invoices |
| Label_18 | Social | Facebook, Twitter, Instagram, etc. |
| Label_19 | Low-Priority | Everything else |

Discover label IDs with: `gws gmail users labels list --params '{"userId":"me"}'`

## Thin Script Wrappers

Scripts are minimal wrappers around GWS-CLI. They do NOT embed intelligence.

| Script | Purpose | Intelligence |
|--------|---------|--------------|
| `run-triage.sh` | Calls `+triage`, returns JSON | AI categorizes |
| `run-calendar.sh` | Calls `+agenda`, returns JSON | AI schedules |
| `run-tasks.sh` | Calls raw Tasks API | AI prioritizes |

## What to Load

| Task | Load These | Do NOT Load |
|------|-----------|-------------|
| Triage inbox | `shared/prioritization-rules.md`, `shared/email-categories.md` | Extraction rules, calendar files |
| Extract knowledge | `02-extraction/CONTEXT.md`, `shared/extraction-rules.md` | Triage files, calendar files |
| Sync calendar | `shared/calendar-preferences.md` | Digest template, extraction rules |
| Generate digest | `04-digest/CONTEXT.md` | All upstream stage CONTEXT files |

## Trust-Based Autonomy

The `{{TRUST_LEVEL}}` placeholder controls checkpoint behavior:

| Level | Behavior |
|-------|----------|
| `supervised` | Pause at every checkpoint for user review |
| `partial` | Skip checkpoints for trusted stages |
| `autonomous` | Run all stages, user only sees digest |

## Prerequisites

- Node.js 18+
- `@googleworkspace/cli` installed globally
- Google Cloud project with OAuth configured

See `setup/gws-setup.md` for installation instructions.

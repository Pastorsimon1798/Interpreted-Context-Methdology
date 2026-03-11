# Google Workspace Agent

An ADHD-friendly agent that monitors inbox, triages emails, extracts valuable information for a knowledge base, and manages calendaring. Read-only by default.

## Folder Map

```
google-workspace-agent/
├── CLAUDE.md              (you are here)
├── CONTEXT.md             (start here for task routing)
├── setup/                 (onboarding questionnaire and gws setup)
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
| `triage` | Run inbox triage immediately |
| `digest` | Generate digest from last run |
| `standup` | Generate daily standup report (emails, tasks, calendar) |
| `agenda` | Show today's calendar agenda |
| `focus` | Schedule focus time block |
| `tasks` | Show/sync tasks from triage |
| `prep` | Prepare context for next meeting |
| `notify` | Send Chat notification |

## Routing

| Task | Go To |
|------|-------|
| Monitor and triage inbox | `stages/01-triage/CONTEXT.md` |
| Extract knowledge from emails | `stages/02-extraction/CONTEXT.md` |
| Create calendar events | `stages/03-calendar/CONTEXT.md` |
| Generate activity digest | `stages/04-digest/CONTEXT.md` |
| Initial setup | `setup/questionnaire.md` |

## GWS Service Matrix

| Service | Features | Integration |
|---------|----------|-------------|
| **Gmail** | `+triage`, `+send`, `+reply` | `scripts/run-triage.sh`, `scripts/run-digest.sh` |
| **Calendar** | `+agenda`, `+insert`, `freebusy` | `scripts/run-calendar.sh` |
| **Tasks** | `list`, `create`, `sync`, `agenda` | `scripts/run-tasks.sh` |
| **Drive** | Files CRUD | `scripts/kb-create.sh` |
| **Workflows** | Cross-service helpers | `shared/gws-workflows.sh` |

## Workflow Commands

### Daily Routines

```bash
# Morning routine
./scripts/run-calendar.sh agenda                    # See today's schedule
./shared/gws-workflows.sh standup                   # Full standup report
./scripts/run-tasks.sh agenda                       # Task agenda

# Process inbox
./scripts/run-triage.sh                             # Triage emails
./scripts/run-tasks.sh sync                         # Create tasks from action items

# Schedule focus time
./scripts/run-calendar.sh insert "[Focus Time]"     # Block focus time
```

### Email Workflows

```bash
# Create task from email
./shared/gws-workflows.sh email-to-task <message_id>

# Send digest to inbox
./scripts/run-digest.sh --email
```

### Calendar Workflows

```bash
# Show agenda
./scripts/run-calendar.sh agenda

# Check free/busy
./scripts/run-calendar.sh freebusy

# Create event with smart scheduling
./scripts/run-calendar.sh insert "Meeting title" 2024-03-15 14:00 60
```

### Tasks Workflows

```bash
# List tasks
./scripts/run-tasks.sh list

# Sync from triage
./scripts/run-tasks.sh sync

# Create task from email
./scripts/run-tasks.sh from-email <message_id>
```

## What to Load

| Task | Load These | Do NOT Load |
|------|-----------|-------------|
| Triage inbox | `01-triage/CONTEXT.md`, `shared/prioritization-rules.md`, `shared/email-categories.md` | Other stages, extraction rules |
| Extract knowledge | `02-extraction/CONTEXT.md`, `shared/extraction-rules.md`, `shared/para-structure.md` | Triage files, calendar files |
| Sync calendar | `03-calendar/CONTEXT.md`, `shared/calendar-preferences.md` | Digest template, extraction rules |
| Generate digest | `04-digest/CONTEXT.md`, `shared/digest-template.md` | All upstream stage CONTEXT files |

## Stage Handoffs

Each stage writes to its `output/` folder. The next stage reads from there:

1. **Triage** → `triage-report.md` → read by Extraction and Calendar
2. **Extraction** → `extraction-log.md` → read by Calendar and Digest
3. **Calendar** → `calendar-log.md` → read by Digest
4. **Digest** → `digest.md` → final output

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

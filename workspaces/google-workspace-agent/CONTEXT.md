# Google Workspace Agent

An always-on agent that monitors inbox, triages, extracts knowledge, and manages calendar.

## Task Routing

| Task Type | Go To | Description |
|-----------|-------|-------------|
| Triage inbox | `stages/01-triage/CONTEXT.md` | Categorize and prioritize emails |
| Extract knowledge | `stages/02-extraction/CONTEXT.md` | Save valuable info to PARA folders |
| Sync calendar | `stages/03-calendar/CONTEXT.md` | Create events and focus blocks |
| Generate digest | `stages/04-digest/CONTEXT.md` | Consolidated activity summary |
| Initial setup | `setup/questionnaire.md` | Configure workspace variables |

## Shared Resources

| Resource | Location | Contains |
|----------|----------|----------|
| Prioritization rules | `shared/prioritization-rules.md` | Urgency/importance criteria |
| Email categories | `shared/email-categories.md` | User's taxonomy for sorting |
| Extraction rules | `shared/extraction-rules.md` | What counts as valuable info |
| PARA structure | `shared/para-structure.md` | Knowledge base folder layout |
| Calendar preferences | `shared/calendar-preferences.md` | Durations, reminders, hours |
| Digest template | `shared/digest-template.md` | ADHD-friendly format |
| GWS workflows | `shared/gws-workflows.sh` | Cross-service workflow helpers |

## GWS Skills

This workspace uses the `@googleworkspace/cli` skill bundle. Install with:

```bash
npx skills add https://github.com/googleworkspace/cli
```

Key skills used:
- `gws-gmail`, `gws-gmail-triage`, `gws-gmail-send`, `gws-gmail-reply` — inbox operations
- `gws-tasks`, `gws-tasks-list`, `gws-tasks-create` — action item management
- `gws-calendar`, `gws-calendar-insert`, `gws-calendar-freebusy` — calendar operations
- `gws-drive`, `gws-keep` — knowledge storage
- `persona-exec-assistant`, `persona-project-manager`, `persona-researcher` — behavior patterns

## Full GWS Capability Matrix

### Gmail

| Feature | Command | Script |
|---------|---------|--------|
| Triage unread | `gws gmail +triage` | `scripts/run-triage.sh` |
| Send email | `gws gmail +send` | `scripts/run-digest.sh send` |
| Reply to email | `gws gmail +reply` | `scripts/run-digest.sh reply` |
| Get message | `gws gmail users messages get` | `scripts/run-triage.sh` |

### Calendar

| Feature | Command | Script |
|---------|---------|--------|
| Daily agenda | `gws calendar +agenda` | `scripts/run-calendar.sh agenda` |
| Create event | `gws calendar events insert` | `scripts/run-calendar.sh insert` |
| Check free/busy | `gws calendar freebusy` | `scripts/run-calendar.sh freebusy` |
| List events | `gws calendar events list` | `scripts/run-calendar.sh` |

### Tasks

| Feature | Command | Script |
|---------|---------|--------|
| List tasks | `gws tasks tasks list` | `scripts/run-tasks.sh list` |
| Create task | `gws tasks tasks insert` | `scripts/run-tasks.sh create` |
| Complete task | `gws tasks tasks update` | `scripts/run-tasks.sh complete` |
| Sync from triage | - | `scripts/run-tasks.sh sync` |
| Task agenda | - | `scripts/run-tasks.sh agenda` |

### Drive

| Feature | Command | Script |
|---------|---------|--------|
| Create doc | `gws drive files create` | `scripts/kb-create.sh` |
| List files | `gws drive files list` | `scripts/kb-create.sh` |

### Workflows

| Workflow | Command | Script |
|----------|---------|--------|
| Email to task | `email-to-task <msg_id>` | `shared/gws-workflows.sh` |
| Daily standup | `standup` | `shared/gws-workflows.sh` |
| Weekly digest | `weekly-digest [--send]` | `shared/gws-workflows.sh` |
| Meeting prep | `meeting-prep [--hours N]` | `shared/gws-workflows.sh` |
| Schedule focus | `focus [duration] [date] [time]` | `shared/gws-workflows.sh` |
| Chat notification | `notify <space> <message>` | `shared/gws-workflows.sh` |

## Session Workflow Example

```
You: "start my day"

Agent:
1. ./scripts/run-calendar.sh agenda → "You have 3 meetings today..."
2. ./shared/gws-workflows.sh standup → "Open tasks: 5, Emails unread: 12..."
3. ./shared/gws-workflows.sh meeting-prep → "Next meeting: Weekly Sync..."

You: "process newsletters"

Agent:
1. ./scripts/run-triage.sh → fetch newsletters
2. [AI extraction]
3. ./scripts/kb-create.sh → save to KB
4. ./scripts/run-tasks.sh from-email → extract action items

You: "schedule focus time"

Agent:
1. ./scripts/run-calendar.sh freebusy → find open slots
2. ./scripts/run-calendar.sh insert "[Focus Time]" → block 2 hours

You: "send me my digest"

Agent:
1. ./scripts/run-digest.sh → generate digest
2. ./scripts/run-digest.sh send user@example.com "Daily Digest" → deliver to inbox
```

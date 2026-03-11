# Calendar Sync

Create and manage calendar events based on action items and extracted dates.

## Inputs

| Source | File/Location | Section/Scope | Why |
|--------|--------------|---------------|-----|
| Stage 01 | `../01-triage/output/triage-report.md` | "Action Items" section | Action items with deadlines |
| Stage 02 | `../02-extraction/output/extraction-log.md` | Dates/deadlines | Extracted temporal data |
| Shared | `shared/calendar-preferences.md` | Full file | Durations, working hours |
| Config | `c_8794edb43185139c1476becd055c18da00b15120720f6754ce8e6f7e7598d6d8@group.calendar.google.com` | - | Target calendar (Life/EF) |
| Skills | gws-calendar, gws-calendar-insert, recipe-block-focus-time, persona-project-manager | - | Processing capabilities |

## Commands

| Command | Description |
|---------|-------------|
| `agenda [date]` | Show daily agenda with all events |
| `insert <summary> [date] [time] [duration]` | Create event with smart scheduling |
| `freebusy [date]` | Check free/busy times |
| (default) | Run full calendar sync |

## Process

1. Collect action items with deadlines from triage report
2. Collect dates/deadlines from extraction log
3. Check for conflicts via `gws calendar events list`
4. Draft proposed events with context links
5. Apply preferences from calendar-preferences.md
6. Block focus time using recipe-block-focus-time (ADHD-friendly)
7. [Checkpoint] If supervised = true, pause for user review
8. Create events via `gws calendar events insert`

## Checkpoints

| After Step | Agent Presents | Human Decides |
|------------|---------------|---------------|
| 7 | Draft events with focus blocks and conflict resolution | Approve calendar changes before creation |

## Audit

| Check | Pass Condition |
|-------|---------------|
| All events have context links | Each event links to source triage item or extraction |
| No conflicts | No new events overlap with existing calendar events |

## Outputs

| Artifact | Location | Format |
|----------|----------|--------|
| Calendar Events | `c_8794edb43185139c1476becd055c18da00b15120720f6754ce8e6f7e7598d6d8@group.calendar.google.com` | Events with context links |
| Focus Blocks | `c_8794edb43185139c1476becd055c18da00b15120720f6754ce8e6f7e7598d6d8@group.calendar.google.com` | Blocked focus time |
| Calendar Log | `output/calendar-log.md` | List of created events with IDs |

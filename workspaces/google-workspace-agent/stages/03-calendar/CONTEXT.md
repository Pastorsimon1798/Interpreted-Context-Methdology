# Calendar Sync

Create and manage calendar events based on action items and extracted dates.

## Key Principle

> **The AI does the scheduling. Scripts just return JSON.**

## Inputs

| Source | How to Access | Why |
|--------|--------------|-----|
| Stage 01 | `../01-triage/output/triage-report.md` | Action items with deadlines |
| Stage 02 | `../02-extraction/output/extraction-log.md` | Extracted temporal data |
| Shared | `shared/calendar-preferences.md` | Durations, working hours |
| Calendar | `gws calendar +agenda --today --format json` | Today's schedule |

## GWS Commands for AI

```bash
# Get today's agenda
gws calendar +agenda --today --format json

# Get this week's agenda
gws calendar +agenda --week --format json

# Create event (AI decides when)
gws calendar +insert --summary "Meeting Title" --start "2026-03-12T14:00:00"

# Create event with full options
gws calendar events insert \
  --calendar "primary" \
  --json '{"summary":"Meeting","start":{"dateTime":"2026-03-12T14:00:00","timeZone":"America/New_York"},"end":{"dateTime":"2026-03-12T15:00:00","timeZone":"America/New_York"}}'

# Check free/busy
gws calendar freebusy \
  --json '{"items":[{"id":"primary"}],"timeMin":"2026-03-12T00:00:00Z","timeMax":"2026-03-12T23:59:59Z"}'
```

## Process

1. **Fetch schedule** - Call `gws calendar +agenda --today --format json`
2. **AI reads preferences** - `shared/calendar-preferences.md` for working hours, buffer times
3. **AI analyzes** - Identify gaps, conflicts, optimal focus times
4. **AI decides** - When to schedule events, how long, when to block focus time
5. **AI creates events** - Call `gws calendar +insert` or `gws calendar events insert`
6. **Generate log** - Write `output/calendar-log.md`

## AI Scheduling Logic

The AI uses its intelligence to schedule. Example decisions:

- **Focus blocks**: Morning (9-11am) or afternoon (2-4pm) based on preferences
- **Meeting buffers**: 5-15 min between meetings (configurable)
- **Working hours**: Respect start/end times from preferences
- **Conflict resolution**: Reschedule or find alternative slots

## Commands (Thin Wrappers)

| Command | GWS Call | AI Decision |
|---------|----------|-------------|
| `agenda [date]` | `gws calendar +agenda` | None - returns JSON |
| `insert <summary> ...` | `gws calendar +insert` | AI decides time |
| `freebusy [date]` | `gws calendar freebusy` | None - returns JSON |

## Outputs

| Artifact | Location | Format |
|----------|----------|--------|
| Calendar Events | Google Calendar | Events with context links |
| Focus Blocks | Google Calendar | Blocked focus time |
| Calendar Log | `output/calendar-log.md` | List of created events |

## Verifiability

**Classification:** `MACHINE-VERIFIABLE`

**Verification Method:** Events created can be verified via Calendar API, conflicts can be detected programmatically.

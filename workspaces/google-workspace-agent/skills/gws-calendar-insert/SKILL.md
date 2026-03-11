---
name: gws-calendar-insert
description: "Create calendar events from extracted meeting details."
---

# Calendar Insert

Create Google Calendar events from parsed meeting information.

## Usage

```bash
gws calendar-insert --summary "Meeting Title" \
  --date "2024-01-15" \
  --time "10:00" \
  --duration "60"
```

## Input Sources

| Source | How Extracted |
|--------|---------------|
| Email body | NLP parsing for date/time/location |
| Manual entry | Structured parameters |
| Natural language | "Schedule lunch with John tomorrow at noon" |

## Event Structure

```json
{
  "summary": "Event Title",
  "start": { "dateTime": "2024-01-15T10:00:00" },
  "end": { "dateTime": "2024-01-15T11:00:00" },
  "location": "Conference Room A",
  "description": "Meeting notes link",
  "attendees": ["email@example.com"]
}

## Workflow

1. Parse input for date, time, duration, attendees
2. Check calendar availability
3. Present parsed details for confirmation
4. Create event on confirmation
5. Return event ID and link

## Tips

- Always confirm before creating
- Check for conflicts before scheduling
- Include video conferencing link if remote
- Set appropriate reminders

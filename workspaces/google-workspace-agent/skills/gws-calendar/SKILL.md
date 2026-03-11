---
name: gws-calendar
description: "Google Calendar operations via gws CLI."
---

# GWS Calendar

Manage Google Calendar events and schedules.

## Commands

| Command | Description |
|---------|-------------|
| `gws calendar events list --calendarId <id>` | List events |
| `gws calendar events get <eventId>` | Get event details |
| `gws calendar events create --calendarId <id>` | Create event |
| `gws calendar events update <eventId>` | Update event |
| `gws calendar events delete <eventId>` | Delete event |
| `gws calendar freebusy --timeMin <start> --timeMax <end>` | Check availability |

## Creating Events

```bash
gws calendar events create \
  --calendarId "primary" \
  --summary "Meeting Title" \
  --startDateTime "2024-01-15T10:00:00" \
  --endDateTime "2024-01-15T11:00:00" \
  --attendees '["email@example.com"]'
```

## Checking Availability

```bash
gws calendar freebusy \
  --timeMin "2024-01-15T09:00:00Z" \
  --timeMax "2024-01-15T17:00:00Z"
```

## Tips

- Use `primary` as calendarId for main calendar
- Include timezone in datetime strings
- Check availability before scheduling
- Set reminders for important events

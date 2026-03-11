---
name: recipe-block-focus-time
description: "Schedule protected focus time blocks on calendar."
---

# Block Focus Time Recipe

Create protected calendar blocks for deep work sessions.

## Usage

```bash
gws recipe +focus-time --duration 90 --time "10:00" --date "2024-01-15"
gws recipe +focus-time --duration 90 --time "10:00" --recurring "daily"
```

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--duration` | 90 | Block length in minutes |
| `--time` | 10:00 | Start time (24h format) |
| `--date` | today | Specific date or "today"/"tomorrow" |
| `--recurring` | none | "daily", "weekdays", or specific days |
| `--title` | "Focus Time" | Calendar event title |

## Example

```bash
# Block 90 minutes starting at 9am today
gws recipe +focus-time --duration 90 --time "09:00"

# Schedule recurring weekday focus blocks
gws recipe +focus-time --duration 120 --time "09:00" --recurring "weekdays"
```

## Focus Block Rules

1. Check for existing meetings first
2. Find next available slot if conflict
3. Set status to "Busy" (not "Free")
4. Add reminder 10 minutes before
5. Include "Do not book" in description

## Event Structure

```json
{
  "summary": "Focus Time",
  "start": { "dateTime": "2024-01-15T10:00:00" },
  "end": { "dateTime": "2024-01-15T11:30:00" },
  "transparency": "opaque",
  "visibility": "private",
  "reminders": {
    "overrides": [{ "method": "popup", "minutes": 10 }]
  }
}
```

## Tips

- Block in morning for best energy
- 90 minutes is optimal for deep work
- Mark as "Busy" to prevent double-booking
- Take breaks between focus blocks
- Review and adjust weekly

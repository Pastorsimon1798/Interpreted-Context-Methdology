---
name: gws-calendar-agenda
description: "Generate daily or weekly agenda from calendar events."
---

# Calendar Agenda

Generate structured agenda views from Google Calendar.

## Commands

| Command | Description |
|---------|-------------|
| `gws calendar agenda --day` | Today's agenda |
| `gws calendar agenda --week` | Weekly overview |
| `gws calendar agenda --date "2024-01-15"` | Specific day |
| `gws calendar agenda --upcoming` | Next 7 days |

## Usage

```bash
# Today's agenda
gws calendar agenda --day

# Week view starting today
gws calendar agenda --week

# Specific date with details
gws calendar agenda --date "2024-01-15" --details
```

## Agenda Output Format

```markdown
## Agenda - Monday, Jan 15, 2024

### Morning
| Time | Event | Location | Prep |
|------|-------|----------|------|
| 9:00 | Team Standup | Zoom | [Link] |
| 10:30 | Client Review | Conf Room A | [Doc] |

### Afternoon
| Time | Event | Location | Prep |
|------|-------|----------|------|
| 2:00 | 1:1 with Sarah | Phone | [Notes] |
| 4:00 | Focus Time | - | - |

### Action Items for Today
- [ ] Prepare client presentation
- [ ] Review Sarah's proposal

### Looking Ahead
- Tomorrow: Board meeting (10:00)
- Thursday: Deadline for Q4 report
```

## Integration Points

| Context | Action |
|---------|--------|
| Meeting prep | Pull relevant docs from Drive |
| Focus time | Block calendar, set status |
| Conflicts | Alert and suggest alternatives |
| Travel time | Add buffer between locations |

## Tips

- Run each morning for daily overview
- Review weekly agenda on Monday
- Include prep time before meetings
- Block travel time between locations
- Set reminders for important events

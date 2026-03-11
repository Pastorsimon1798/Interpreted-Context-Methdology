---
name: gws-workflow-weekly-digest
description: "Generate comprehensive weekly activity summary."
---

# Weekly Digest Workflow

Compile a comprehensive summary of all workspace activity for the week.

## Usage

```bash
gws workflow +weekly-digest --week "current"
gws workflow +weekly-digest --week "2024-W03"
```

## Digest Components

### Email Activity
| Metric | Source |
|--------|--------|
| Emails processed | Gmail API |
| Categories breakdown | Triage logs |
| Action items created | Tasks created |
| Response time avg | Sent vs received |

### Calendar Activity
| Metric | Source |
|--------|--------|
| Meetings attended | Calendar events |
| Focus time blocked | Calendar analysis |
| Upcoming deadlines | Events + tasks |

### Task Activity
| Metric | Source |
|--------|--------|
| Tasks created | Google Tasks |
| Tasks completed | Completed tasks |
| Overdue items | Due date analysis |

### Knowledge Base
| Metric | Source |
|--------|--------|
| Files saved | Drive activity |
| Notes captured | Keep activity |
| PARA distribution | Folder analysis |

## Output Format

```markdown
# Weekly Digest - Week X, YYYY

## Summary
- X emails processed
- X meetings attended
- X tasks completed
- X items saved to KB

## Key Accomplishments
- [List of completed items]

## Upcoming Priorities
- [List of next week's priorities]

## Recommendations
- [AI-suggested improvements]
```

## Tips

- Run every Friday afternoon
- Review before sending
- Archive after review
- Track trends over time

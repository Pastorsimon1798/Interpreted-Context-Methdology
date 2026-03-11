---
name: gws-tasks
description: "Google Tasks operations via gws CLI."
---

# GWS Tasks

Manage Google Tasks for action items and to-dos.

## Commands

| Command | Description |
|---------|-------------|
| `gws tasks list --tasklist <id>` | List tasks in list |
| `gws tasks get <taskId>` | Get task details |
| `gws tasks create --tasklist <id> --title "<title>"` | Create task |
| `gws tasks update <taskId> --status completed` | Complete task |
| `gws tasks delete <taskId>` | Delete task |
| `gws tasklists list` | List all task lists |

## Task Lists

| List | Purpose |
|------|---------|
| Default | General tasks |
| Work | Work-related items |
| Personal | Personal items |

## Creating Tasks

```bash
gws tasks create \
  --tasklist "TASK_LIST_ID" \
  --title "Complete project report" \
  --notes "Due Friday\nContext: Q4 deliverable" \
  --due "$(date -v+7d +%Y-%m-%d)"
```

## Tips

- Always set due dates for time-sensitive items
- Add context in notes field
- Use clear, action-oriented titles
- Review and clean up completed tasks weekly

---
name: gws-workflow-email-to-task
description: "Convert emails into actionable tasks in Google Tasks."
---

# Email to Task Workflow

Transform email action items into trackable Google Tasks.

## Usage

```bash
gws workflow +email-to-task --messageId <gmail_message_id>
```

## Workflow Steps

1. **Fetch Email** - Retrieve full email content by message ID
2. **Extract Actions** - Identify action items and deadlines
3. **Create Task** - Add to Google Tasks with:
   - Title: Clear action description
   - Notes: Email context and link back to source
   - Due date: If deadline mentioned
4. **Label Email** - Mark as processed with `action-created` label
5. **Archive** - Remove from inbox (optional)

## Example

```bash
# From triage output, convert flagged email to task
gws workflow +email-to-task --messageId "18c4f2e3b7a1d9e5"
```

## Task Format

| Field | Source |
|-------|--------|
| Title | Email subject or extracted action |
| Notes | Sender, date, email link, key context |
| Due | Parsed deadline or default +3 days |

## Tips

- Run after triage to process flagged items
- Always include email link in task notes
- Use consistent task list (e.g., "Inbox Actions")
- Review created tasks in weekly digest

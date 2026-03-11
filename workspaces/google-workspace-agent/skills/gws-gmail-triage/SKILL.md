---
name: gws-gmail-triage
description: "Process Gmail inbox with priority scoring and categorization."
---

# GWS Gmail Triage

Process your Gmail inbox with intelligent priority scoring and categorization.

## Commands

| Command | Description |
|---------|-------------|
| `gws gmail list --filter "is:unread"` | List unread emails |
| `gws gmail get <message_id>` | Get email details |
| `gws gmail labels list` | List available labels |
| `gws gmail modify <message_id> --addLabelIds <ids>` | Add labels to email |
| `gws gmail archive <message_id>` | Archive email |

## Triage Process

1. Fetch unread emails (max 50 at a time)
2. Apply priority scoring based on sender, subject, keywords
3. Categorize by type (action, reference, archive)
4. Present in table format for quick scanning
5. Apply labels and archive as approved

## Priority Scoring

| Factor | Points |
|--------|--------|
| From known contact | +3 |
| Contains action keywords | +2 |
| Contains deadline | +2 |
| From newsletter | -2 |
| Promotional content | -3 |

## Tips

- Use `--format table` for readable output
- Process in batches of 10-15 emails
- Always confirm before archiving
- Flag emails requiring follow-up as tasks

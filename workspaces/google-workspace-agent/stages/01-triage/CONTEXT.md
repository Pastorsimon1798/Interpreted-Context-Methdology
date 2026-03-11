# Inbox Triage

Read, categorize, and prioritize incoming emails for action and extraction.

## Inputs

| Source | File/Location | Section/Scope | Why |
|--------|--------------|---------------|-----|
| Gmail API | `gws gmail messages list` | Unread/recent messages | Raw email data |
| Gmail API | `gws gmail users.messages.watch` | Push configuration | Real-time notifications |
| Shared | `shared/prioritization-rules.md` | Full file | Urgency/importance criteria |
| Shared | `shared/email-categories.md` | Full file | User's taxonomy |
| Skills | gws-gmail-triage, gws-workflow-email-to-task, gws-tasks, persona-exec-assistant, persona-project-manager | - | Processing capabilities |

## Process

1. Set up push notifications via `gws gmail-watch`
2. Fetch unread/recent emails via `gws gmail messages list`
3. Categorize each email using email-categories.md taxonomy
4. Score urgency using prioritization-rules.md
5. Identify action-required items
6. Convert action items to Google Tasks via `gws tasks`
7. Flag emails with valuable content for extraction
8. Generate triage-report.md
9. [Checkpoint] If supervised = true, pause for user review

## Checkpoints

| After Step | Agent Presents | Human Decides |
|------------|---------------|---------------|
| 9 | triage-report.md with categories, priorities, and action items | Approve categorization and task creation before proceeding |

## Audit

| Check | Pass Condition |
|-------|---------------|
| All emails categorized | Every processed email has a category assigned |
| Action items identified | All action-required emails have corresponding tasks |
| No auto-replies sent | No email responses were sent without explicit approval |

## Outputs

| Artifact | Location | Format |
|----------|----------|--------|
| Triage Report | `output/triage-report.md` | Categorized email list with priorities and action items |
| Google Tasks | Tasks API | Created action items from email processing |

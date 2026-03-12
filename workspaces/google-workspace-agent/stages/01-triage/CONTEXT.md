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
| Security | `../../shared/security/CONTEXT.md` | Full file | Sanitization rules |
| Skill | `../../skills/security-input-sanitization/SKILL.md` | Full file | Injection protection |

## Process

1. Set up push notifications via `gws gmail-watch`
2. Fetch unread/recent emails via `gws gmail messages list`
3. **[Security]** Sanitize email content using security-input-sanitization skill
4. Categorize each email using email-categories.md taxonomy
5. Score urgency using prioritization-rules.md
6. Identify action-required items
7. Convert action items to Google Tasks via `gws tasks`
8. Flag emails with valuable content for extraction
9. Generate triage-report.md
10. [Checkpoint] If supervised = true, pause for user review

## Verifiability

**Classification:** `JUDGMENT-REQUIRED`

**Verification Method:** Email prioritization and categorization involve subjective judgment. Automated checks can verify completeness but not quality of decisions.

**Human Review Trigger:** High-priority categorizations and action item creation require human confirmation unless in autonomous mode.

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
| Content sanitized | All email bodies passed security validation |

## Outputs

| Artifact | Location | Format |
|----------|----------|--------|
| Triage Report | `output/triage-report.md` | Categorized email list with priorities and action items |
| Google Tasks | Tasks API | Created action items from email processing |

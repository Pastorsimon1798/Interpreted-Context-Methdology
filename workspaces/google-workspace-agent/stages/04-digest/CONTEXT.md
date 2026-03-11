# Digest

Present a consolidated summary of all agent activity.

## Inputs

| Source | File/Location | Section/Scope | Why |
|--------|--------------|---------------|-----|
| Stage 01 | `../01-triage/output/triage-report.md` | Full file | Triage summary |
| Stage 02 | `../02-extraction/output/extraction-log.md` | Full file | Extraction summary |
| Stage 03 | `../03-calendar/output/calendar-log.md` | Full file | Calendar summary |
| Shared | `shared/digest-template.md` | Full file | ADHD-friendly formatting |
| Config | `twice-daily` | - | Digest frequency |
| Skills | gws-calendar-agenda, gws-workflow-weekly-digest | - | Processing capabilities |

## Commands

| Command | Description |
|---------|-------------|
| (default) | Generate digest |
| `--email` | Generate and send via Gmail |
| `--slack` | Send notification via Slack |
| `send <to> <subject> [body]` | Send email via Gmail +send |
| `reply <msg_id> [body]` | Reply to email via Gmail +reply |

## Process

1. Aggregate statistics from all upstream outputs
2. Summarize triage: emails processed, categories, urgent items, tasks created
3. Summarize extractions: new knowledge files, PARA distribution, attachments saved
4. Summarize calendar: events created, focus blocks, upcoming deadlines
5. Format using ADHD-friendly template
6. Write digest to output
7. (Optional) Deliver via email or Slack

## Checkpoints

| After Step | Agent Presents | Human Decides |
|------------|---------------|---------------|
| 6 (Write digest) | digest.md with summary of all activity | Approve before sending/displaying |

## Audit

| Check | Pass Condition |
|-------|---------------|
| All action items accounted | Every action item from triage appears in digest |
| Digest scannable | Content uses ADHD-friendly formatting (bullet points, clear sections, visual hierarchy) |

## Outputs

| Artifact | Location | Format |
|----------|----------|--------|
| Digest | `output/digest.md` | Consolidated activity summary |
| Email | Inbox | (Optional) Delivered via Gmail +send |

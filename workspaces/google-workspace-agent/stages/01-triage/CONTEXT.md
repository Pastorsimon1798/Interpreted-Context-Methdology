# Inbox Triage

Read, categorize, and prioritize incoming emails for action and extraction.

## Key Principle

> **The AI does the categorization. Scripts just return JSON.**

## Inputs

| Source | How to Access | Why |
|--------|--------------|-----|
| Gmail API | `gws gmail +triage --max 100 --format json` | Inbox summary for AI |
| Gmail API | `gws gmail users messages get --params '{"userId":"me","id":"ID"}'` | Full email details |
| Shared | `shared/prioritization-rules.md` | Urgency/importance criteria |
| Shared | `shared/email-categories.md` | User's taxonomy |

## Process

1. **Fetch inbox** - Call `gws gmail +triage --max 100 --format json`
2. **AI categorizes** - Use intelligence + `shared/email-categories.md` to classify each email
3. **AI prioritizes** - Use `shared/prioritization-rules.md` to score urgency
4. **AI decides actions** - What to archive, what to extract, what to create tasks for
5. **AI archives** - Call `gws gmail users messages modify` to remove from inbox + apply label
6. **Generate report** - Write `output/triage-report.md`

## GWS Commands for AI

```bash
# Get inbox summary (id, subject, from, date)
gws gmail +triage --max 100 --format json

# Get full email details when needed
gws gmail users messages get --params '{"userId":"me","id":"MESSAGE_ID"}' --format json

# Archive email with label
gws gmail users messages modify \
  --params '{"userId":"me","id":"MESSAGE_ID"}' \
  --json '{"removeLabelIds":["INBOX"],"addLabelIds":["Label_7"]}'

# Discover label IDs
gws gmail users labels list --params '{"userId":"me"}' --format json
```

## Label Reference

| Label ID | Name | Use For |
|----------|------|---------|
| Label_10 | Jobs | LinkedIn, job alerts, career |
| Label_7 | Newsletters | Substack, digests, regular updates |
| Label_11 | Promos | Marketing, offers, unsubscribe links |
| Label_6 | Receipts | Orders, confirmations, invoices |
| Label_18 | Social | Facebook, Twitter, Instagram, etc. |
| Label_19 | Low-Priority | Everything else |

## AI Categorization Logic

The AI uses its intelligence to categorize emails. Example patterns:

- **Jobs**: Contains "job alert", "career", "recruiter", from LinkedIn Jobs
- **Newsletters**: Contains "unsubscribe", regular sender, digest format
- **Promos**: Marketing language, "offer", "sale", promotional sender
- **Social**: From social media platforms, notification-style emails
- **Action-Required**: "please review", "action needed", "deadline", personal request
- **Reference**: Receipts, confirmations, bookings

## Outputs

| Artifact | Location | Format |
|----------|----------|--------|
| Triage Report | `output/triage-report.md` | Categorized email list with priorities and action items |
| Google Tasks | Tasks API | Created action items from email processing |

## Verifiability

**Classification:** `JUDGMENT-REQUIRED`

**Verification Method:** Email prioritization and categorization involve subjective judgment. The AI makes decisions based on rules and context.

**Human Review Trigger:** High-priority categorizations and action item creation require human confirmation unless in autonomous mode.

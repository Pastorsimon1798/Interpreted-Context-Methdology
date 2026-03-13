# Digest

Present a consolidated summary of all agent activity.

## Key Principle

> **The AI reads outputs and writes the digest. Scripts just help deliver it.**

## Inputs

| Source | How to Access | Why |
|--------|--------------|-----|
| Stage 01 | `../01-triage/output/triage-report.md` | Triage summary |
| Stage 02 | `../02-extraction/output/extraction-log.md` | Extraction summary |
| Stage 03 | `../03-calendar/output/calendar-log.md` | Calendar summary |
| Shared | `shared/digest-template.md` | ADHD-friendly formatting |

## GWS Commands for AI

```bash
# Send digest via email (AI composes, +send delivers)
gws gmail +send --to "user@example.com" --subject "Daily Digest" --body "..."

# Reply to a thread (AI composes reply)
gws gmail +reply --message-id "..." --body "..."
```

## Process

1. **AI reads stage outputs** - Triage, extraction, calendar logs
2. **AI aggregates** - Statistics, counts, key items
3. **AI summarizes** - ADHD-friendly format with bullets, clear sections
4. **AI writes digest** - `output/digest.md`
5. **AI delivers** (optional) - Call `gws gmail +send`

## AI Summary Logic

The AI creates a scannable digest:

- **ACTION REQUIRED**: Critical items first (max 5)
- **HIGH PRIORITY**: Important but not urgent (max 10)
- **INBOX SUMMARY**: Stats and categories
- **EXTRACTED**: New knowledge base items
- **CALENDAR**: Today's schedule, focus time
- **METRICS**: Quick counts

## Delivery Commands

```bash
# Generate digest only
./scripts/run-digest.sh

# Generate and send via email
./scripts/run-digest.sh --email

# Send custom email (AI composes)
gws gmail +send --to "user@example.com" --subject "Subject" --body "AI-written content"
```

## Outputs

| Artifact | Location | Format |
|----------|----------|--------|
| Digest | `output/digest.md` | Consolidated activity summary |
| Email | Inbox | (Optional) Delivered via Gmail +send |

## Verifiability

**Classification:** `JUDGMENT-REQUIRED`

**Verification Method:** Digest completeness can be checked, but quality of summary requires human judgment.

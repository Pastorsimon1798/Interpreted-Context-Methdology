# Digest Template

> ADHD-friendly, scannable format for twice-daily summaries.

## Digest Configuration

**Frequency:** `twice-daily`

**Delivery Times:** `08:00` and `16:00`

**Delivery Method:** `in-app` (displayed when running agent)

---

## Header Section

```markdown
# Google Workspace Digest
**Date:** {{DIGEST_DATE}}
**Time Range:** {{DIGEST_TIME_RANGE}}
**Generated:** {{GENERATION_TIMESTAMP}}

---
```

---

## Triage Summary

### Critical Items (Action Required)

**Format:** Bold key items for immediate attention.

```markdown
## ACTION REQUIRED

**[!] {{CRITICAL_ITEM_1}}**
  From: {{SENDER}} | Category: {{CATEGORY}}
  Why: {{URGENCY_REASON}}
  Action: {{SUGGESTED_ACTION}}

**[!] {{CRITICAL_ITEM_2}}**
  From: {{SENDER}} | Category: {{CATEGORY}}
  Why: {{URGENCY_REASON}}
  Action: {{SUGGESTED_ACTION}}
```

**Max Items Shown:** `5`

---

### High Priority (Review Today)

```markdown
## HIGH PRIORITY

1. **{{HIGH_ITEM_1}}** - {{SENDER}}
2. **{{HIGH_ITEM_2}}** - {{SENDER}}
3. {{HIGH_ITEM_3}} - {{SENDER}}
```

**Max Items Shown:** `10`

---

## Quick Scan Section

### Emails by Category

```markdown
## INBOX SUMMARY

| Category | Count | Sample |
|----------|-------|--------|
| Action Required | {{ACTION_COUNT}} | "{{SAMPLE_ACTION}}" |
| Newsletters | {{NEWSLETTER_COUNT}} | "{{SAMPLE_NEWSLETTER}}" |
| Reference | {{REFERENCE_COUNT}} | "{{SAMPLE_REFERENCE}}" |
| Social | {{SOCIAL_COUNT}} | "{{SAMPLE_SOCIAL}}" |
| Promotional | {{PROMO_COUNT}} | (auto-archived) |
| Low Priority | {{LOW_COUNT}} | (batched) |

**Total Unprocessed:** {{TOTAL_UNPROCESSED}}
**Auto-Filed:** {{AUTO_FILED_COUNT}}
```

---

## Extractions

### Valuable Information Captured

```markdown
## EXTRACTED THIS PERIOD

### Links
- **{{LINK_TITLE_1}}** - {{LINK_SOURCE}}
  URL: {{LINK_URL}}
  Saved to: {{PARA_DESTINATION}}

- {{LINK_TITLE_2}} - {{LINK_SOURCE}}

### Quotes
> "{{QUOTE_TEXT}}"
> -- {{QUOTE_SOURCE}}

### Deadlines
**{{DEADLINE_TITLE}}** - {{DEADLINE_DATE}}
  Source: {{DEADLINE_EMAIL}}
  Added to calendar

### Resources
- **{{RESOURCE_TITLE}}** -> {{RESOURCE_DESTINATION}}
```

**Max Extractions Shown:** `10`

---

## Calendar Overview

```markdown
## CALENDAR

### Today's Schedule

| Time | Event | Type | Prep |
|------|-------|------|------|
| **08:00** | {{EVENT_1}} | {{TYPE}} | {{PREP_NOTES}} |
| 10:00 | {{EVENT_2}} | {{TYPE}} | |
| **14:00** | {{EVENT_3}} | {{TYPE}} | {{PREP_NOTES}} |
| 15:00 | Focus Block | Focus | |

**Focus Time Remaining:** {{FOCUS_TIME_REMAINING}}
**Meeting Load:** {{MEETING_LOAD}}% of day

### Upcoming (Next 24 hours)

- **{{TOMORROW_EVENT_1}}** (Tomorrow, {{TIME}})
- {{TOMORROW_EVENT_2}} (Tomorrow, {{TIME}})
```

---

## Action Items

### Consolidated Task List

```markdown
## ACTION ITEMS

### Due Today
- [ ] **{{TASK_1}}** (from {{SOURCE}})
- [ ] **{{TASK_2}}** (from {{SOURCE}})

### Due This Week
- [ ] {{TASK_3}} (due {{DUE_DATE}})
- [ ] {{TASK_4}} (due {{DUE_DATE}})

### Waiting For
- [ ] {{WAITING_TASK_1}} - waiting on {{BLOCKER}}
- [ ] {{WAITING_TASK_2}} - waiting on {{BLOCKER}}
```

---

## Metrics

### This Period's Stats

```markdown
## METRICS

**Emails Processed:** {{EMAILS_PROCESSED}}
**Actions Extracted:** {{ACTIONS_EXTRACTED}}
**Resources Saved:** {{RESOURCES_SAVED}}
**Meetings Attended:** {{MEETINGS_ATTENDED}}
**Focus Time Achieved:** {{FOCUS_TIME_ACHIEVED}} / {{FOCUS_TIME_TARGET}}

**Trend vs. Last Period:**
- Email volume: {{EMAIL_TREND}}
- Meeting load: {{MEETING_TREND}}
- Focus time: {{FOCUS_TREND}}
```

---

## Footer

```markdown
---

**Quick Actions:**
- [ ] Mark all promotional as read
- [ ] Archive processed newsletters
- [ ] Schedule focus time for {{SUGGESTED_FOCUS_DATE}}

**Next Digest:** {{NEXT_DIGEST_TIME}}

**Agent Notes:** {{AGENT_NOTES}}
```

---

## Formatting Rules

### Visual Hierarchy

1. **Bold** = Requires immediate attention
2. *Italics* = Contextual information
3. `Code` = Technical details, IDs
4. > Blockquotes = Quoted content

### ADHD-Friendly Principles

- **Scannable:** Key info visible in < 30 seconds
- **Chunked:** Sections separated by clear headers
- **Prioritized:** Most important at top
- **Actionable:** Clear next steps
- **Bounded:** Limits on items per section

### Color Coding (if supported)

```markdown
**CRITICAL** - Red
**HIGH** - Orange
MEDIUM - Yellow
LOW - Gray
```

---

## Customization Options

### Section Visibility

- Always show: Triage Summary, Action Items
- Show if not empty: Extractions, Calendar
- Collapsed by default: Metrics

---

## Alternative Formats

### Minimal Digest

```
DIGEST {{DATE}}

CRITICAL: {{CRITICAL_COUNT}} items
- {{CRITICAL_1}}
- {{CRITICAL_2}}

CALENDAR: {{NEXT_EVENT}} at {{NEXT_EVENT_TIME}}

ACTIONS: {{ACTION_COUNT}} due today
```

### Detailed Digest

Full template as shown above with all sections expanded.

### Slack/Chat Format

```
*Google Workspace Digest - {{DATE}}*

:rotating_light: *ACTION REQUIRED*
> {{CRITICAL_1}}
> {{CRITICAL_2}}

:calendar: *Next up:* {{NEXT_EVENT}} at {{NEXT_EVENT_TIME}}

:white_check_mark: *Actions due:* {{ACTION_COUNT}}
```

---

## Usage Notes

- Digest adapts based on user engagement patterns
- Low engagement = simpler digest
- High engagement = more detail
- User can request "more detail" or "simplify" at any time
- Historical digests archived in `Resources/Digests/`

---

*Last updated: 2026-03-10*

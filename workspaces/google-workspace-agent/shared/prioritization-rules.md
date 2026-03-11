# Prioritization Rules

> Urgency/importance criteria for email triage.

## Urgency Detection

### Keywords That Signal Urgency

- `urgent`, `asap`, `emergency`, `critical`
- `deadline`, `overdue`
- `today`, `now`, `immediately`
- `action required`, `response needed`

### Contextual Urgency Boosters

- Email has a deadline mentioned within 3 days
- Sender has emailed 3+ times without response
- Email references an event occurring within 24 hours

---

## Importance Classification

### Always Important Senders

*(None specified - agent will learn patterns over time)*

### Sender Patterns

| Pattern | Priority Boost |
|---------|---------------|
| Direct report | +2 |
| External client | +2 |
| Manager/skip-level | +3 |
| Domain in VIP list | +1 |

### Topic Importance

Topics matching user's interests (AI, coding, productivity, neurodiversity, entrepreneurship) receive +1 priority boost.

---

## Deprioritization Rules

### Ignore Patterns

- "unsubscribe" in body
- "no-reply@" or "noreply@" sender
- "newsletter" or "digest" in subject (unless flagged)
- Marketing/promotional keywords
- Auto-reply / out-of-office
- Emails with "AI-Digest" label (Label_16) - skip entirely

### Auto-Archive Conditions

- Email is promotional AND older than 7 days
- Newsletter NOT from starred senders AND older than 14 days
- No action required AND no calendar reference

---

## Priority Scoring

### Formula

```
Priority Score = (Urgency) + (Importance) - (Deprioritization)
```

### Score Ranges

| Score | Priority Level | Action |
|-------|---------------|--------|
| 8-10 | Critical | Surface immediately |
| 5-7 | High | Include in next digest |
| 3-4 | Medium | Batch for weekly review |
| 0-2 | Low | Archive or auto-file |

---

## User-Specific Overrides

*(No custom overrides configured yet)*

---

## Usage Notes

- Urgency keywords are case-insensitive
- Sender matching supports wildcards (`*@domain.com`)
- Priority scores are recalculated on each digest cycle
- User can manually adjust priority of any email

---

*Last updated: 2026-03-10*

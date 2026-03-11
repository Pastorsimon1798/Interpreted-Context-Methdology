# Email Categories

> Email taxonomy for triage classification.

## Standard Categories

### action-required

**Definition:** Emails requiring a response or task completion.

**Detection Rules:**
- Direct questions addressed to user
- Requests with deadlines
- "Please review/approve/respond" language
- Meeting requests requiring confirmation
- Contains urgent keywords (urgent, asap, critical, deadline, overdue)

**Label Color:** `red`

---

### job-alert

**Definition:** Job postings, recruiter outreach, and application updates.

**Detection Rules:**
- Sender contains "job", "recruit", "hiring", "career"
- LinkedIn Job Alerts, Indeed, job boards
- Recruiter emails (internal or agency)
- Application confirmations and status updates
- Company career portal notifications

**Handling:** Keep in inbox - user is actively job searching

**Label Color:** `purple`

---

### newsletter

**Definition:** Subscribed periodic content with potential knowledge value.

**Detection Rules:**
- Sender contains "newsletter", "digest", "substack"
- User has subscribed (not spam)
- Regular cadence (daily/weekly/monthly)
- Contains industry insights, not just marketing

**Handling:** Keep for PARA extraction, do not auto-archive

**Label Color:** `blue`

---

### reference

**Definition:** Information to retain for future lookup.

**Detection Rules:**
- Contains credentials, codes, or access info
- Receipts, confirmations, bookings
- Documentation or how-to guides
- Account-related communications

**Auto-Filing:** `enabled`

**Label Color:** `gray`

---

### social

**Definition:** Personal and networking communications.

**Detection Rules:**
- Social media notifications
- Personal contacts
- Event invitations (non-work)

**Label Color:** `green`

---

### promotional

**Definition:** Pure marketing and sales spam only.

**Detection Rules:**
- "unsubscribe" link present AND no valuable content
- Promotional keywords (sale, offer, discount)
- Marketing email patterns
- NOT from subscribed newsletters
- NOT job-related

**Auto-Archive:** Yes

**Label Color:** `yellow`

---

### low-priority

**Definition:** Notifications that don't require attention.

**Detection Rules:**
- Auto-generated notifications
- System alerts
- FYI-only messages
- CC'd on large threads

**Label Color:** `default`

---

## Category Hierarchy

When an email matches multiple categories, apply in order:

1. action-required (always wins if detected)
2. job-alert (high priority - active job search)
3. newsletter (contains valuable content)
4. reference
5. social
6. promotional
7. low-priority

---

## Category Actions

| Category | Auto-Label | Auto-Archive | Digest Inclusion |
|----------|------------|--------------|------------------|
| action-required | Yes | No | Always |
| job-alert | Yes | No | Always |
| newsletter | Yes | No | Yes (extract to PARA) |
| reference | Yes | After filing | Summary only |
| social | Yes | After 30 days | Optional |
| promotional | Yes | Yes | No |
| low-priority | Yes | Yes | No |

---

## Examples

```
Email from: jobalerts-noreply@linkedin.com
Subject: "data analyst: Solomon Page - Data Analyst and more"
Classification: job-alert
Action: Keep in inbox, include in digest
```

```
Email from: thecomplexityedge@substack.com
Subject: "You Were the System's Favorite Explanation"
Classification: newsletter
Action: Keep for PARA extraction
```

```
Email from: brew@simplygoodcoffee.com
Subject: "No Time For Plastic. No Time For Complicated."
Classification: promotional
Action: Auto-archive
```

---

*Last updated: 2026-03-10*

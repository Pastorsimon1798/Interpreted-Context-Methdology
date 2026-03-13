# Email Categories

> Email taxonomy for triage classification.

## Standard Categories

### action-required

**Definition:** Emails requiring a response or task completion from YOU.

**Detection Rules:**
- Direct questions addressed to you
- Requests with deadlines
- "Please review/approve/respond" language
- Meeting requests requiring confirmation
- Support tickets awaiting your reply
- Contains urgent keywords (urgent, asap, critical, deadline, overdue)

**Label Color:** `red`

**Stays in Inbox:** YES - until action completed

---

### valuable-promo

**Definition:** Tech/AI provider promotions that are actually relevant to your workflow.

**Detection Rules:**
- Keywords: "free credits", "bonus", "discount code", "save $", "% off", "trial", "limited time"
- From known tech providers YOU USE (AI tools, cloud services, dev tools, SaaS subscriptions)
- Free inference/credits (Anthropic, OpenAI, etc.)
- Credit offers for services you're paying for
- Loyalty rewards or referral bonuses

**Keywords to Surface:**
```
free inference
free credits
bonus credits
discount code
promo code
save $
% off
limited offer
expires
trial extension
credit added
your account
```

**From Providers (examples):**
- AI/LLM: Anthropic, OpenAI, Google AI, Kilocode, Cursor, Replit, v0
- Cloud: AWS, GCP, Azure, Vercel, Railway, Render
- Dev Tools: GitHub, GitLab, Linear, Notion
- SaaS: Any subscription you actively pay for

**Label Color:** `orange`

**Stays in Inbox:** YES - review and act on deal

---

### job-alert

**Definition:** Job postings, recruiter outreach, and application updates (non-LinkedIn).

**Detection Rules:**
- Sender contains "job", "recruit", "hiring", "career" (not LinkedIn)
- Indeed, job boards, company portals
- Recruiter emails (internal or agency)
- Application confirmations and status updates
- Company career portal notifications

**Handling:** Keep in inbox - user is actively job searching

**Label Color:** `purple`

---

### linkedin-job

**Definition:** LinkedIn job-related emails to keep in inbox.

**Detection Rules:**
- Sender contains "linkedin"
- Subject contains: "job alert", "job opening", "recommended job", "applied", "your application"

**Handling:** Keep in inbox - job search priority

**Auto-Archive:** No

**Label Color:** `purple`

---

### linkedin-marketing

**Definition:** LinkedIn promotional emails to auto-archive.

**Detection Rules:**
- Sender contains "linkedin"
- Subject contains: "upgrade", "premium", "try", "discover", "people also viewed", "trending", "new features", "you appeared"

**Handling:** Auto-archive immediately

**Auto-Archive:** Yes

**Label Color:** `yellow`

---

### linkedin-notification

**Definition:** LinkedIn notifications (default LinkedIn category).

**Detection Rules:**
- Sender contains "linkedin"
- Does not match linkedin-job or linkedin-marketing patterns

**Handling:** Auto-archive immediately

**Auto-Archive:** Yes

**Label Color:** `yellow`

---

### provider-blog

**Definition:** Newsletter/blog content from tech providers you use - valuable for knowledge extraction.

**Detection Rules:**
- From known tech/AI providers
- Contains "blog", "newsletter", "update", "new feature", "announcement"
- NOT a promo (no discounts/codes)
- Educational or product update content

**Handling:** Label and keep for KB extraction, then archive

**Label Color:** `blue`

---

### newsletter

**Definition:** Subscribed periodic content with potential knowledge value (non-provider).

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
- Security alerts

**Auto-Filing:** `enabled`

**Label Color:** `gray`

---

### social

**Definition:** Active community and networking communications you engage with.

**Detection Rules:**
- Skool community notifications
- Discord server messages
- Personal contacts
- Event invitations (communities you're active in)

**Label Color:** `green`

**Auto-Archive:** No (you're active in these communities)

---

### promotional

**Definition:** Pure marketing and sales spam - no value, to YOU specifically.

**Detection Rules:**
- "unsubscribe" link present AND no valuable content
- Promotional keywords (sale, offer, discount)
- Marketing email patterns
- NOT from subscribed newsletters
- NOT job-related
- NOT from tech providers you use (see provider-rules.md)
- NOT containing actionable promos (see valuable-promo)
- NOT from active communities (see social)

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
- NOT from active communities

**Label Color:** `default`

---

## Category Hierarchy

When an email matches multiple categories, apply in order:

1. action-required (always wins if detected)
2. valuable-promo (actionable tech deals)
3. linkedin-job (job search priority)
4. job-alert (high priority - active job search)
5. provider-blog (valuable content from tools you use)
6. newsletter (contains valuable content)
7. reference (security/receipts)
8. linkedin-marketing (promotional LinkedIn)
9. linkedin-notification (other LinkedIn)
10. social
11. promotional
12. low-priority

---

## Category Actions

| Category | Auto-Label | Auto-Archive | Digest Inclusion |
|----------|------------|--------------|------------------|
| action-required | Yes | No | Always |
| valuable-promo | Yes | No | Always - highlight |
| linkedin-job | Yes | No | Always |
| job-alert | Yes | No | Always |
| provider-blog | Yes | After KB extraction | Yes (extract to PARA) |
| newsletter | Yes | No | Yes (extract to PARA) |
| linkedin-marketing | Yes | Yes | No |
| linkedin-notification | Yes | Yes | No |
| reference | Yes | After filing | Summary only |
| social | Yes | After 30 days | Optional |
| promotional | Yes | Yes | No |
| low-priority | Yes | Yes | No |

---

## Examples

```
Email from: noreply@anthropic.com
Subject: "You have $5 in free credits added to your account"
Classification: valuable-promo
Action: Keep in inbox, highlight in digest
```

```
Email from: team@kilocode.com
Subject: "Kilocode Blog: Building Better Agents with Context"
Classification: provider-blog
Action: Keep for KB extraction, then archive
```

```
Email from: offers@cursor.sh
Subject: "50% off Pro plan - this week only"
Classification: valuable-promo
Action: Keep in inbox - relevant discount
```

```
Email from: jobalerts-noreply@linkedin.com
Subject: "data analyst: Solomon Page - Data Analyst and more"
Classification: linkedin-job
Action: Keep in inbox, include in digest
```

```
Email from: messages-noreply@linkedin.com
Subject: "You appeared in 15 searches this week"
Classification: linkedin-notification
Action: Auto-archive
```

```
Email from: messages-noreply@linkedin.com
Subject: "Upgrade to Premium to see who viewed your profile"
Classification: linkedin-marketing
Action: Auto-archive
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

## Provider Rules

Create a `provider-rules.md` file to define:
- Which providers you use (for valuable-promo and provider-blog detection)
- Which promos are relevant vs ignorable
- Custom handling per provider

---

*Last updated: 2026-03-12*

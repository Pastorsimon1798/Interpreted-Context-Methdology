# Onboarding Questionnaire

<!-- Agent instructions: Read this file when the user types "setup". First run the Pre-Setup Check
     to verify tool prerequisites. If all checks pass, ask ALL questions in a single conversational
     pass. The user should be able to answer everything in one message. Collect answers. Replace
     placeholders across the specified files. After all replacements, verify no {{PLACEHOLDER}}
     patterns remain in the workspace. -->

<!-- Questionnaire design rules:
     1. FLAT STRUCTURE: No category groupings. Just a numbered list of questions.
     2. ALL AT ONCE: Every question appears in one pass. The user answers in one message.
     3. SYSTEM-LEVEL ONLY: Questions configure the production system, not a specific run.
        Per-run details are collected conversationally at the start of each pipeline run.
     4. DERIVE, DON'T ASK: If a field can be derived from other answers or tools, the agent fills
        it in without asking. List derived fields under the question they depend on.
     5. SENSIBLE DEFAULTS: Every question should have a default or example so the user
        can skip what they don't care about.
     6. ASK ONCE, NEVER AGAIN: After setup, the user should never be asked these questions
        again. The answers are baked into the workspace files permanently. -->

---

## Pre-Setup Check

Before asking preference questions, verify tool prerequisites:

### Step 1: Check gws CLI Installation

Run: `gws --version`

- If SUCCESS: Note the version, proceed to Step 2
- If FAIL: Guide user through installation:
  1. Ensure Node.js 18+ is installed (`node --version`)
  2. Run `npm install -g @googleworkspace/cli`
  3. Re-run `gws --version` to verify

### Step 2: Check gws Authentication

Run: `gws auth status`

- If SUCCESS (shows authenticated account): Proceed to Step 3
- If FAIL: Guide user through authentication:
  1. Run `gws auth login`
  2. Browser opens for OAuth consent
  3. Select account and approve scopes
  4. If "Google hasn't verified this app" appears, click Continue
  5. Re-run `gws auth status` to verify

### Step 3: Verify API Access

Run these commands to confirm API access:

```
gws gmail users.messages.list --params '{"userId": "me", "maxResults": 1}'
gws calendar calendarList.list
```

- If BOTH succeed: Proceed to questionnaire
- If Gmail fails: Gmail API not enabled. Run `gws auth setup` or enable manually in GCP Console
- If Calendar fails: Calendar API not enabled. Run `gws auth setup` or enable manually

**If any step fails and cannot be resolved:** Direct user to `setup/gws-setup.md` for detailed troubleshooting.

---

## Questionnaire

### Q1: Calendar Selection

I can see your available calendars. Which one should I manage?

- Action: Run `gws calendar calendarList.list` and present the list as numbered options
- Placeholder: `{{AGENT_CALENDAR_ID}}`
- Files: `shared/calendar-preferences.md`, `stages/03-calendar/CONTEXT.md`
- Type: selection (from API response)
- Default: Primary calendar (first in list, typically user's email)

---

### Q2: Knowledge Base Location

Where should I store your knowledge base? This folder will contain markdown files organized by PARA (Projects, Areas, Resources, Archive).

- Placeholder: `{{KNOWLEDGE_BASE_PATH}}`
- Files: `shared/para-structure.md`, `stages/02-extraction/CONTEXT.md`
- Type: free text (absolute path)
- Default: `~/knowledge-base`
- Example: `/Users/yourname/Documents/notes`

---

### Q3: Trust Level

How much autonomy should I have? This affects which actions require your confirmation.

- Placeholder: `{{TRUST_LEVEL}}`
- Files: `CLAUDE.md`, `stages/*/CONTEXT.md`
- Type: selection
- Options:
  - `supervised` - I propose actions, you approve each one
  - `partial` - I execute routine tasks, escalate sensitive ones
  - `autonomous` - I act independently, report what I did
- Default: `supervised`

---

### Q4: Digest Frequency

How often should I compile activity summaries?

- Placeholder: `{{DIGEST_FREQUENCY}}`
- Files: `shared/digest-template.md`, `stages/04-digest/CONTEXT.md`
- Type: selection
- Options: `daily`, `weekly`
- Default: `daily`

---

### Q5: Working Hours

What are your typical working hours? I'll avoid scheduling meetings outside these times.

- Placeholders: `{{WORKING_HOURS_START}}`, `{{WORKING_HOURS_END}}`
- Files: `shared/calendar-preferences.md`
- Type: free text (24-hour format)
- Default: `09:00` to `17:00`

---

### Q6: Default Reminder

How many minutes before events should I set reminders?

- Placeholder: `{{DEFAULT_REMINDER}}`
- Files: `shared/calendar-preferences.md`
- Type: free text (number)
- Default: `15`

---

### Q7: Focus Block Duration

How long should focus blocks be when I schedule deep work time? (minutes)

- Placeholder: `{{FOCUS_BLOCK_DURATION}}`
- Files: `shared/calendar-preferences.md`
- Type: free text (number)
- Default: `90`

---

### Q8: Urgent Keywords

List words/phrases that indicate urgency. I'll prioritize these automatically.

- Placeholder: `{{URGENT_KEYWORDS}}`
- Files: `shared/prioritization-rules.md`
- Type: free text (comma-separated)
- Default: `urgent, asap, emergency, critical, deadline today, time-sensitive`

---

### Q9: Important Senders

List email addresses or domains that are always important.

- Placeholder: `{{IMPORTANT_SENDERS}}`
- Files: `shared/prioritization-rules.md`
- Type: free text (comma-separated)
- Default: (leave blank)
- Example: `boss@company.com, @exec-team.com`

---

### Q10: Topics of Interest

What topics, projects, or keywords are you actively tracking?

- Placeholder: `{{TOPICS_OF_INTEREST}}`
- Files: `shared/extraction-rules.md`
- Type: free text (comma-separated)
- Default: (leave blank to learn from behavior)
- Example: `Q4 planning, product launch, AI strategy`

---

### Q11: Active Projects (PARA)

List your current active projects. One per line. I'll create project folders.

- Placeholder: `{{ACTIVE_PROJECTS}}`
- Files: `shared/para-structure.md`
- Type: free text (one per line)
- Default: (leave blank to add later)

---

### Q12: Life Areas (PARA)

What areas of responsibility define your life? These become PARA categories.

- Placeholder: `{{LIFE_AREAS}}`
- Files: `shared/para-structure.md`
- Type: free text (comma-separated)
- Default: `Health, Finances, Career, Relationships, Personal Growth`

---

## After Onboarding

Once you provide your answers, I will:

1. Replace all `{{PLACEHOLDER}}` values across the workspace
2. Create your knowledge base folder structure
3. Initialize PARA categories with your projects and areas
4. Confirm the configuration is complete

You can then start using the agent by saying:
- "Check my inbox"
- "What's on my calendar today?"
- "Summarize my emails from yesterday"
- "Create a focus block for tomorrow morning"

---

After all replacements, scan the entire workspace for remaining `{{` patterns. If any remain, ask for the missing info.

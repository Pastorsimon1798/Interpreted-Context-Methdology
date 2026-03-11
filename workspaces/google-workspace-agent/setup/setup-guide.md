# Interactive Setup Guide

This workspace uses an interactive agent-driven setup, not a static questionnaire.

## Trigger

When user says `setup`, the agent runs this interactive flow.

---

## Setup Flow

### Phase 1: Verify Prerequisites

Check if the agent can connect to Google Workspace.

```
1. Run: `gws --version`
   - If not found: Guide user to install:
     ```
     npm install -g @googleworkspace/cli
     ```
   - Retry after installation.

2. Run: `gws auth status`
   - If not authenticated: Guide user through:
     ```
     gws auth login
     ```
   - Opens browser for OAuth consent.
   - User completes authorization.
   - Retry check.

3. Verify access:
   ```
   gws gmail messages list --params '{"maxResults": 1}'
   gws calendar calendarList list
   ```
   - If errors: Diagnose (API not enabled, scope issues, etc.)
   - See troubleshooting in `gws-setup.md`.
```

### Phase 2: Fetch Account Info

Query the user's actual Google Workspace data.

```
4. Get available calendars:
   Run: `gws calendar calendarList list --params '{"minAccessRole": "writer"}'`

   Present to user:
   "I found these calendars you can manage:
    1. Primary (your-email@gmail.com)
    2. Work Calendar (work@company.com)
    3. Family (family@gmail.com)

    Which should I manage? [1/2/3]"

   Store selection as AGENT_CALENDAR_ID.

5. Get user's email (from auth context or first calendar):
   Store as USER_EMAIL.
```

### Phase 3: Collect Preferences

Ask 4-5 questions conversationally. User can answer all at once.

```
6. "Where should I store your knowledge base? (folder path)"
   - Default: ~/google-workspace-agent/knowledge-base
   - Create folder if it doesn't exist
   - Initialize PARA structure inside

7. "How much autonomy should I have?"
   - supervised: I propose, you approve each action
   - partial: I handle routine, escalate sensitive items
   - autonomous: I act independently, report what I did
   - Default: supervised

8. "What are your working hours?"
   - Default: 09:00 - 17:00

9. "Any urgent keywords I should watch for? (comma-separated)"
   - Default: urgent, asap, emergency, critical, deadline
   - Optional: skip to use defaults

10. "Any senders that are always important? (email addresses)"
    - Default: none
    - Optional: skip
```

### Phase 4: Write Configuration

Create the config file with actual values (not placeholders).

```markdown
# Write to: shared/config.md

---
generated: 2026-03-10T...
calendar_id: [user's selection]
knowledge_base_path: [user's path]
trust_level: supervised|partial|autonomous
working_hours:
  start: "09:00"
  end: "17:00"
urgent_keywords: [list]
important_senders: [list]
---
```

### Phase 5: Initialize Knowledge Base

```
11. Create PARA folder structure:
    mkdir -p {knowledge_base_path}/{projects,areas,resources,archive}

12. Create initial files:
    - projects/.gitkeep
    - areas/.gitkeep
    - resources/.gitkeep
    - archive/.gitkeep
```

### Phase 6: Verify and Complete

```
13. Run verification:
    - `gws gmail messages list --params '{"maxResults": 1}'` ✓
    - `gws calendar events list --params '{"calendarId": "{CALENDAR_ID}", "maxResults": 1}'` ✓

14. Report success:
    "Setup complete!

     Connected to: [user's email]
     Managing calendar: [calendar name]
     Knowledge base: [path]
     Trust level: [level]

     Try these commands:
     - 'check my inbox'
     - 'what's on my calendar today'
     - 'summarize recent emails'"
```

---

## Configuration File

After setup, all config lives in `shared/config.md`:

```markdown
# Workspace Configuration

Generated: {{SETUP_DATE}}

## Account
- **Email:** {{USER_EMAIL}}
- **Calendar ID:** {{AGENT_CALENDAR_ID}}

## Preferences
- **Trust Level:** {{TRUST_LEVEL}}
- **Working Hours:** {{WORKING_HOURS_START}} - {{WORKING_HOURS_END}}
- **Knowledge Base:** {{KNOWLEDGE_BASE_PATH}}

## Prioritization
- **Urgent Keywords:** {{URGENT_KEYWORDS}}
- **Important Senders:** {{IMPORTANT_SENDERS}}
```

---

## Re-running Setup

User can say `setup` again to reconfigure. Agent should:
1. Show current config
2. Ask which values to change
3. Update config file

---

## Troubleshooting

If setup fails, see `setup/gws-setup.md` for:
- Installation issues
- Authentication problems
- API enablement
- Scope limits
- Test user configuration

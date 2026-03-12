# PROGRESS.md

Session continuity file for resuming work across conversations. This file persists state so agents can pick up where they left off.

---

## Current State

<!-- What is actively being worked on right now -->

**Status:** `{{STATUS}}` <!-- one of: STARTED | IN_PROGRESS | BLOCKED | COMPLETE | PAUSED -->

**Active Stage:** `{{ACTIVE_STAGE}}` <!-- e.g., 02-discovery -->

**Last Action:** {{LAST_ACTION}} <!-- one sentence: what was just done -->

---

## Recent Changes

<!-- Brief log of what changed in recent sessions. Keep last 5 entries. -->

| Date | Change | Stage |
|------|--------|-------|
| {{DATE}} | {{CHANGE_DESCRIPTION}} | {{STAGE}} |

---

## Next Steps

<!-- Ordered list of immediate next actions. Be specific. -->

1. {{NEXT_STEP_1}}
2. {{NEXT_STEP_2}}
3. {{NEXT_STEP_3}}

---

## Blockers

<!-- Issues preventing progress. Delete section if none. -->

| Blocker | Impact | Resolution Needed |
|---------|--------|-------------------|
| {{BLOCKER}} | {{IMPACT}} | {{WHO_OR_WHAT_NEEDED}} |

---

## Decisions

<!-- Key decisions made during this work. Prevents re-litigating. -->

| Decision | Rationale | Date |
|----------|-----------|------|
| {{DECISION}} | {{RATIONALE}} | {{DATE}} |

---

## Context Notes

<!-- Working memory: observations, patterns noticed, things to remember for this specific run. Not permanent reference material. -->

{{CONTEXT_NOTES}}

---

## How to Use This File

**For Agents:**
1. Read this file at the start of each session to understand current state
2. Update after each significant action or stage completion
3. Keep entries concise - this is a dashboard, not a log

**For Humans:**
1. Edit Next Steps to redirect agent focus
2. Add Blockers when external input is needed
3. Record Decisions to prevent circular discussions

**Reset:**
- When starting a new pipeline run, archive this file and start fresh
- Keep decisions that apply across runs, reset stage-specific state

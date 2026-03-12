# PROGRESS.md

Session continuity file for resuming work across conversations. This file persists state so agents can pick up where they left off.

---

## Current State

**Status:** `STARTED`

**Active Stage:** None

**Last Action:** Workspace initialized

---

## Recent Changes

| Date | Change | Stage |
|------|--------|-------|
| 2026-03-11 | PROGRESS.md created during workspace remediation | setup |

---

## Next Steps

1. Run `triage` to process inbox
2. Run `standup` for morning routine
3. Run `digest` to generate activity summary

---

## Blockers

None

---

## Decisions

| Decision | Rationale | Date |
|----------|-----------|------|
| 4-stage pipeline | triage → extraction → calendar → digest | 2026-03-10 |

---

## Context Notes

GWS Agent is read-only by default. Uses ADHD-friendly persona for prioritized workflows.

Trust levels:
- `supervised` - Pause at every checkpoint
- `partial` - Skip checkpoints for trusted stages
- `autonomous` - Run all stages, show only digest

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
- When starting a new triage cycle, archive and start fresh
- Keep decisions that apply across runs, reset stage-specific state

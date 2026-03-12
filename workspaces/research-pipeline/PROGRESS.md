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

1. Run `research [topic]` to start a new research pipeline
2. Run `monitor` to check for knowledge base gaps
3. Run `status` to see current pipeline state

---

## Blockers

None

---

## Decisions

| Decision | Rationale | Date |
|----------|-----------|------|
| Research pipeline structure | 6-stage flow from scoping to publish | 2026-03-10 |

---

## Context Notes

Research pipeline supports three modes:
- `research [topic]` - Full pipeline with checkpoints
- `research email [topic]` - Full pipeline + email delivery
- `research quick [topic]` - Fast research, skips scoping

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

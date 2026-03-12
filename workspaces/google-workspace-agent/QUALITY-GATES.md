# QUALITY-GATES.md

Inter-stage verification checkpoints for the Google Workspace agent.

---

## Gate Structure

Each gate has two layers:
- **Layer 1 (Structural):** Machine-verifiable checks (file exists, format correct, no placeholders)
- **Layer 2 (Semantic):** Content quality checks (alignment with goals, completeness, coherence)

---

## Gate: Pre-Pipeline

**Trigger:** Before triage begins

### Layer 1 (Structural)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| GWS authenticated | `gws` CLI connected | Run `gws auth` |
| No stale outputs | output/ folders empty or intentionally preserved | Ask user to clear or confirm |

### Layer 2 (Semantic)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| Clear task intent | User wants triage, extraction, calendar, or digest | Ask what to do |

**Human Gate:** If no task specified, ask user for direction.

---

## Gate: Triage → Extraction

**Trigger:** After 01-triage completes, before 02-extraction begins

### Layer 1 (Structural)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| Triage report exists | `stages/01-triage/output/triage-report.md` exists | Re-run triage |
| Emails categorized | Categories assigned to processed emails | Re-run categorization |

### Layer 2 (Semantic)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| Actionable items surfaced | Emails requiring action identified | Review triage rules |
| Priority correct | High-priority emails flagged | Check prioritization rules |

**Human Gate:** Present high-priority items for review (unless autonomous mode).

---

## Gate: Extraction → Calendar

**Trigger:** After 02-extraction completes, before 03-calendar begins

### Layer 1 (Structural)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| Extraction log exists | `stages/02-extraction/output/extraction-log.md` exists | Re-run extraction |

### Layer 2 (Semantic)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| Knowledge extracted | KB-worthy content identified | Review extraction rules |
| PARA structure followed | Items routed to correct folder | Check PARA rules |

**Human Gate:** None (proceed automatically if structural checks pass).

---

## Gate: Calendar → Digest

**Trigger:** After 03-calendar completes, before 04-digest begins

### Layer 1 (Structural)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| Calendar log exists | `stages/03-calendar/output/calendar-log.md` exists | Re-run calendar |

### Layer 2 (Semantic)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| Events processed | Calendar items created or updated | Review calendar rules |

**Human Gate:** None (proceed automatically if structural checks pass).

---

## Gate: Post-Pipeline

**Trigger:** After 04-digest completes

### Layer 1 (Structural)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| Digest exists | `stages/04-digest/output/digest.md` exists | Re-run digest |

### Layer 2 (Semantic)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| Summary complete | All stages represented in digest | Complete digest |
| Actionable summary | Clear next steps surfaced | Review digest template |

**Human Gate:** Present digest for review (unless autonomous mode).

---

## Trust Level Integration

The `{{TRUST_LEVEL}}` placeholder controls gate behavior:

| Level | Human Gates | Auto-Proceed |
|-------|-------------|--------------|
| `supervised` | All gates pause | Never |
| `partial` | Only high-priority gates | Structural + low-risk semantic |
| `autonomous` | None | All gates |

---

## Quick Reference

| Gate | Human Gate? | Key Check |
|------|-------------|-----------|
| Pre-Pipeline | Yes (if no task) | GWS authenticated |
| Triage → Extraction | Yes (supervised/partial) | High-priority items |
| Extraction → Calendar | No | KB-worthy content |
| Calendar → Digest | No | Events processed |
| Post-Pipeline | Yes (supervised/partial) | Digest complete |

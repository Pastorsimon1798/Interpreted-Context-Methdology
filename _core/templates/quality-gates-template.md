# QUALITY-GATES.md

Inter-stage verification checkpoints. This file defines quality gates that run between stages to catch issues before they propagate.

---

## Gate Structure

Each gate has two layers:

- **Layer 1 (Structural):** Machine-verifiable checks (file exists, format correct, no placeholders)
- **Layer 2 (Semantic):** Content quality checks (alignment with goals, completeness, coherence)

---

## Gate: Pre-Pipeline

**Trigger:** Before Stage 01 begins

### Layer 1 (Structural)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| Workspace initialized | CLAUDE.md and CONTEXT.md exist | Run `setup` |
| No stale outputs | output/ folders empty or intentionally preserved | Ask user to clear or confirm |
| No unresolved placeholders | No `{{.*}}` patterns in non-template files | Run `setup` to fill |

### Layer 2 (Semantic)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| Clear intent | User stated what they want to produce | Ask clarifying questions |
| Scope defined | Boundaries of work are understood | Request scope clarification |

**Human Gate:** If intent is ambiguous, pause for clarification before proceeding.

---

## Gate: {{STAGE_NAME_1}} → {{STAGE_NAME_2}}

**Trigger:** After {{STAGE_NAME_1}} completes, before {{STAGE_NAME_2}} begins

### Layer 1 (Structural)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| Output exists | `stages/0N-{{stage}}/output/` contains files | Re-run previous stage |
| Format valid | Output matches expected format | Fix or re-generate |
| No placeholders | No `{{.*}}` in output files | Fill placeholders |

### Layer 2 (Semantic)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| Completeness | All required sections present | Complete missing sections |
| Alignment | Output addresses scope from Stage 01 | Revise or re-scope |
| Quality floor | Meets minimum quality standards | Revise output |

**Human Gate:** If semantic checks fail twice, pause for human review.

---

## Gate: {{STAGE_NAME_2}} → {{STAGE_NAME_3}}

<!-- Duplicate and customize for each stage transition -->

**Trigger:** After {{STAGE_NAME_2}} completes, before {{STAGE_NAME_3}} begins

### Layer 1 (Structural)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| Output exists | `stages/0N-{{stage}}/output/` contains files | Re-run previous stage |
| Format valid | Output matches expected format | Fix or re-generate |

### Layer 2 (Semantic)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| [Check name] | [What passing looks like] | [Recovery action] |

**Human Gate:** [When to pause for human review]

---

## Gate: Post-Pipeline

**Trigger:** After final stage completes

### Layer 1 (Structural)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| Final output exists | Output file(s) in final stage output/ | Re-run final stage |
| No placeholders | No `{{.*}}` in final output | Fill or remove |

### Layer 2 (Semantic)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| Meets original intent | Output delivers what was requested | Revise or re-scope |
| Quality review | Output is production-ready | Revise |

**Human Gate:** Final output requires explicit human approval before publication/delivery.

---

## Gate Execution

**Automatic Gates:** Layer 1 checks run automatically. Failures block progression.

**Escalation:** Layer 2 failures after 2 revision attempts trigger human gate.

**Human Gates:** Pause and present options. Do not proceed without direction.

**Logging:** Record gate results in PROGRESS.md under "Recent Changes".

---

## How to Customize

1. Duplicate the stage transition gate template for each stage pair
2. Fill in specific structural and semantic checks for each transition
3. Define human gate triggers based on stage verifiability classification
4. Remove any checks that do not apply to the workspace

---

## Quick Reference

| Gate Type | Who Checks | Recovery |
|-----------|-----------|----------|
| Layer 1 (Structural) | Agent auto-check | Fix automatically |
| Layer 2 (Semantic) | Agent assesses | Revise, then escalate |
| Human Gate | User reviews | User decides direction |

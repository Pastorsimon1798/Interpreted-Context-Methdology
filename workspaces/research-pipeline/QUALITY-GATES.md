# QUALITY-GATES.md

Inter-stage verification checkpoints for the research pipeline.

---

## Gate Structure

Each gate has two layers:
- **Layer 1 (Structural):** Machine-verifiable checks (file exists, format correct, no placeholders)
- **Layer 2 (Semantic):** Content quality checks (alignment with goals, completeness, coherence)

---

## Gate: Pre-Pipeline

**Trigger:** Before research begins

### Layer 1 (Structural)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| Workspace initialized | CLAUDE.md and CONTEXT.md exist | Run `setup` |
| No stale outputs | output/ folders empty or intentionally preserved | Ask user to clear or confirm |

### Layer 2 (Semantic)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| Clear research intent | User stated topic or question | Ask clarifying questions |
| Scope boundaries | What is in/out of scope is understood | Request scope clarification |

**Human Gate:** If topic is ambiguous, pause for clarification.

---

## Gate: Scoping → Discovery

**Trigger:** After 01-scoping completes, before 02-discovery begins

### Layer 1 (Structural)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| Scoping output exists | `stages/01-scoping/output/` contains scoping artifact | Re-run scoping |
| Goal defined | Research goal clearly stated | Complete scoping |

### Layer 2 (Semantic)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| Questions actionable | Key questions can guide search | Revise questions |
| Methodology appropriate | Approach matches topic complexity | Revise methodology |

**Human Gate:** Present research goal for confirmation before proceeding.

---

## Gate: Discovery → Analysis

**Trigger:** After 02-discovery completes, before 03-analysis begins

### Layer 1 (Structural)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| Sources gathered | `stages/02-discovery/output/` contains source findings | Re-run discovery |
| Sources credible | Credibility scores assigned | Add credibility assessment |

### Layer 2 (Semantic)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| Sufficient coverage | Sources address all key questions | Expand search |
| Quality floor | At least 3 credible sources per major question | Find more sources |

**Human Gate:** None (proceed automatically if structural checks pass).

---

## Gate: Analysis → Synthesis

**Trigger:** After 03-analysis completes, before 04-synthesis begins

### Layer 1 (Structural)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| Analysis output exists | `stages/03-analysis/output/` contains analysis artifact | Re-run analysis |

### Layer 2 (Semantic)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| Findings extracted | Key insights surfaced from each source | Deepen analysis |
| Patterns identified | Common themes or contradictions noted | Review analysis |

**Human Gate:** None (proceed automatically if structural checks pass).

---

## Gate: Synthesis → Output

**Trigger:** After 04-synthesis completes, before 05-output begins

### Layer 1 (Structural)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| Synthesis output exists | `stages/04-synthesis/output/` contains synthesis artifact | Re-run synthesis |

### Layer 2 (Semantic)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| Conclusions drawn | Answers to research questions stated | Complete synthesis |
| Contradictions addressed | Conflicting findings explained or flagged | Address gaps |

### Layer 3 (Quality Scoring)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| RQS calculated | Research Quality Score computed using `scoring/RQS-CALCULATOR.md` | Calculate RQS |
| RQS ≥ 60 | Minimum quality threshold met | Return to synthesis with improvement guidance |
| RQS logged | Score recorded in `PROGRESS.md` Quality Metrics section | Log score |
| Experiment logged | If experiment was run, log to `IMPROVEMENT-LOG.md` | Log experiment |

**RQS-Based Routing:**

| RQS Score | Action |
|-----------|--------|
| 90-100 | Flag for KB archiving, proceed to output |
| 75-89 | Auto-approve for archive, proceed to output |
| 60-74 | Acceptable, proceed to output |
| <60 | Return to synthesis stage |

**Human Gate:** Present conclusions AND RQS score for review before generating final output.

---

## Gate: Output → Publish

**Trigger:** After 05-output completes, before 06-publish begins

### Layer 1 (Structural)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| Report exists | Output file generated in `stages/05-output/output/` | Re-run output |
| Format correct | Markdown structure follows template | Fix formatting |

### Layer 2 (Semantic)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| Complete report | All sections populated | Complete missing sections |
| Meets original goal | Output addresses research intent | Revise or re-scope |

**Human Gate:** Final report requires approval before publication.

---

## Gate: Post-Pipeline

**Trigger:** After 06-publish completes

### Layer 1 (Structural)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| Delivery confirmed | Email sent or file uploaded | Retry publish |

### Layer 2 (Semantic)

| Check | Pass Condition | On Fail |
|-------|---------------|---------|
| User satisfied | Research need addressed | Collect feedback |

**Human Gate:** Optional feedback collection.

---

## Quick Reference

| Gate | Human Gate? | Key Check |
|------|-------------|-----------|
| Pre-Pipeline | Yes (if ambiguous) | Clear research intent |
| Scoping → Discovery | Yes | Goal confirmation |
| Discovery → Analysis | No | Sources gathered |
| Analysis → Synthesis | No | Findings extracted |
| Synthesis → Output | Yes | Conclusions + RQS review |
| Output → Publish | Yes | Final approval |
| Post-Pipeline | Optional | Delivery confirmed |

# Improvement Log

Self-improving experiment system for research quality. Inspired by Karpathy's autoresearch pattern: experiments generate, run, evaluate, and evolve automatically.

---

## Core Principle

**The experiment system improves itself.** Not just research quality, but the experiments themselves get smarter over time.

---

## Self-Improving Loop

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  ┌──────────────┐    ┌──────────────┐    ┌───────────┐ │
│  │   ANALYZE    │───▶│   SELECT     │───▶│    RUN    │ │
│  │  (weakness)  │    │ (experiment) │    │ (research)│ │
│  └──────────────┘    └──────────────┘    └───────────┘ │
│         ▲                                       │       │
│         │                                       ▼       │
│  ┌──────────────┐    ┌──────────────┐    ┌───────────┐ │
│  │   EVOLVE     │◀───│   SCORE      │◀───│   LOG     │ │
│  │ (new ideas)  │    │  (result)    │    │  (RQS)    │ │
│  └──────────────┘    └──────────────┘    └───────────┘ │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Experiment Scoring

Each experiment tracks its effectiveness. This drives selection priority.

### Experiment Score Formula

```
Experiment Score = (Success Rate × 0.4) + (Avg Δ × 0.3) + (Recency Bonus × 0.2) + (Diversity × 0.1)
```

| Factor | How Calculated | Why It Matters |
|--------|----------------|----------------|
| **Success Rate** | % of runs where Δ ≥ +3 | Proven experiments get priority |
| **Avg Δ** | Average RQS improvement | Bigger improvements are better |
| **Recency Bonus** | +10 if not run in last 3 sessions | Avoid running same experiment repeatedly |
| **Diversity** | +5 if targets different component than last run | Don't over-optimize one factor |

### Experiment Scorecard

| ID | Experiment | Runs | Successes | Success% | Avg Δ | Score |
|----|------------|------|-----------|----------|-------|-------|
| A001 | Add arXiv to discovery | 0 | 0 | -- | -- | 50 (baseline) |
| A002 | Add Google Scholar | 0 | 0 | -- | -- | 50 (baseline) |
| A003 | Credibility in synthesis | 0 | 0 | -- | -- | 50 (baseline) |
| A004 | Recency filter | 0 | 0 | -- | -- | 50 (baseline) |
| A005 | KB cross-reference | 0 | 0 | -- | -- | 50 (baseline) |
| A006 | Counterargument section | 0 | 0 | -- | -- | 50 (baseline) |
| A007 | Implementation steps | 0 | 0 | -- | -- | 50 (baseline) |
| A008 | Credibility threshold | 0 | 0 | -- | -- | 50 (baseline) |

---

## Smart Selection

Experiments are selected based on multiple factors, not just "fewest runs".

### Selection Algorithm

```python
def select_experiment():
    # 1. Identify weakest RQS component
    weak_component = min(RQS_components, key=score)

    # 2. Filter experiments targeting that component
    candidates = experiments.where(target=weak_component)

    # 3. Score each candidate
    for exp in candidates:
        exp.score = calculate_score(exp)

    # 4. Pick highest scoring
    return max(candidates, key=score)
```

### Selection Priority Matrix

| Priority | Condition | Selection |
|----------|-----------|-----------|
| 1 | Component score < 50 | Experiment targeting that component |
| 2 | No experiment run in 3+ sessions | Highest-scored untested experiment |
| 3 | Experiment has high success rate (>70%) | Proven winner |
| 4 | Default | Experiment with fewest runs |

---

## Experiment Generation

New experiments are **auto-generated** based on patterns in completed experiments.

### Generation Triggers

| Trigger | What Happens |
|---------|--------------|
| Same component weak for 3+ sessions | Generate 2 new experiments for that component |
| Experiment failed 3 times | Generate variant with different approach |
| Experiment succeeded 3 times | Generate "level 2" version (more ambitious) |
| No experiments left for component | Generate new experiment ideas |

### Generation Templates

**For Credibility:**
- "Add [source type] to discovery" → New source types
- "Filter sources below [threshold]" → Different thresholds
- "Prioritize [source attribute]" → New attributes

**For Depth:**
- "Require [N] sources per finding" → Different counts
- "Add [section type] to synthesis" → New sections
- "Cross-reference with [knowledge source]" → New references

**For Actionability:**
- "Add [template] to output" → New templates
- "Include [decision tool]" → New tools
- "Structure recommendations as [format]" → New formats

### Auto-Generated Experiments

| ID | Generated Date | Based On | Experiment | Status |
|----|----------------|----------|------------|--------|
| -- | -- | -- | -- | -- |

*(Experiments will be auto-generated as patterns emerge)*

---

## Experiment Retirement

Experiments that don't work are removed from rotation automatically.

### Retirement Rules

| Condition | Action |
|-----------|--------|
| Failed 3+ times with avg Δ < 0 | **Retire** - remove from pool |
| Failed 3+ times with avg Δ 0-2 | **Downgrade** - move to LOW-RISK |
| Succeeded 3+ times with avg Δ ≥ +3 | **Graduate** - becomes standard practice |
| Not run in 10+ sessions | **Archive** - move to backlog |

### Retired Experiments

| ID | Retired Date | Reason | Avg Δ |
|----|--------------|--------|-------|
| -- | -- | -- | -- |

### Graduated Experiments (Standard Practice)

| Experiment | Graduated | Avg Δ | Now In |
|------------|-----------|-------|--------|
| -- | -- | -- | -- |

---

## Experiment Types

| Type | Runs When | Approval | Auto-Generate? |
|------|-----------|----------|----------------|
| **AUTO** | Every session | Never | Yes |
| **LOW-RISK** | Default ON | Can opt out | Yes |
| **HIGH-RISK** | Explicit only | Required | No (manual only) |

### AUTO Experiments (Always Run)

| ID | Experiment | Target | Runs | Success% | Score | Status |
|----|------------|--------|------|----------|-------|--------|
| A001 | Add arXiv to discovery | Credibility | 0 | -- | 50 | ready |
| A002 | Add Google Scholar | Credibility | 0 | -- | 50 | ready |
| A003 | Credibility in synthesis | Depth | 0 | -- | 50 | ready |
| A004 | Recency filter | Recency | 0 | -- | 50 | ready |
| A005 | KB cross-reference | Gap Fill | 0 | -- | 50 | ready |
| A006 | Counterargument section | Depth | 0 | -- | 50 | ready |
| A007 | Implementation steps | Actionability | 0 | -- | 50 | ready |
| A008 | Credibility threshold | Credibility | 0 | -- | 50 | ready |

### LOW-RISK Experiments

| ID | Experiment | Target | Runs | Success% | Score | Status |
|----|------------|--------|------|----------|-------|--------|
| L001 | 3 sources per finding | Depth | 0 | -- | 50 | queued |
| L002 | Actionability checklist | Actionability | 0 | -- | 50 | queued |
| L003 | Exclude >2yr sources (AI) | Recency | 0 | -- | 50 | queued |
| L004 | Decision matrix | Actionability | 0 | -- | 50 | queued |
| L005 | Note-taking template | Depth | 0 | -- | 50 | queued |

### HIGH-RISK Experiments

| ID | Experiment | Target | Status |
|----|------------|--------|--------|
| H001 | Synthesis template overhaul | All | needs-approval |
| H002 | Change RQS weightings | All | needs-approval |
| H003 | Parallel discovery agents | Credibility | needs-approval |

---

## RQS Trend

| Period | Avg RQS | Trend | Experiments | Best Δ | Notes |
|--------|---------|-------|-------------|--------|-------|
| Baseline (2026-03-11) | -- | → | 0 | -- | System initialized |

---

## Completed Experiments

| ID | Date | Experiment | Before | After | Δ | Component | Success? |
|----|------|------------|--------|-------|---|-----------|----------|
| -- | -- | -- | -- | -- | -- | -- | -- |

---

## Pattern Learning

After each experiment, extract patterns to inform future generation.

### What We've Learned

| Pattern | Evidence | Implication |
|---------|----------|-------------|
| -- | -- | -- |

*(Patterns will be extracted as experiments complete)*

### Pattern Extraction Rules

After logging an experiment:

1. **If success:** What made it work? → Add to pattern library
2. **If failure:** Why did it fail? → Add to anti-pattern library
3. **If mixed:** What conditions helped/hurt? → Add context rules

Example patterns:
- "Source additions work better for technical topics"
- "Threshold filters fail when sources are already high-quality"
- "Template changes have delayed impact (show up in next session)"

---

## Default Session Behavior

```
research [topic]
  → ANALYZE: Find weakest RQS component
  → SELECT: Pick best experiment for that component
  → RUN: Execute research with experiment
  → SCORE: Calculate RQS, compare to baseline
  → LOG: Record result with component breakdown
  → LEARN: Extract pattern from result
  → EVOLVE: Generate new experiments if triggers met
  → RETIRE: Check retirement conditions
```

---

## Session Startup

1. **Read PROGRESS.md** → Get current RQS and component scores
2. **Identify weakness** → Find lowest-scoring component
3. **Select experiment** → Use smart selection (not just fewest runs)
4. **Check generation triggers** → Create new experiments if needed
5. **Check retirement** → Remove failed experiments
6. **Report** → Show last 3 results, current experiment, why selected

---

## Experiment Budget

| Constraint | Limit | Notes |
|------------|-------|-------|
| AUTO per session | 1 | Always runs |
| LOW-RISK per session | 1 | Optional |
| HIGH-RISK per week | 1 | Requires approval |
| Max AUTO experiments in pool | 15 | Retire oldest when exceeded |
| Min runs before retirement | 3 | Give experiments fair chance |
| Graduation threshold | +3 avg Δ over 3 runs | Becomes standard practice |

---

## Success Metrics

| Metric | Target | Current |
|--------|--------|---------|
| Experiments per session | 1 | 0 |
| Experiment success rate | >60% | -- |
| Avg improvement per successful experiment | +5 RQS | -- |
| Experiments graduated per month | 2 | 0 |
| New experiments generated per month | 4 | 0 |
| RQS improvement over 30 days | +10 points | -- |
| Pattern extraction rate | 100% | 0% |

---

## Quick Reference

### Selection
```
weakest component → target that → highest score → run it
```

### Scoring
```
Score = (Success% × 0.4) + (AvgΔ × 0.3) + (Recency × 0.2) + (Diversity × 0.1)
```

### Generation
```
3 weak sessions → generate for component
3 failures → generate variant
3 successes → generate "level 2"
```

### Retirement
```
3 fails with Δ < 0 → retire
3 fails with Δ 0-2 → downgrade
3 wins with Δ ≥ 3 → graduate
```

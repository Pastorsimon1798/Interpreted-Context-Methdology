# Research Quality Score (RQS) Calculator

A unified scoring system that combines multiple quality dimensions into a single, trackable metric for measuring research output quality over time.

---

## Overview

RQS provides a single number (0-100) that represents overall research quality, enabling:
- Cross-session quality tracking
- Experiment effectiveness measurement
- Quality-based archiving decisions

---

## Formula

```
RQS = (Source Credibility × 0.35) + (Depth × 0.25) + (Actionability × 0.20) + (Recency × 0.10) + (Gap Fill × 0.10)
```

---

## Component Scoring

### 1. Source Credibility (35% weight)

**Derived from:** `stages/02-discovery/utils/credibility.md`

**Calculation:**
1. Score each source using the credibility system (0-100)
2. Calculate weighted average: `(sum of scores) / (number of sources)`
3. Apply floor bonus: If minimum credibility threshold met, +5 points

| Tier | Score Range | Research Usage |
|------|-------------|----------------|
| High | 70-100 | Primary evidence |
| Medium | 40-69 | Supporting evidence |
| Low | 20-39 | Background only |
| Exclude | <20 | Not used |

**Example:**
```
Source 1: 72 (High)
Source 2: 58 (Medium)
Source 3: 81 (High)
Source 4: 45 (Medium)
Source 5: 65 (Medium)

Average = (72 + 58 + 81 + 45 + 65) / 5 = 64.2
Floor bonus (all ≥40): +5
Source Credibility Score: 69.2
```

---

### 2. Depth (25% weight)

**Measures:** How thoroughly research questions are answered.

**Scoring:**

| Score | Criteria |
|-------|----------|
| 90-100 | All questions fully answered with nuanced analysis, multiple perspectives, and evidence synthesis |
| 70-89 | All questions answered with supporting evidence, some gaps in nuance |
| 50-69 | Most questions answered, some shallow or incomplete responses |
| 30-49 | Key questions partially answered, significant gaps |
| 0-29 | Questions largely unanswered or superficially addressed |

**Evaluation Checklist:**
- [ ] Each research question has a dedicated answer
- [ ] Answers include specific evidence from sources
- [ ] Multiple sources support major claims
- [ ] Contradictions between sources are addressed
- [ ] Implications and context are explained

**Example:**
```
5 research questions:
- Q1: Fully answered with 4 sources ✓
- Q2: Fully answered with 3 sources ✓
- Q3: Answered but only 1 source (partial)
- Q4: Fully answered with 2 sources ✓
- Q5: Briefly addressed, no specific sources (shallow)

Depth Score: 70 (3 full, 1 partial, 1 shallow)
```

---

### 3. Actionability (20% weight)

**Measures:** How useful the research is for decision-making.

**Scoring:**

| Score | Criteria |
|-------|----------|
| 90-100 | Clear recommendations with specific next steps, prioritized actions, and decision criteria |
| 70-89 | Recommendations provided with some guidance on implementation |
| 50-69 | General direction suggested but lacks specificity |
| 30-49 | Findings presented but no clear path forward |
| 0-29 | Information only, no actionable insights |

**Evaluation Checklist:**
- [ ] Executive summary highlights key decisions
- [ ] Specific recommendations are stated
- [ ] Recommendations are prioritized (high/medium/low)
- [ ] Trade-offs between options are explained
- [ ] Next steps are clearly identified

**Example:**
```
Research on "Best CI/CD tool for startup":
- Recommendation: "GitHub Actions" ✓
- Rationale: Cost-effective, good ecosystem ✓
- Alternatives considered: GitLab CI, CircleCI ✓
- Implementation steps: Not provided ✗
- Priority/timeline: Not provided ✗

Actionability Score: 65 (has recommendation, lacks implementation detail)
```

---

### 4. Recency (10% weight)

**Measures:** How current the information is.

**Scoring:**

| Score | Criteria |
|-------|----------|
| 90-100 | All sources <6 months old, real-time data included |
| 70-89 | Most sources <1 year old, key sources current |
| 50-69 | Mix of recent and older sources, key sources <2 years |
| 30-49 | Most sources 2-5 years old |
| 0-29 | Sources >5 years old or no dates found |

**Note:** For stable domains (history, established science), recency requirements are relaxed. For fast-moving domains (AI, security), recency is critical.

**Domain Multipliers:**
- Fast-moving (AI, crypto, security): ×1.0 (full weight)
- Standard (software, business): ×0.8
- Stable (history, mathematics): ×0.5

**Example:**
```
AI research (fast-moving domain):
- 3 sources from 2024 (<6 months): High recency
- 2 sources from 2023 (1-2 years): Medium recency
- 0 sources older than 2 years

Base Recency Score: 85
Domain Multiplier: ×1.0
Recency Score: 85
```

---

### 5. Gap Fill (10% weight)

**Measures:** Whether the research addresses known knowledge gaps.

**Source:** Gap priorities from `stages/00-monitor/references/relevance-criteria.md`

**Scoring:**

| Score | Criteria |
|-------|----------|
| 90-100 | Directly addresses HIGH priority gap with comprehensive coverage |
| 70-89 | Addresses gap with good coverage, some aspects missing |
| 50-69 | Partially addresses gap or addresses MEDIUM priority gap |
| 30-49 | Tangentially related to gap or addresses LOW priority gap |
| 0-29 | No gap relationship, general research |

**Gap Priority Mapping:**
- HIGH priority: Known knowledge gap from KB analysis
- MEDIUM priority: Related to existing KB but extends it
- LOW priority: New topic, not yet assessed for gaps

**Example:**
```
Research topic: "RAG evaluation benchmarks"
KB gap analysis shows: HIGH priority gap in "evaluation methods for RAG systems"

Gap Fill Score: 85 (directly addresses HIGH priority gap)
```

---

## Complete Scoring Example

**Research:** "Evaluation Paradigms for AI Coding Assistants"

### Component Scores

| Component | Raw Score | Weight | Weighted Score |
|-----------|-----------|--------|----------------|
| Source Credibility | 72 | 0.35 | 25.2 |
| Depth | 78 | 0.25 | 19.5 |
| Actionability | 65 | 0.20 | 13.0 |
| Recency | 85 | 0.10 | 8.5 |
| Gap Fill | 80 | 0.10 | 8.0 |

### RQS Calculation

```
RQS = 25.2 + 19.5 + 13.0 + 8.5 + 8.0 = 74.2
```

**Rounded RQS: 74**

---

## Score Interpretation

| RQS Range | Quality Level | Archive Decision | KB Consideration |
|-----------|--------------|------------------|------------------|
| 90-100 | Exceptional | `archive/high-value/` | Immediate KB integration |
| 75-89 | High Quality | `archive/reviewed/` | KB candidate, review for integration |
| 60-74 | Acceptable | `archive/reviewed/` | May have value, manual review needed |
| <60 | Below Threshold | `archive/rejected/` | Do not add to KB |

---

## RQS Thresholds for Pipeline

| Threshold | Action |
|-----------|--------|
| RQS ≥ 90 | Flag for immediate KB archiving, no human review needed |
| RQS ≥ 75 | Auto-approve for archive, flag for KB consideration |
| RQS ≥ 60 | Acceptable, proceed to output |
| RQS < 60 | Return to synthesis stage, quality improvement required |

---

## Scoring Process

### When to Calculate RQS

**Mandatory:** After synthesis stage, before output generation

**Optional:** After each stage to track quality accumulation

### Calculation Steps

1. **Gather component data**
   - Source credibility scores from discovery stage
   - Research questions and answers from scoping/analysis
   - Recommendations from synthesis
   - Source dates for recency
   - Gap priorities from monitor stage

2. **Score each component** (0-100)

3. **Apply weights and sum**

4. **Record in PROGRESS.md**
   ```markdown
   ## Quality Metrics
   - **Current RQS:** 74
   - **Components:** Cred:72, Depth:78, Act:65, Rec:85, Gap:80
   - **Trend:** ↗
   ```

5. **Compare to thresholds**
   - If RQS < 60: Return to synthesis with improvement guidance
   - If RQS ≥ 60: Proceed to output

---

## Quick Reference

```
RQS = (Credibility × 0.35) + (Depth × 0.25) + (Actionability × 0.20) + (Recency × 0.10) + (Gap Fill × 0.10)

Pass: RQS ≥ 60
Archive: RQS ≥ 75
KB Candidate: RQS ≥ 75
High-Value: RQS ≥ 90
```

# Stage 04: Synthesis

Combine findings into coherent conclusions through multi-pass analysis.

## Inputs

| Source | File/Location | Section/Scope | Why |
|--------|--------------|---------------|-----|
| Previous stage | `../03-analysis/output/findings-analyzed.md` | Full file | Findings to synthesize |
| Previous stage | `../02-discovery/output/sources-collected.md` | Credibility scores | Source quality data |
| Previous stage | `../01-scoping/output/research-goal.md` | Goal, questions | Research target |
| Brand vault | `../../brand-vault.md` | Research Style | Style preferences |
| Reference | `references/synthesis-patterns.md` | Full file | Argumentation structures |

## Multi-Pass Synthesis Process

### Pass 1: Gather & Score

1. Read all analyzed findings from 03-analysis
2. Read credibility scores from 02-discovery
3. Rank findings by source credibility (High > Medium > Low)
4. Group findings by research question

### Pass 2: Detect Contradictions

5. **For each key question:**
   - Extract all positions from sources
   - Identify conflicting claims (Source A says X, Source B says Y)
   - Document the contradiction with source citations

**Contradiction template:**
```markdown
| Topic | Position A | Source A (Score) | Position B | Source B (Score) |
|-------|------------|------------------|------------|------------------|
| [Issue] | [Claim X] | [Citation] (75) | [Claim Y] | [Citation] (45) |
```

### Pass 3: Resolve Contradictions

6. **Apply credibility hierarchy:**
   - High tier (70+) sources take precedence
   - If equal scores, note uncertainty
   - If recent vs older, prefer recent (unless historical topic)
   - Document resolution reasoning

**Resolution template:**
```markdown
## Resolution: [Topic]
- **Accepted:** [Position] from [Source] (Score: 75)
- **Rejected:** [Position] from [Source] (Score: 45)
- **Reasoning:** [Source A] has higher credibility due to [academic source, primary research, etc.]
```

### Pass 4: Identify Gaps

7. **For each research question:**
   - Check if fully answered
   - Identify missing perspectives
   - Note areas with only low-credibility sources

**Gap analysis template:**
```markdown
| Question | Status | Gap Description | Impact |
|----------|--------|-----------------|--------|
| [Q1] | Partially answered | No industry perspective | Limits practical applicability |
| [Q2] | Unanswered | No sources found | Major gap |
| [Q3] | Fully answered | None | N/A |
```

### Pass 5: Structure Narrative

8. Organize conclusions into coherent narrative:
   - Lead with highest-confidence conclusions
   - Address contradictions explicitly
   - Acknowledge gaps honestly
   - End with confidence level for each conclusion

9. **[Checkpoint]** Present key conclusions with evidence
10. Run audit checks, revise if needed
11. Write synthesized knowledge document to output/

## Checkpoints

| After Step | Agent Presents | Human Decides |
|------------|---------------|---------------|
| 8 | Key conclusions with evidence, contradictions resolved, and gaps identified | Whether conclusions are well-supported and gaps are acceptable |

## Audit

| Check | Pass Condition |
|-------|---------------|
| Evidence supports conclusions | Each conclusion has 2+ supporting sources from High/Medium tier |
| Contradictions addressed | All conflicts documented with resolution reasoning |
| Resolution credibility | Contradictions resolved using higher-credibility sources |
| Gaps acknowledged | Unanswered questions and missing perspectives stated |
| Confidence levels | Each conclusion has confidence rating (High/Medium/Low) |
| Logical coherence | Conclusions follow from findings |
| Questions answered | Each key question has response (even if "insufficient evidence") |

## Output Format

The `knowledge-synthesized.md` output must include:

```markdown
# Synthesis: [Topic]

## Executive Summary
[2-3 sentence overview with overall confidence level]

## Synthesis by Question

### Question 1: [Question]

**Answer:** [Synthesized answer]

**Confidence:** [High/Medium/Low]

**Supporting Evidence:**
- [Finding] — Source: [Citation] (Credibility: [score])
- [Finding] — Source: [Citation] (Credibility: [score])

**Contradictions Resolved:**
| Conflict | Resolution | Reasoning |
|----------|------------|-----------|
| [Issue] | [Position chosen] | [Why this source is more credible] |

**Remaining Gaps:**
- [Gap description]

### Question 2: [Question]

[Repeat structure]

## Knowledge Gaps Summary

| Gap | Impact on Conclusions | Recommended Follow-up |
|-----|----------------------|----------------------|
| [Gap 1] | [Impact] | [Action] |

## Confidence Assessment

| Area | Confidence | Reason |
|------|------------|--------|
| [Area 1] | High | Multiple high-credibility sources agree |
| [Area 2] | Medium | Some contradiction, resolved with better source |
| [Area 3] | Low | Only low-credibility sources available |
```

## Outputs

| Artifact | Location | Format |
|----------|----------|--------|
| Synthesized knowledge | `output/knowledge-synthesized.md` | Conclusions, contradictions resolved, gaps, confidence levels |

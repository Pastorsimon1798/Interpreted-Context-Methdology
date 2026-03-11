# Stage 02: Discovery

Gather information from web, documents, and other sources with credibility scoring.

## Inputs

| Source | File/Location | Section/Scope | Why |
|--------|--------------|---------------|-----|
| Previous stage | `../01-scoping/output/research-goal.md` | Full file | Research plan |
| Brand vault | `../../brand-vault.md` | Quality Thresholds | Source standards |
| Skill | `../../skills/web-research/SKILL.md` | Full file | Search capability |
| Reference | `references/search-strategies.md` | Full file | Search patterns |
| Utility | `utils/credibility.md` | Full file | Scoring system |

## Process

1. Read research goal and key questions from previous stage
2. Plan search strategy for each key question
3. Execute searches using web-research skill
4. **For each source found:**
   - Extract domain metadata (TLD, HTTPS, URL path)
   - Assess content indicators (author, date, type)
   - Calculate credibility score using `utils/credibility.md`
   - Assign tier (High/Medium/Low/Unreliable)
5. Filter sources below threshold (default: 40 points)
6. Collect sources with annotations (relevance to questions, credibility score)
7. Organize sources by question coverage
8. Identify source gaps needing additional search
9. **[Checkpoint]** Present source summary with credibility assessment
10. Run audit checks, revise if needed
11. Write collected sources document to output/

## Credibility Thresholds

| Tier | Score Range | Usage |
|------|-------------|-------|
| High | 70+ | Primary evidence, cited directly |
| Medium | 40-69 | Supporting evidence, noted with caveat |
| Low | 20-39 | Background only, not cited |
| Unreliable | <20 | Exclude entirely |

**Default minimum: 40 points**

## Checkpoints

| After Step | Agent Presents | Human Decides |
|------------|---------------|---------------|
| 8 | Source collection with credibility ratings and coverage map | Whether sources are sufficient |

## Audit

| Check | Pass Condition |
|-------|---------------|
| Source diversity | Sources from multiple domains/types |
| Credibility verified | Each source has credibility score and tier |
| Threshold applied | Sources below 40 points excluded from conclusions |
| Question coverage | Every key question has relevant sources (High/Medium tier) |
| Proper attribution | All sources have complete citations |

## Output Format

The `sources-collected.md` output must include credibility data:

```markdown
# Sources Collected: [Topic]

## Summary
- Total sources found: [N]
- High credibility (70+): [N]
- Medium credibility (40-69): [N]
- Low credibility (<40): [N] - excluded from conclusions

## Sources by Question

### Question 1: [Question]

#### High Credibility Sources (70+)

**[Source Title]**
- URL: [url]
- Credibility: [score] (High)
- Scoring: [+30 .edu, +10 /research/, +5 https, +5 recent]
- Relevance: [How it answers the question]
- Key Quote: [Relevant excerpt]

#### Medium Credibility Sources (40-69)

[Same format]

### Question 2: [Question]

[Repeat structure]

## Excluded Sources (Below Threshold)

[List sources that didn't meet 40-point threshold with reasons]
```

## Outputs

| Artifact | Location | Format |
|----------|----------|--------|
| Collected sources | `output/sources-collected.md` | Annotated list with credibility scores and tiers |

# Stage 03: Analysis

Process collected sources and extract insights.

## Inputs

| Source | File/Location | Section/Scope | Why |
|--------|--------------|---------------|-----|
| Previous stage | `../02-discovery/output/sources-collected.md` | Full file | Sources to analyze |
| Previous stage | `../01-scoping/output/research-goal.md` | Key questions | Questions to answer |
| Reference | `references/analysis-frameworks.md` | Full file | Categorization patterns |
| Security | `../../shared/security/CONTEXT.md` | Full file | Sanitization rules |
| Skill | `../../skills/security-input-sanitization/SKILL.md` | Full file | Injection protection |

## Process

1. Read all collected sources and annotations
2. **[Security]** Re-sanitize any quotes/excerpts before extraction
3. Apply categorization framework (theme, type, finding)
4. Extract key findings from each source
5. Link findings to specific research questions
6. Identify patterns across multiple sources
7. Note contradictions between sources
8. Identify gaps in evidence
9. Organize findings by question and theme
10. Run audit checks, revise if needed
11. Write analyzed findings document to output/

## Verifiability

**Classification:** `MACHINE-VERIFIABLE`

**Verification Method:** Findings extracted can be counted, categorization structure can be validated, pattern detection can be verified.

**Human Review Trigger:** None required. Auto-proceed to synthesis if audit passes.

## Checkpoints

| After Step | Agent Presents | Human Decides |
|------------|---------------|---------------|
| 11 (Write findings) | findings-analyzed.md with categorized insights | Approve analysis before synthesis |

## Audit

| Check | Pass Condition |
|-------|---------------|
| All sources processed | Every source has extracted findings |
| Findings categorized | Organized by theme and question |
| Patterns identified | Cross-source patterns noted |
| Evidence linked | Each claim linked to source |
| Contradictions noted | Conflicting findings identified |
| Excerpts sanitized | All quoted content passed security check |

## Outputs

| Artifact | Location | Format |
|----------|----------|--------|
| Analyzed findings | `output/findings-analyzed.md` | Categorized findings, patterns, contradictions |

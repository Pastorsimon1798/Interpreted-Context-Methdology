# Research Pipeline

A configurable, general-purpose research workflow that transforms any starting input into structured deliverables.

## Folder Map

```
research-pipeline/
├── CLAUDE.md              (you are here)
├── CONTEXT.md             (start here for task routing)
├── PROGRESS.md            (session state + quality metrics)
├── IMPROVEMENT-LOG.md     (experiment tracking)
├── QUALITY-GATES.md       (inter-stage verification)
├── brand-vault.md         (research style and quality preferences)
├── setup/                 (onboarding questionnaire)
├── scoring/               (quality scoring system)
│   └── RQS-CALCULATOR.md  (unified quality score)
├── archive/               (research outputs by quality)
│   ├── high-value/        (RQS 90+)
│   ├── reviewed/          (RQS 60-89)
│   └── rejected/          (RQS <60)
├── skills/                (bundled Claude skills)
│   ├── web-research/      (web search and source evaluation)
│   └── gws-publish/       (Google Drive publishing)
├── stages/
│   ├── 00-monitor/        (watch for research opportunities)
│   ├── 01-scoping/        (define goal and methodology)
│   ├── 02-discovery/      (gather information)
│   ├── 03-analysis/       (process and extract insights)
│   ├── 04-synthesis/      (combine and conclude)
│   ├── 05-output/         (generate deliverable)
│   └── 06-publish/        (push to Google Drive)
└── shared/                (cross-stage reference files)
```

## Triggers

| Keyword | Action |
|---------|--------|
| `research [topic]` | Full pipeline + 1 AUTO experiment (default) |
| `research strict [topic]` | Full pipeline, skip all experiments |
| `research email [topic]` | Full pipeline + 1 AUTO experiment + email PDF |
| `research quick [topic]` | Fast research: skip scoping, still runs AUTO experiment |
| `research high-risk [id] [topic]` | Full pipeline + specific HIGH-RISK experiment (needs approval) |
| `monitor` | Read raw discovery data, score against KB topics, output prioritized digest |
| `monitor email` | Same as `monitor` + send digest via email |
| `monitor topics` | Show topics mined from ~/knowledge-base/ |
| `monitor gaps` | Show only knowledge gaps detected |
| `quality` | Show RQS scores, trends, component weakness analysis |
| `improve` | Run pattern analysis, check generation triggers, show recommendations |
| `experiments` | Show experiment scores, graduation candidates, retirement candidates |
| `setup` | Run onboarding questionnaire |
| `status` | Show pipeline completion for all stages |
| `resume` | Read PROGRESS.md and continue from last checkpoint |

## Research Trigger Workflows

### `research [topic]` — Full Pipeline + Experiment (DEFAULT)
Runs all stages in sequence, with 1 AUTO experiment:
0. **Select experiment** → Pick AUTO experiment with fewest runs from IMPROVEMENT-LOG.md
1. **01-scoping** → Define goal, methodology, key questions
2. **02-discovery** → Gather sources with credibility scoring + experiment applied
3. **03-analysis** → Extract and analyze findings
4. **04-synthesis** → Combine findings, detect contradictions
5. **05-output** → Generate markdown + PDF report
6. **Log experiment** → Record RQS result in IMPROVEMENT-LOG.md

**Pauses:** Checkpoints at scoping (confirm goal) and synthesis (review conclusions + RQS)

### `research strict [topic]` — No Experiments
Same pipeline but skips all experiments. Use for:
- Comparison baselines
- Time-sensitive research
- When you need consistent methodology

### `research email [topic]` — Full Pipeline + Experiment + Email
Same as `research [topic]` plus:
7. **06-publish** → Email PDF with AI-Research-Report label

**Email format:**
- Body: Executive summary
- Attachment: `report-YYYY-MM-DD-topic.pdf`
- Label: `AI-Research-Report`

### `research quick [topic]` — Fast Research
Skips detailed scoping but still runs AUTO experiment:
0. **Select experiment** → Pick AUTO experiment
1. Use default scoping (topic as research goal)
2. **02-discovery** → Quick source gathering + experiment
3. **03-analysis** → Rapid analysis
4. **04-synthesis** → Brief synthesis
5. **05-output** → Markdown report only (no PDF)
6. **Log experiment** → Record result

**Use for:** Simple lookups, quick fact-checks, preliminary research

### `research high-risk [id] [topic]` — Specific HIGH-RISK Experiment
Runs a specific HIGH-RISK experiment (requires approval):
- Use experiment ID from IMPROVEMENT-LOG.md (e.g., H001, H002)
- These are major methodology changes that need explicit consent
- Example: `research high-risk H001 AI coding assistants`

## Routing

| Task | Go To |
|------|-------|
| Find research opportunities | `stages/00-monitor/CONTEXT.md` |
| Define research scope and methodology | `stages/01-scoping/CONTEXT.md` |
| Gather information from sources | `stages/02-discovery/CONTEXT.md` |
| Process and analyze findings | `stages/03-analysis/CONTEXT.md` |
| Synthesize conclusions | `stages/04-synthesis/CONTEXT.md` |
| Generate final deliverable | `stages/05-output/CONTEXT.md` |
| Publish to Google Drive | `stages/06-publish/CONTEXT.md` |

## What to Load

| Task | Load These | Do NOT Load |
|------|-----------|-------------|
| Monitor sources | 00-monitor/CONTEXT.md, config/sources.yaml, references/relevance-criteria.md, shared/skills/doc-analysis/SKILL.md | stages 01-06 |
| Scope research | 01-scoping/CONTEXT.md, brand-vault.md, shared/methodology-guide.md, shared/skills/doc-analysis/SKILL.md | stages 02-06 |
| Gather sources | 02-discovery/CONTEXT.md, 01-scoping/output/, skills/web-research/SKILL.md, shared/skills/code-analysis/SKILL.md, shared/skills/doc-analysis/SKILL.md | stages 03-06, brand-vault |
| Analyze findings | 03-analysis/CONTEXT.md, 02-discovery/output/, 01-scoping/output/, shared/skills/doc-analysis/SKILL.md | stages 04-06, skills |
| Synthesize | 04-synthesis/CONTEXT.md, 03-analysis/output/, brand-vault.md, shared/skills/doc-analysis/SKILL.md | stages 01-02, 05-06, skills |
| Generate output | 05-output/CONTEXT.md, 04-synthesis/output/, brand-vault.md, shared/skills/doc-analysis/SKILL.md | stages 01-03, 06, skills |
| Publish to Drive | 06-publish/CONTEXT.md, 05-output/output/, skills/gws-publish/SKILL.md, shared/skills/doc-analysis/SKILL.md | stages 01-04 |
| Check quality | PROGRESS.md, IMPROVEMENT-LOG.md, scoring/RQS-CALCULATOR.md | stages, skills |
| Run experiments | IMPROVEMENT-LOG.md, PROGRESS.md, brand-vault.md | stages 01-03 |

## Stage Handoffs

Each stage writes its output to its own `output/` folder. The next stage reads from there. If you edit an output file, the next stage picks up your edits.

**Full pipeline flow:**
00-monitor → 01-scoping → 02-discovery → 03-analysis → 04-synthesis → 05-output → 06-publish

You can pause between any stage to review or edit.

## Quality Improvement System

### Research Quality Score (RQS)

Every research output is scored using RQS (0-100):

```
RQS = (Source Credibility × 0.35) + (Depth × 0.25) + (Actionability × 0.20) + (Recency × 0.10) + (Gap Fill × 0.10)
```

| RQS Range | Quality | Archive Decision |
|-----------|---------|------------------|
| 90-100 | Exceptional | `archive/high-value/` |
| 75-89 | High Quality | `archive/reviewed/` |
| 60-74 | Acceptable | `archive/reviewed/` |
| <60 | Below Threshold | `archive/rejected/` |

### Self-Improving Experiment System

**Experiments run by default AND the system improves itself.** The experiment system learns what works, generates new ideas, and retires failures automatically.

#### The Loop

```
ANALYZE (find weakness) → SELECT (smart pick) → RUN (research) → SCORE (RQS) → LOG (result) → LEARN (pattern) → EVOLVE (generate new) → RETIRE (remove failures)
```

#### Smart Selection (Not Random)

Experiments are selected based on:

```
Score = (Success Rate × 0.4) + (Avg Δ × 0.3) + (Recency × 0.2) + (Diversity × 0.1)
```

| Factor | Why It Matters |
|--------|----------------|
| Success Rate | Proven experiments get priority |
| Avg Δ | Bigger improvements are better |
| Recency | Don't run same experiment repeatedly |
| Diversity | Don't over-optimize one component |

**Selection:** Weakest RQS component → Target that → Highest score → Run it

#### Auto-Generation

New experiments are generated automatically:

| Trigger | Action |
|---------|--------|
| Component weak for 3+ sessions | Generate 2 new experiments for it |
| Experiment failed 3 times | Generate variant with different approach |
| Experiment succeeded 3 times | Generate "level 2" version |
| No experiments for component | Generate new ideas from templates |

#### Auto-Retirement

Experiments are removed automatically:

| Condition | Action |
|-----------|--------|
| Failed 3× with avg Δ < 0 | Retire (remove from pool) |
| Failed 3× with avg Δ 0-2 | Downgrade to LOW-RISK |
| Succeeded 3× with avg Δ ≥ +3 | Graduate to standard practice |

#### Pattern Learning

After each experiment, extract patterns:
- **Success:** What made it work? → Pattern library
- **Failure:** Why did it fail? → Anti-pattern library
- **Mixed:** What conditions mattered? → Context rules

#### Experiment Types

| Type | When It Runs | Approval | Auto-Generate? |
|------|--------------|----------|----------------|
| **AUTO** | Every session | Never | Yes |
| **LOW-RISK** | Default ON | Can opt out | Yes |
| **HIGH-RISK** | Explicit only | Required | No |

All experiments, scores, and patterns are in `IMPROVEMENT-LOG.md`.

### Quality Triggers

| Trigger | Action |
|---------|--------|
| `quality` | Show RQS scores and trends |
| `improve` | Suggest/implement improvement experiment |
| `experiments` | Show experiment status |
| `research experiment [topic]` | Run research with experiment |

### Session Startup

At session start:
1. Read `PROGRESS.md` → Get RQS and identify **weakest component**
2. Read `IMPROVEMENT-LOG.md` → Get experiment scores and patterns
3. **Select experiment** → Smart selection (targets weakness, highest score)
4. **Check generation triggers** → Create new experiments if needed
5. **Check retirement** → Remove/downgrade failed experiments
6. Report: "Running [experiment] because [component] is weak ([score])"

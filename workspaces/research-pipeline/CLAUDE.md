# Research Pipeline

A configurable, general-purpose research workflow that transforms any starting input into structured deliverables.

## Folder Map

```
research-pipeline/
├── CLAUDE.md          (you are here)
├── CONTEXT.md         (start here for task routing)
├── brand-vault.md     (research style and quality preferences)
├── setup/             (onboarding questionnaire)
├── skills/            (bundled Claude skills)
│   ├── web-research/  (web search and source evaluation)
│   └── gws-publish/   (Google Drive publishing)
├── stages/
│   ├── 00-monitor/    (watch for research opportunities)
│   ├── 01-scoping/    (define goal and methodology)
│   ├── 02-discovery/  (gather information)
│   ├── 03-analysis/   (process and extract insights)
│   ├── 04-synthesis/  (combine and conclude)
│   ├── 05-output/     (generate deliverable)
│   └── 06-publish/    (push to Google Drive)
└── shared/            (cross-stage reference files)
```

## Triggers

| Keyword | Action |
|---------|--------|
| `research [topic]` | Full pipeline: scope → discover → analyze → synthesize → output |
| `research email [topic]` | Full pipeline + send PDF attachment via email |
| `research quick [topic]` | Fast research: skip scoping, go straight to discovery |
| `monitor` | Read raw discovery data, score against KB topics, output prioritized digest |
| `monitor email` | Same as `monitor` + send digest via email |
| `monitor topics` | Show topics mined from ~/knowledge-base/ |
| `monitor gaps` | Show only knowledge gaps detected |
| `setup` | Run onboarding questionnaire |
| `status` | Show pipeline completion for all stages |
| `resume` | Read PROGRESS.md and continue from last checkpoint |

## Research Trigger Workflows

### `research [topic]` — Full Pipeline
Runs all stages in sequence:
1. **01-scoping** → Define goal, methodology, key questions
2. **02-discovery** → Gather sources with credibility scoring
3. **03-analysis** → Extract and analyze findings
4. **04-synthesis** → Combine findings, detect contradictions
5. **05-output** → Generate markdown + PDF report

**Pauses:** Checkpoints at scoping (confirm goal) and synthesis (review conclusions)

### `research email [topic]` — Full Pipeline + Email
Same as `research [topic]` plus:
6. **06-publish** → Email PDF with AI-Research-Report label

**Email format:**
- Body: Executive summary
- Attachment: `report-YYYY-MM-DD-topic.pdf`
- Label: `AI-Research-Report`

### `research quick [topic]` — Fast Research
Skips detailed scoping:
1. Use default scoping (topic as research goal)
2. **02-discovery** → Quick source gathering
3. **03-analysis** → Rapid analysis
4. **04-synthesis** → Brief synthesis
5. **05-output** → Markdown report only (no PDF)

**Use for:** Simple lookups, quick fact-checks, preliminary research

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
| Monitor sources | 00-monitor/CONTEXT.md, config/sources.yaml, references/relevance-criteria.md | stages 01-06 |
| Scope research | 01-scoping/CONTEXT.md, brand-vault.md, shared/methodology-guide.md | stages 02-06 |
| Gather sources | 02-discovery/CONTEXT.md, 01-scoping/output/, skills/web-research/SKILL.md | stages 03-06, brand-vault |
| Analyze findings | 03-analysis/CONTEXT.md, 02-discovery/output/, 01-scoping/output/ | stages 04-06, skills |
| Synthesize | 04-synthesis/CONTEXT.md, 03-analysis/output/, brand-vault.md | stages 01-02, 05-06, skills |
| Generate output | 05-output/CONTEXT.md, 04-synthesis/output/, brand-vault.md | stages 01-03, 06, skills |
| Publish to Drive | 06-publish/CONTEXT.md, 05-output/output/, skills/gws-publish/SKILL.md | stages 01-04 |

## Stage Handoffs

Each stage writes its output to its own `output/` folder. The next stage reads from there. If you edit an output file, the next stage picks up your edits.

**Full pipeline flow:**
00-monitor → 01-scoping → 02-discovery → 03-analysis → 04-synthesis → 05-output → 06-publish

You can pause between any stage to review or edit.

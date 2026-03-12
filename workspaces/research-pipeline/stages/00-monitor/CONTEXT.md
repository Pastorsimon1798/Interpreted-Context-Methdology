# Stage 00: Monitor

Autonomous discovery of research opportunities. Runs twice daily via cron, enhanced on-demand by Claude.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  SCHEDULED (cron/bash)                                          │
│  ────────────────────                                           │
│  run-monitor.sh fetches raw data → output/raw-YYYY-MM-DD-AM.md │
│  (No email - just saves raw data for Claude to process)        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  ON-DEMAND (Claude session)                                     │
│  ──────────────────────────                                     │
│  User says "monitor" → Claude reads:                            │
│  • output/raw-YYYY-MM-DD-AM.md (latest raw data)               │
│  • ~/knowledge-base/**/*.md (mine for topics)                   │
│  • references/relevance-criteria.md (scoring rules)             │
│  → Applies scoring, gap analysis, prioritization                │
│  → Outputs: output/discovery-YYYY-MM-DD-AM.md                   │
│  → "monitor email" sends digest via gws gmail                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Inputs

| Source | Location | What It Provides |
|--------|----------|------------------|
| Raw discovery data | `output/raw-YYYY-MM-DD-*.md` | Unfiltered items from HN, Reddit, arXiv, GitHub |
| Knowledge base | `~/knowledge-base/**/*.md` | Your PARA topics, saved docs, interests |
| Relevance criteria | `references/relevance-criteria.md` | Scoring rules, priority tiers |
| Source config | `config/sources.yaml` | Discovery channels (future: add more sources) |

---

## Process

### Automated (run-monitor.sh)

The bash script runs via cron at 9 AM and 5 PM:
1. Fetches from Hacker News, Reddit, arXiv, GitHub
2. Applies basic keyword filtering
3. Outputs to `output/raw-YYYY-MM-DD-AM.md`
4. **No email** — raw data waits for Claude enhancement

### On-Demand Enhancement (Claude)

When user says `monitor`, Claude:

1. **Read raw data**
   - Find latest `output/raw-*.md` file
   - Extract all discovered items

2. **Mine knowledge base**
   - List `~/knowledge-base/resources/**/*.md` and `~/knowledge-base/areas/**/*.md`
   - Extract: titles, headers, tags, first paragraph from each file
   - Build topic fingerprint for comparison

3. **Score items** using relevance-criteria.md:
   - Apply three-tier priority system (TIER 1: 10+, TIER 2: 6-9, TIER 3: 3-5)
   - Check for project keywords (ICM, mac-mini-agent, PARA+AI)
   - Apply source credibility multiplier
   - Add recency bonus

4. **Identify gaps**
   - Compare raw items to KB topics
   - Flag "You have X but not Y" patterns
   - Note trending topics across sources

5. **Output prioritized digest**
   - Write `output/discovery-YYYY-MM-DD-AM.md`
   - Format per relevance-criteria.md template

---

## Outputs

| File | Format | Purpose |
|------|--------|---------|
| `raw-YYYY-MM-DD-*.md` | Unfiltered list | Raw data from APIs (bash script) |
| `discovery-YYYY-MM-DD-*.md` | Scored digest | AI-enhanced, prioritized (Claude) |

### Discovery Digest Format

```markdown
# AI Digest - YYYY-MM-DD (AM/PM)

## 🔥 Must Know (Research Immediately)
1. **[Source] Title** - Why it matters
   - Relevance: [connection to your projects/KB]
   - [Link]

## 📌 Worth Your Time (Queue for Later)
3. **[Source] Title**
   - Why: [reason]
   - [Link]

## 📰 Background Awareness
5. Item (lower priority)

## 🔍 Knowledge Gaps Detected
- You have [X] folder but no coverage of [Y]
- Trending: [Z] matches 3 of your interests

---
💡 Suggestion: Research items #1 and #2?
```

---

## Triggers

| Trigger | Action |
|---------|--------|
| `monitor` | Read raw data, enhance with scoring, output discovery digest |
| `monitor email` | Same as `monitor` + send digest with `AI-Digest` label |
| `monitor topics` | Only show what topics were mined from KB |
| `monitor gaps` | Only show knowledge gaps (no full digest) |

## Email Labeling

Digest emails are labeled `AI-Digest` so the GWS agent can skip them.
- **Label ID:** `Label_16`
- **Purpose:** Transient actionable prompts, not knowledge to archive

To label after sending:
```bash
gws gmail users messages modify --params '{"userId":"me","id":"MESSAGE_ID"}' --json '{"addLabelIds":["Label_16"]}'
```

## GWS Agent Integration

| Content Type | Label | GWS Agent Action |
|--------------|-------|------------------|
| Digest emails | `AI-Digest` | **SKIP** — don't archive |
| Research reports | N/A | Save to `KB/Resources` in Drive |

**GWS agent config:** Add `AI-Digest` to skip list so these transient digests don't clutter your knowledge base.

**Research pipeline output:** Final reports from stage 06-publish should save to the `KB/Resources` folder in Google Drive (same location GWS agent uses).

---

## Files

```
00-monitor/
├── CONTEXT.md                    # This file
├── config/
│   └── sources.yaml              # Discovery channels
├── scripts/
│   └── run-monitor.sh            # Cron wrapper script
├── output/
│   ├── raw-YYYY-MM-DD-*.md       # Raw data (bash script output)
│   └── discovery-YYYY-MM-DD-*.md # Enhanced digest (Claude output)
└── references/
    └── relevance-criteria.md     # Scoring rules
```

---

## Scheduling

### Install Cron Jobs

```bash
cd /Users/simongonzalezdecruz/Desktop/Interpreted-Context-Methdology/workspaces/research-pipeline
./stages/00-monitor/scripts/run-monitor.sh install
```

Runs at 9:00 AM and 5:00 PM daily.

### Check Status

```bash
./stages/00-monitor/scripts/run-monitor.sh status
```

---

## Integration Notes

**Do NOT duplicate inbox mining.** The GWS agent handles:
- Reading Gmail
- Categorizing emails
- Saving to knowledge base

This stage handles:
- Reading what's already saved
- Finding NEW external content
- Expanding your knowledge universe

## Checkpoints

| After Step | Agent Presents | Human Decides |
|------------|---------------|---------------|
| 5 (Output digest) | discovery-YYYY-MM-DD-*.md with prioritized items | Approve before emailing or proceeding to research |

## Verifiability

**Classification:** `MACHINE-VERIFIABLE`

**Verification Method:** Raw data exists, scores calculated, digest formatted correctly.

**Human Review Trigger:** None required. Auto-proceed unless user wants to adjust scoring criteria.

## Audit

| Check | Pass Condition |
|-------|---------------|
| Raw data found | Latest raw-*.md file exists and has content |
| KB topics mined | Topics extracted from ~/knowledge-base/**/*.md |
| Scoring applied | All items have relevance scores |
| Tiers assigned | Items categorized as TIER 1/2/3 |
| Gaps identified | Knowledge gaps detected and listed |
| Digest formatted | Output matches discovery digest format template |

# Andrej Karpathy Release Tracker

> Persistent monitoring of all Karpathy releases, projects, and announcements.
> Last updated: 2026-03-11
> Status: ACTIVE

## Profile

- **GitHub:** https://github.com/karpathy
- **Twitter/X:** https://x.com/karpathy
- **Blog:** https://karpathy.ai
- **YouTube:** https://youtube.com/@karpathy

## Tracking Scope

| Source | Frequency | What We Track |
|--------|-----------|---------------|
| GitHub repos | Daily | New repos, major commits, releases |
| X/Twitter | Daily | Project announcements, opinions |
| YouTube | Weekly | New videos, talks |
| Blog | Weekly | New essays, posts |

---

## Known Projects (Inventory)

### Active / Recent

| Project | Released | Stars | Status | Description |
|---------|----------|-------|--------|-------------|
| **autoresearch** | 2026-03-06 | 26,300+ | 🔥 HOT | AI agents running autonomous ML experiments overnight |
| **nanochat** | 2026-02 | ~5,000 | Active | Minimal LLM training from scratch |
| **llm.c** | 2024-05 | 25,000+ | Active | LLM training in pure C/CUDA |
| **micrograd** | 2023 | 10,000+ | Stable | Autograd engine in 100 lines |
| **makemore** | 2022 | - | Stable | Character-level language models |
| **zero-to-hero** | 2022 | - | Complete | Neural networks YouTube series |

### Historical / Archived

| Project | Year | Description |
|---------|------|-------------|
| **char-rnn** | 2015 | Character-level RNN for text |
| **softmax** | - | Educational implementations |
| **ConvNetJS** | 2014 | Deep learning in browser |

---

## Priority Signals

When monitoring, flag these as **TIER 1**:

1. **New open source release** - Any new GitHub repo
2. **Architecture paper/essay** - Long-form technical content
3. **Educational content** - New courses, YouTube series
4. **"Vibe coding" mentions** - Coined term, track evolution
5. **AI agent tooling** - Heavily focused on agents now

---

## AUTORESEARCH Deep Dive

> Flagship project for 2026 - track closely

### What It Does
- 630-line Python script
- AI agents run ~100 ML experiments overnight on single GPU
- Autonomous loop: modify → train (5min) → evaluate → keep/discard
- Tracks `val_bpb` metric (lower = better)

### Architecture
```
prepare.py   — Data prep, tokenizer (agent never touches)
train.py     — Model, optimizer, loop (agent modifies this)
program.md   — Agent instructions (human writes this)
```

### Key Metrics (2026-03-11)
- GitHub stars: 26,300+
- Forks: 3,300+
- License: MIT
- One overnight run: 0.9979 → 0.9697 val_bpb (126 experiments)

### Karpathy's Vision
> "The goal is to engineer your agents to make the fastest research progress indefinitely and without any of your own involvement."
>
> Next step: "asynchronously massively collaborative for agents (think: SETI@home style)"

### Notable Forks
- [miolini/autoresearch-macos](https://github.com/miolini/autoresearch-macos)
- [trevin-creator/autoresearch-mlx](https://github.com/trevin-creator/autoresearch-mlx)
- [jsegov/autoresearch-win-rtx](https://github.com/jsegov/autoresearch-win-rtx)

---

## Recent Activity Log

### 2026-03-06 to 2026-03-11

| Date | Event | Significance |
|------|-------|--------------|
| 2026-03-11 | autoresearch commit c2450ad | Bug fixes, README improvements |
| 2026-03-10 | autoresearch commit ebf3578 | NaN fast-fail check |
| 2026-03-09 | Discussion #43 | Session report: 126 experiments, 3% improvement |
| 2026-03-06 | **autoresearch released** | 26K+ stars in 5 days |
| 2026-03-06 | X thread announcement | "automating scientific method with AI agents" |

---

## Monitoring Commands

### Manual Check (in Claude)
```
Check Karpathy's GitHub for new releases
```

### In Monitor Stage
The `run-monitor.sh` script includes `fetch_karpathy()` function.

### Raw Data Location
- Digest: `stages/00-monitor/output/discovery-YYYY-MM-DD-*.md`
- This tracker: `stages/00-monitor/references/karpathy-tracker.md`

---

## Related Topics in Knowledge Base

When Karpathy releases intersect with:
- **AI Agents** → Research immediately
- **LLM Training** → Research immediately
- **Educational Content** → Queue for review
- **Tooling/Frameworks** → Evaluate for ICM adoption

---

## Update Log

| Date | Update |
|------|--------|
| 2026-03-11 | Created tracker, documented autoresearch release |

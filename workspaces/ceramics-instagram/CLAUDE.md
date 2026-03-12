# Ceramics Instagram Workspace

Manage your Instagram ceramics account -- from weekly asset collection through content creation and repurposing.

## Folder Map

```
ceramics-instagram/
├── CLAUDE.md              (you are here)
├── CONTEXT.md             (task routing table)
├── setup/
│   └── questionnaire.md   (onboarding -- brand identity setup)
├── stages/
│   ├── 01-input/          (collect weekly assets)
│   ├── 02-planning/       (weekly content calendar)
│   ├── 03-content/        (captions, hashtags, CTAs)
│   └── 04-repurposing/    (stories + reels from posts)
├── brand-vault/           (persistent brand identity)
│   ├── identity.md        (who you are, aesthetic, goals)
│   ├── voice-rules.md     (how you sound -- auto-enhanced)
│   ├── performance-insights.md  (engagement dashboard)
│   ├── dm-sales-playbook.md     (DM automation & sales templates)
│   └── local-market-analysis.md (Long Beach competitors & opportunities)
├── shared/
│   └── hashtag-library.md (curated hashtag sets -- auto-optimized)
├── scripts/               (Instagram intelligence tools)
│   ├── extract-archive.py (full historical extraction)
│   ├── sync-weekly.py     (incremental updates)
│   ├── analyze-voice.py   (voice pattern extraction)
│   ├── analyze-hashtags.py (hashtag optimization)
│   ├── analyze-performance.py (generate insights)
│   └── lib/               (shared utilities)
└── data/
    ├── archive/           (extracted Instagram data)
    │   ├── cerafica_archive.json
    │   └── cerafica_media/
    └── sync/              (sync timestamps)
```

## Triggers

| Keyword | Action |
|---------|--------|
| `setup` | Run onboarding -- configure brand identity and voice |
| `status` | Show pipeline completion for all four stages |

### How `status` works

Scan `stages/*/output/` folders. For each stage, if the output folder contains files (other than .gitkeep), the stage is COMPLETE. Otherwise PENDING. Render:

```
Pipeline Status: ceramics-instagram

  [01-input]  -->  [02-planning]  -->  [03-content]  -->  [04-repurposing]
     STATUS          STATUS              STATUS              STATUS
```

## Routing

| Task | Go To |
|------|-------|
| Set up brand identity | `setup/questionnaire.md` |
| Collect this week's assets | `stages/01-input/CONTEXT.md` |
| Plan weekly content | `stages/02-planning/CONTEXT.md` |
| Write captions | `stages/03-content/CONTEXT.md` |
| Create stories/reels | `stages/04-repurposing/CONTEXT.md` |
| Review brand identity | `brand-vault/identity.md` |
| Check voice guidelines | `brand-vault/voice-rules.md` |
| See performance insights | `brand-vault/performance-insights.md` |
| Set up DM sales automation | `brand-vault/dm-sales-playbook.md` |
| Research local market/competitors | `brand-vault/local-market-analysis.md` |
| Extract Instagram archive | `scripts/extract-archive.py` |
| Sync weekly posts | `scripts/sync-weekly.py` |
| Analyze voice patterns | `scripts/analyze-voice.py` |
| Optimize hashtags | `scripts/analyze-hashtags.py` |
| Generate insights | `scripts/analyze-performance.py` |

## Weekly Workflow

1. **Monday/Tuesday**: Run `01-input` to gather new photos/videos
2. **Tuesday**: Run `02-planning` to create content calendar
3. **Wednesday**: Run `03-content` to write all captions
4. **Thursday**: Run `04-repurposing` for stories/reels ideas
5. **Post throughout week** using your completed content pack

## Goals

This workspace supports:
1. **Sell existing inventory** -- DM-based sales with clear CTAs
2. **Build audience authentically** -- artist voice, behind-the-scenes
3. **Future commissions** -- establish presence for later commission work

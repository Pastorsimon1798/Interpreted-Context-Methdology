# [Workspace Name]

[One sentence: what this workspace does.]

## Folder Map

```
[workspace-name]/
├── CLAUDE.md          (you are here)
├── CONTEXT.md         (start here for task routing)
├── setup/             (onboarding questionnaire)
├── skills/            (bundled Claude skills for domain knowledge)
├── [context-folder]/  (shared context files)
├── stages/
│   ├── 01-[name]/     ([brief description])
│   ├── 02-[name]/     ([brief description])
│   └── 03-[name]/     ([brief description])
└── shared/            (cross-stage reference files)
```

## Triggers

| Keyword | Action |
|---------|--------|
| `setup` | Run onboarding questionnaire |
| `status` | Show pipeline completion for all stages |

## Routing

| Task | Go To |
|------|-------|
| [Task type 1] | `stages/01-[name]/CONTEXT.md` |
| [Task type 2] | `stages/02-[name]/CONTEXT.md` |
| [Task type 3] | `stages/03-[name]/CONTEXT.md` |

## What to Load

<!-- Map each task to its minimal file set. Loading more files dilutes quality.
     The context window is working memory, not storage. -->

| Task | Load These | Do NOT Load |
|------|-----------|-------------|
| [Task 1] | [minimal file list] | [what to skip and why] |
| [Task 2] | [minimal file list] | [what to skip and why] |

## Stage Handoffs

Each stage writes its output to its own `output/` folder. The next stage reads from there. If you edit an output file, the next stage picks up your edits.

## Ownership Protocol

> **Own the whole system. No artificial boundaries.**

- **All bugs are your responsibility** - No issue is "separate" or "out of scope" without approval
- **Verify before assuming** - Never say "this existed before" without checking
- **Fix before declaring done** - A bug found during testing MUST be fixed before claiming completion
- **Test end-to-end** - "Done" means the system works, not just that code was written

**Red Flags (self-catch):**
- "That's a separate issue" → NO IT ISN'T
- "This existed before my changes" → DID YOU VERIFY?
- "Out of scope" → WHOSE SCOPE? MINE.
- "Someone else's problem" → WHO? NO ONE? THEN MINE.

## Direct Action Rule

Before building any script/abstraction:

1. Do the task directly once
2. If repeating, ask: "Is this actually repetitive or imagined?"
3. Only abstract after **3+ real repetitions observed**
4. Default: Just do the work

## Git Setup

Each workspace is an independent git repository. After creating a new workspace:

```bash
cd workspaces/[workspace-name]
git init
git add .
git commit -m "Initialize [workspace-name] workspace"
```

This gives each workspace its own commit history, separate from the root ICM repo. See `_core/CONVENTIONS.md` Pattern 17 for full architecture details.

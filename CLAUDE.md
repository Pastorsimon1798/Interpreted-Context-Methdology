

<!-- EMPOWER_ORCHESTRATOR:START -->
Factory automation is allowed only when the operator can still understand and recover from what is about to happen.
Before dispatching automation or creating a durable system change, state the four-question blast-radius check:

1. **Scale** — how many repositories, files, jobs, runners, users, or environments can this touch?
2. **Severity** — what is the worst plausible breakage if this is wrong?
3. **Reversibility** — how quickly can the operator roll it back or stop it?
4. **Predictability** — is the system deterministic enough to trust unattended execution?

If any answer is unclear, narrow the action, add a dry run, or require explicit operator confirmation before continuing.
<!-- EMPOWER_ORCHESTRATOR:END -->

# Model Workspace Protocol

MWP is a framework for building structured, multi-stage AI workflows out of markdown files and folder conventions. Each workspace gives AI agents the right context at each stage of a task, and gives humans clear edit surfaces between stages.

## Folder Map

```
model-workspace-protocol/
├── CLAUDE.md                          (you are here)
├── README.md                          (project overview)
├── LICENSE
├── _core/                             (shared conventions and templates)
│   ├── CONVENTIONS.md                 (source of truth for all patterns)
│   ├── placeholder-syntax.md          (how {{VARIABLES}} work)
│   └── templates/                     (blank starting points for new workspaces)
└── workspaces/
    ├── script-to-animation/           (content idea -> animated video)
    ├── course-deck-production/        (unstructured material -> course PowerPoints)
    └── workspace-builder/             (builds new MWP workspaces)
```

## Token-Efficient Navigation (jDocMunch/jCodeMunch)

**ICM is indexed. Use these tools to save 80-99% tokens.**

| Task | Tool | Repo ID |
|------|------|---------|
| Find markdown section | `search_sections` | `local/Interpreted-Context-Methdology` |
| Find code symbol | `search_symbols` | `local/Interpreted-Context-Methdology-d323f6ef` |

```
# Example: Find routing info
search_sections(repo="local/Interpreted-Context-Methdology", query="routing")
→ get_section(section_id="...")
```

**NEVER read entire .md files when jDocMunch can retrieve specific sections.**

See `shared/skills/doc-analysis/SKILL.md` and `shared/skills/code-analysis/SKILL.md` for full documentation.

## Routing

| You want to... | Go to |
|-----------------|-------|
| Create content with script-to-animation | `workspaces/script-to-animation/CLAUDE.md` |
| Build course slide decks from source material | `workspaces/course-deck-production/CLAUDE.md` |
| Build a new workspace for any domain | `workspaces/workspace-builder/CLAUDE.md` |
| Analyze codebases efficiently | `shared/skills/code-analysis/SKILL.md` |
| Navigate documentation by section | `shared/skills/doc-analysis/SKILL.md` |
| Read the full MWP specification | `_core/CONVENTIONS.md` |
| Understand the placeholder system | `_core/placeholder-syntax.md` |
| Use a template for a new workspace | `_core/templates/` |

## Triggers

| Keyword | Action |
|---------|--------|
| `setup` | Run onboarding in whatever workspace you are in |
| `status` | Show pipeline completion for the current workspace |

## How It Works

Each workspace is self-contained with its own CLAUDE.md. Navigate into a workspace folder and that workspace's CLAUDE.md takes over. You do not need to read this root file once you are inside a workspace.
# Stage 03: Scaffolding

Generate the complete workspace folder structure, CONTEXT.md files, and placeholder reference files.

## Inputs

| Source | File/Location | Section/Scope | Why |
|--------|--------------|---------------|-----|
| Previous stage | `../02-mapping/output/stage-contracts.md` | Full file | The contracts to implement as folders and files |
| Discovery output | `../01-discovery/output/workflow-map.md` | "Tool Prerequisites" and "Selected Skills" sections | Tools that need setup guides, skills to bundle |
| Template | `/_core/templates/stage-context-template.md` | Full file | Template for stage CONTEXT.md files (includes Verifiability, Checkpoints, and Audit sections) |
| Template | `/_core/templates/workspace-claude-template.md` | Full file | Template for the workspace CLAUDE.md (includes What to Load section) |
| Template | `/_core/templates/workspace-context-template.md` | Full file | Template for the workspace CONTEXT.md |
| Template | `/_core/templates/progress-template.md` | Full file | Template for PROGRESS.md session continuity file |
| Template | `/_core/templates/quality-gates-template.md` | Full file | Template for inter-stage verification checkpoints |
| Syntax | `/_core/placeholder-syntax.md` | Full file | How to write placeholder variables |

## Process

1. Read the stage contracts from mapping output
2. Create the workspace folder structure:
   - Root: CLAUDE.md, CONTEXT.md, setup/
   - Context folder (brand-vault or domain equivalent) with its own CONTEXT.md
   - stages/ with one numbered subfolder per stage, each containing CONTEXT.md, output/, and references/
   - shared/ for cross-stage reference files
   - skills/ if any skills were selected during discovery
3. Populate each stage CONTEXT.md using the template, filled with the contract's inputs, process, and outputs. For each stage, determine:
   - **Verifiability:** Classify as MACHINE-VERIFIABLE, EXPERT-VERIFIABLE, or JUDGMENT-REQUIRED. Fill in the verification method and human review trigger.
   - **Checkpoints:** Does this stage benefit from human steering between steps? Creative stages (writing, design, ideation) should have at least one checkpoint. Linear stages (extract, render, validate) can skip the section.
   - **Audit:** Does this stage need quality checks before output is written? Creative and build stages should have an audit table with specific pass conditions. Data extraction or file conversion stages can skip the section.
   - Delete the Checkpoints or Audit sections from the template if the stage does not need them.
4. Create the workspace CLAUDE.md using the template: folder map, triggers, routing table, and What to Load section mapping each task to its minimal file set. Add the `resume` trigger keyword.
5. Create the workspace CONTEXT.md using the template: task routing table, shared resources
6. Create PROGRESS.md at workspace root using the template: session continuity file for resuming work across conversations
7. Create QUALITY-GATES.md at workspace root using the template: customize gate definitions for each stage transition based on the stage contracts
8. Create placeholder reference files for each stage with `{{PLACEHOLDER}}` variables for user-specific content
9. For content-producing workspaces, create a value framework reference file (see Pattern 13)
10. For code-producing workspaces, create a shared constants file or pattern (see Pattern 15)
11. Create the context folder (brand-vault equivalent) with placeholder files. If the workspace produces voice/style content, structure voice rules with Hard Constraints, Sentence Rules, and Pacing sections (not a single description placeholder)
12. If skills were selected during discovery, create a skills/ folder:
    - For local skills (found in `~/.claude/skills/` or `~/.agents/skills/`): copy the entire skill folder into `skills/[skill-name]/`
    - For GitHub skills: clone the repo and copy the skill folder in, or note the clone command in a setup guide
    - Remove any custom reference files that the skill replaces (avoid duplication)
    - Update stage CONTEXT.md Inputs tables to reference `../../skills/[name]/SKILL.md` instead of deleted reference files
13. If tools were identified that require system-level installation (Node.js, Python, LibreOffice), write a setup guide in the relevant stage's `references/` folder. Tools bundled inside skills do not need separate setup guides.
14. Add .gitkeep files in all output/ directories
15. Run the audit checks below. If any fail, fix before saving.
16. Write everything to output/

## Audit

| Check | Pass Condition |
|-------|---------------|
| Folder structure | Every stage has CONTEXT.md, output/, and references/ |
| Contract fidelity | Every stage CONTEXT.md matches the contracts from Stage 02 |
| PROGRESS.md exists | Workspace root contains PROGRESS.md with template structure |
| QUALITY-GATES.md exists | Workspace root contains QUALITY-GATES.md with customized gates |
| Resume trigger | CLAUDE.md triggers table includes `resume` keyword |
| Verifiability section | Each stage CONTEXT.md has Verifiability classification filled |
| Placeholder syntax | All placeholders use `{{SCREAMING_SNAKE_CASE}}` format |
| .gitkeep coverage | Every output/ directory contains a .gitkeep file |
| CONTEXT.md size | No CONTEXT.md file exceeds 80 lines |
| Naming conventions | All folders and files use lowercase-with-hyphens |

## Outputs

| Artifact | Location | Format |
|----------|----------|--------|
| Generated workspace | `output/` | Complete folder structure with all files. Ready for questionnaire design. |

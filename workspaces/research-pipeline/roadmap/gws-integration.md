# Plan: Research-Pipeline GWS Integration

## Context

The research-pipeline workspace is complete and functional. Future expansion should integrate it with the google-workspace-agent to automatically publish research outputs to the PARA knowledge base in Google Drive (Docs/Sheets).

**Why defer:** The GWS agent's PARA structure and database are still being built. Things may change, so integration should wait until the structure stabilizes.

---

## Dependencies (Blockers)

Before implementing, wait for:
- [x] GWS agent's `shared/para-structure.md` to be finalized
- [x] GWS agent's `shared/drive-structure.md` to be finalized
- [ ] `@googleworkspace/cli` setup confirmed working
- [ ] Knowledge base path confirmed (`~/knowledge-base` or alternative)

---

## Integration Design

### New Stage: 06-publish

Add a new stage after 05-output that handles publishing to the PARA knowledge base.

```
research-pipeline/
├── stages/
│   ├── ...
│   ├── 05-output/         (generates local deliverable)
│   └── 06-publish/        (NEW: pushes to GWS knowledge base)
│       ├── CONTEXT.md
│       ├── output/
│       └── references/
│           └── para-mapping.md
```

### Stage 06 Contract

| Aspect | Value |
|--------|-------|
| **Input** | 05-output/output/ (report.md, dataset.json, or docs/) |
| **Process** | 1. Read output from stage 05<br>2. Determine PARA category (Resources/Research/)<br>3. Create Google Doc or Sheet via gws CLI<br>4. Link to PARA index |
| **Output** | publish-log.md (Google Drive URLs) |

### PARA Destination Mapping

| Research Output Type | PARA Location | Google Format |
|---------------------|---------------|---------------|
| Report | Resources/Research/{topic}/ | Google Doc |
| Dataset | Resources/Research/{topic}/data/ | Google Sheet |
| Documentation | Resources/Reference/{topic}/ | Google Doc |

---

## Files to Create

1. **`stages/06-publish/CONTEXT.md`** - Stage contract
2. **`stages/06-publish/references/para-mapping.md`** - Maps output types to PARA folders
3. **`skills/gws-publish/SKILL.md`** - Skill for Google Workspace publishing
4. **Update `CLAUDE.md`** - Add routing entry for publish stage
5. **Update `CONTEXT.md`** - Add task routing for publish
6. **Update `brand-vault.md`** - Add `{{AUTO_PUBLISH}}` preference

---

## Execution Steps (When Ready)

1. **Verify GWS agent stability**
   - Read `workspaces/google-workspace-agent/shared/para-structure.md`
   - Read `workspaces/google-workspace-agent/shared/drive-structure.md`
   - Confirm paths and structure are stable

2. **Create 06-publish stage**
   - Create folder structure
   - Write CONTEXT.md with Inputs/Process/Outputs
   - Create para-mapping.md reference

3. **Bundle gws-publish skill**
   - Copy or create skill for `@googleworkspace/cli` operations
   - Include doc creation, sheet creation, folder navigation

4. **Update workspace routing**
   - Add 06-publish to CLAUDE.md folder map
   - Add task routing entry
   - Add to "What to Load" table

5. **Add onboarding question**
   - Q: "Auto-publish research to Google Drive?"
   - Placeholder: `{{AUTO_PUBLISH}}`
   - Conditional: If "no", remove 06-publish stage

6. **Validate**
   - Run workspace-builder stage 05 validation
   - Test with sample research output

---

## Skill Requirements

The bundled `skills/gws-publish/SKILL.md` should cover:

```
## gws-publish Skill

### When to Use
- Publishing research output to Google Drive
- Creating Google Docs from markdown
- Creating Google Sheets from JSON/CSV

### Prerequisites
- Node.js 18+
- @googleworkspace/cli installed and authenticated
- Google Cloud project with Drive API enabled

### Commands
- `gws docs create --title "..." --content "..."` - Create Doc
- `gws sheets create --title "..."` - Create Sheet
- `gws drive upload --file "..." --folder "..."` - Upload file

### Error Handling
- Rate limits: exponential backoff
- Auth errors: re-run `gws auth login`
- Folder not found: create or use root
```

---

## Verification

After implementation, test by:
1. Running a complete research pipeline (01-05)
2. Confirming 06-publish picks up the output
3. Verifying Google Doc/Sheet appears in correct PARA folder
4. Checking publish-log.md contains valid Drive URLs

---

## Storage Location

This plan will be saved to:
```
workspaces/research-pipeline/roadmap/gws-integration.md
```

The agent can read this file and implement when dependencies are met.

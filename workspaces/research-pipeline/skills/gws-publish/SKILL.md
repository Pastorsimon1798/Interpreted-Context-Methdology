# gws-publish

Publish research outputs to Google Drive knowledge base via kb-create.sh.

## When to Use

- Publishing research output to Google Drive
- Creating Google Docs from markdown
- Uploading research reports to PARA folders

## Prerequisites

- `gws` CLI installed and authenticated
- `kb-create.sh` script available at `google-workspace-agent/scripts/`
- OAuth credentials configured for Google Drive

### Setup

```bash
# Navigate to google-workspace-agent
cd /path/to/Interpreted-Context-Methdology/workspaces/google-workspace-agent

# Verify gws CLI is available
gws --version

# Verify kb-create.sh works
./scripts/kb-create.sh resource "Test Doc" "Test content"
```

## Folder IDs Reference

From `google-workspace-agent/shared/drive-ids.sh`:

| PARA Category | Variable | Description |
|---------------|----------|-------------|
| Resources | `RESOURCES_ID` | Research outputs typically go here |
| Projects | `PROJECTS_ID` | Active project documents |
| Areas | `AREAS_ID` | Ongoing responsibility documents |
| Archive | `ARCHIVE_ID` | Completed research |

## Commands

### Create Document in PARA Folder

```bash
cd /path/to/Interpreted-Context-Methdology/workspaces/google-workspace-agent

# Create in Resources folder (typical for research)
./scripts/kb-create.sh resource "<title>" "<content>"

# Create in Projects folder
./scripts/kb-create.sh project "<title>" "<content>"

# Create in Areas folder
./scripts/kb-create.sh area "<title>" "<content>"

# Create in Archive folder
./scripts/kb-create.sh archive "<title>" "<content>"
```

### Create with File Content

```bash
# Read content from file
CONTENT=$(cat /path/to/report.md)
./scripts/kb-create.sh resource "Research Report - $(date +%Y-%m-%d)" "$CONTENT"
```

## Workflow

### Publishing a Research Report

```bash
# 1. Navigate to google-workspace-agent
cd /Users/simongonzalezdecruz/Desktop/Interpreted-Context-Methdology/workspaces/google-workspace-agent

# 2. Read the output file
REPORT_CONTENT=$(cat ../research-pipeline/stages/05-output/output/report.md)

# 3. Create the document in Resources folder
./scripts/kb-create.sh resource "AI Agents - Research Report (2026-03-11)" "$REPORT_CONTENT"
```

### Publishing from Research Pipeline

When called from 06-publish stage:

```bash
# Path from research-pipeline stages/06-publish/
GWS_ROOT="../../google-workspace-agent"
KB_CREATE="$GWS_ROOT/scripts/kb-create.sh"

# Read the research output
REPORT=$(cat ../05-output/output/report.md)

# Publish to Resources/Research subfolder
$KB_CREATE resource "Research: [Topic] - $(date +%Y-%m-%d)" "$REPORT"
```

## Output Format

After successful publish, the script outputs:

```
Creating document: [Title]
Category: resource
KB ID: KB-20260311-143022-ResearchTopicResea
Adding content to document...
Adding to Master Index...

=== Document Created ===
URL: https://docs.google.com/document/d/[DRIVE_ID]/edit
KB ID: KB-20260311-143022-ResearchTopicResea
Drive ID: [DRIVE_ID]
```

Record this in `output/publish-log.md`:

```markdown
# Publish Log

## 2026-03-11

### Report: AI Agents Research
- **Google Doc:** https://docs.google.com/document/d/ABC123
- **KB ID:** KB-20260311-143022-AIAgentsResearch
- **Category:** resource
- **Local source:** ../05-output/output/report.md
```

## Error Handling

| Error | Cause | Resolution |
|-------|-------|------------|
| `command not found: gws` | CLI not installed | Install `@googleworkspace/cli` |
| `401 Unauthorized` | Token expired | Run `gws auth login` |
| `403 Rate Limit` | Too many requests | Wait and retry |
| `FOLDER_ID not set` | drive-ids.sh not sourced | Script sources it automatically |

## Notes

- Documents are created as Google Docs (not uploaded files)
- Content is added via `gws docs +write` after creation
- All documents are automatically indexed in the Master Index spreadsheet
- The KB ID is auto-generated from timestamp and title
- Research reports typically go in `resource` category

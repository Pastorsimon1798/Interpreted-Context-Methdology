# Knowledge Extraction

Extract valuable information from newsletters and reference emails for the knowledge base.

## Inputs

| Source | File/Location | Section/Scope | Why |
|--------|--------------|---------------|-----|
| Stage 01 | `../01-triage/output/triage-report.md` | "Valuable Content" section | Flagged emails for extraction |
| Shared | `shared/extraction-rules.md` | Full file | What counts as valuable info |
| Shared | `shared/para-structure.md` | Full file | PARA folder definitions |
| Config | `shared/drive-ids.sh` | - | Google Drive folder IDs |
| Config | Google Drive | Knowledge Base folder | Native Drive storage |
| Skills | gws-drive, gws-keep, recipe-save-email-attachments, persona-researcher | - | Processing capabilities |
| Security | `../../shared/security/CONTEXT.md` | Full file | Sanitization rules |
| Skill | `../../skills/security-input-sanitization/SKILL.md` | Full file | Injection protection |

## Task Integration

Action items extracted during this stage can be synced to Google Tasks:

```bash
# Sync action items from triage to Tasks
./scripts/run-tasks.sh sync

# Create task from specific email
./scripts/run-tasks.sh from-email <message_id>

# Or use the workflow helper
./shared/gws-workflows.sh email-to-task <message_id>
```

## Process

1. Read flagged emails from triage report
2. Extract attachments using recipe-save-email-attachments
3. **[Security]** Sanitize content before saving to knowledge base
4. Extract valuable information per extraction-rules.md
5. Classify each extraction into PARA category
6. Create Google Doc using `scripts/kb-create.sh` in appropriate PARA folder
7. Capture fleeting notes to Google Keep
8. Link each extraction back to source email (message ID)
9. Apply Gmail label (KB/Projects, KB/Areas, KB/Resources, KB/Archive) to source email
10. [Checkpoint] If supervised = true, pause for user review
11. Sync action items to Google Tasks

## Checkpoints

| After Step | Agent Presents | Human Decides |
|------------|---------------|---------------|
| 8 | extraction-log.md with PARA classifications and file locations | Approve extractions and categorizations before proceeding |

## Audit

| Check | Pass Condition |
|-------|---------------|
| All extractions linked | Each extraction references source email message ID |
| PARA category assigned | Every extracted file has a PARA category |
| No duplication | No duplicate content across extractions |
| Content sanitized | All extracted content passed security validation |

## Outputs

| Artifact | Location | Format |
|----------|----------|--------|
| PARA Docs | Google Drive `{00-Inbox,01-Projects,02-Areas,03-Resources,04-Archive}` | Google Docs |
| Attachments | Google Drive `_System/attachments/` | Uploaded files |
| Master Index | Google Sheets `Master Index` | Central registry of all KB items |
| Extraction Log | `output/extraction-log.md` | List of created files with source email IDs |
| Tasks | Google Tasks | Action items synced from triage |

## Drive Integration

Use `scripts/kb-create.sh` to create new knowledge base documents:

```bash
./scripts/kb-create.sh <category> <title> [content]
# Categories: inbox, project, area, resource, archive
```

This creates:
1. A Google Doc in the appropriate PARA folder
2. An entry in the Master Index spreadsheet
3. Returns the Doc URL and KB ID

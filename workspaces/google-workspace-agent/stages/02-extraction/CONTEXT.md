# Knowledge Extraction

Extract valuable information from newsletters and reference emails for the knowledge base.

## Key Principle

> **The AI does the extraction. Scripts just save the files.**

## Inputs

| Source | How to Access | Why |
|--------|--------------|-----|
| Stage 01 | `../01-triage/output/triage-report.md` | Flagged emails for extraction |
| Gmail API | `gws gmail users messages get --params '{"userId":"me","id":"ID"}'` | Full email content |
| Shared | `shared/extraction-rules.md` | What counts as valuable info |
| Shared | `shared/para-structure.md` | PARA folder definitions |

## GWS Commands for AI

```bash
# Get full email content
gws gmail users messages get --params '{"userId":"me","id":"MESSAGE_ID"}' --format json

# Upload to Drive (AI decides PARA category)
gws drive +upload --file "./extracted.md" --name "Newsletter Summary"

# Create Google Doc
gws drive files create --json '{"name":"Title","mimeType":"application/vnd.google-apps.document","parents":["FOLDER_ID"]}'
```

## Process

1. **Read triage report** - Identify emails flagged for extraction
2. **Fetch full email** - Call `gws gmail users messages get`
3. **AI extracts content** - Use `shared/extraction-rules.md` to identify valuable info
4. **AI classifies to PARA** - Projects, Areas, Resources, or Archive
5. **AI saves to Drive** - Call `gws drive +upload` or create doc
6. **Generate log** - Write `output/extraction-log.md`

## AI Extraction Logic

The AI uses its intelligence to extract. Example patterns:

- **Links**: URLs with context, resources, references
- **Key insights**: Summaries, takeaways, lessons
- **Deadlines**: Dates, due dates, reminders
- **Contacts**: People, organizations, roles
- **Action items**: Tasks, to-dos, follow-ups

## PARA Classification

The AI decides where to save based on content:

| Category | Folder | Use For |
|----------|--------|---------|
| Projects | `01-Projects/` | Active work with deadline |
| Areas | `02-Areas/` | Ongoing responsibilities |
| Resources | `03-Resources/` | Reference material |
| Archive | `04-Archive/` | Completed/inactive items |

## Drive Helper

```bash
# Upload file (AI provides content)
./scripts/kb-create.sh <category> <title> [content]

# Or use GWS directly
gws drive +upload --file "./content.md" --name "Newsletter - 2026-03-12"
```

## Outputs

| Artifact | Location | Format |
|----------|----------|--------|
| PARA Docs | Google Drive | Google Docs in PARA folders |
| Extraction Log | `output/extraction-log.md` | List of extractions with source email IDs |

## Verifiability

**Classification:** `MACHINE-VERIFIABLE`

**Verification Method:** Extractions can be counted, PARA categories can be validated, source links can be verified.

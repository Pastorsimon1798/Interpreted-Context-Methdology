# Stage 06: Publish

Push research outputs to local knowledge base and Google Drive.

## Inputs

| Source | File/Location | Section/Scope | Why |
|--------|--------------|---------------|-----|
| Previous stage | `../05-output/output/` | All files | Content to publish |
| Brand vault | `../../brand-vault.md` | Publishing section | Preferences |
| Reference | `references/para-mapping.md` | Full file | Destination mapping |
| GWS reference | `../../../google-workspace-agent/shared/drive-ids.sh` | Folder IDs | PARA folder IDs |
| GWS script | `../../../google-workspace-agent/scripts/kb-create.sh` | Full file | Document creation |

## Process

### Step 1: Local KB Save

Save markdown report to local knowledge base for GWS agent pickup:

```bash
# Create research directory if needed
mkdir -p ~/knowledge-base/resources/research/

# Copy report to KB
cp stages/05-output/output/report-*.md ~/knowledge-base/resources/research/

# GWS agent will sync to Drive on next run
```

### Step 2: Email with PDF Attachment (if `research email`)

When triggered with `research email [topic]`:

```bash
# Send email with PDF attachment
gws email send \
  --to "user@example.com" \
  --subject "Research Report: [Topic] - $(date +%Y-%m-%d)" \
  --body "$(cat stages/05-output/output/executive-summary.txt)" \
  --attachment "stages/05-output/output/report-*.pdf" \
  --label "AI-Research-Report"
```

**Email format:**
- **Body:** Executive summary + "Full report attached as PDF"
- **Attachment:** `report-YYYY-MM-DD-topic.pdf`
- **Label:** `AI-Research-Report` (distinct from `AI-Digest`)

### Step 3: Google Drive Publish (if AUTO_PUBLISH enabled)

1. Read output files from 05-output/output/
2. Determine PARA category (typically `resource` for research)
3. Read content from output file
4. Run kb-create.sh to create Google Doc:
   ```bash
   cd ../../../google-workspace-agent
   ./scripts/kb-create.sh resource "Report Title - $(date +%Y-%m-%d)" "$(cat ../research-pipeline/stages/05-output/output/report.md)"
   ```
5. Record published URL and KB ID in publish-log.md

## Verifiability

**Classification:** `MACHINE-VERIFIABLE`

**Verification Method:** File copied to KB, PDF generated, email sent or Drive URL returned - all can be verified programmatically.

**Human Review Trigger:** Confirm before external publishing (email or Drive) to prevent accidental publication.

## Checkpoints

| After Step | Agent Presents | Human Decides |
|------------|---------------|---------------|
| Step 1 (Local KB save) | Report copied to ~/knowledge-base/ | Confirm before external publishing |
| Step 3 (Drive publish) | Google Drive URL for published doc | Approve before finalizing |

## Audit

| Check | Pass Condition |
|-------|---------------|
| Output exists | Files found in 05-output/output/ |
| Local KB saved | Report copied to ~/knowledge-base/resources/research/ |
| PDF exists | PDF file present for email attachments |
| Script available | kb-create.sh exists and is executable |
| GWS CLI available | `gws` command responds |
| Auth valid | No authentication errors |
| Publish success | Google Drive URL returned |

## Outputs

| Artifact | Location | Format |
|----------|----------|--------|
| Publish log | `output/publish-log.md` | URLs, KB IDs, metadata |
| Local KB copy | `~/knowledge-base/resources/research/` | Markdown files |
| (Side effect) | Google Drive | Google Doc in PARA folder |
| (Side effect) | Master Index | Entry in KB spreadsheet |
| (Side effect) | Email inbox | PDF attachment with AI-Research-Report label |

## Conditional Execution

- **Local KB save:** Always runs
- **Email with PDF:** Only when triggered via `research email [topic]`
- **Google Drive publish:** Only if `AUTO_PUBLISH` is set to "yes" in brand-vault.md

## Email Labels

| Label | Purpose |
|-------|---------|
| `AI-Digest` | Monitor digest emails |
| `AI-Research-Report` | Full research reports with PDF attachments |

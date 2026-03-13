# Stage 05: Output

Format synthesized knowledge into final deliverable with proper file outputs.

## Documentation Navigation

When reading ICM's own documentation, use jDocMunch instead of Read:

```
search_sections(repo="local/Interpreted-Context-Methdology", query="...")
get_section(section_id="...")
```

**Never read entire CLAUDE.md or CONTEXT.md files - retrieve only needed sections.**

## Inputs

| Source | File/Location | Section/Scope | Why |
|--------|--------------|---------------|-----|
| Previous stage | `../04-synthesis/output/knowledge-synthesized.md` | Full file | Content to format |
| Previous stage | `../02-discovery/output/sources-collected.md` | Credibility scores | Source quality data |
| Brand vault | `../../brand-vault.md` | Research Style, Output Defaults | Format preferences |
| Reference | `references/output-templates/` | Template based on format | Structure |
| Security | `../../shared/security/CONTEXT.md` | Full file | Sanitization rules |
| Skill | `../../skills/security-input-sanitization/SKILL.md` | Full file | Injection protection |

## Output File Naming Convention

All outputs follow strict naming for consistency and sorting:
```
output/
├── report-YYYY-MM-DD-{topic-slug}.md    # Full markdown report
├── report-YYYY-MM-DD-{topic-slug}.pdf   # PDF version for attachments
└── sources-YYYY-MM-DD-{topic-slug}.json # Machine-readable source data
```

Example: `report-2026-03-11-ai-agents.md`

**Topic slug rules:**
- Lowercase, hyphens for spaces
- Max 30 characters
- Alphanumeric only

## Process

1. Read synthesized knowledge document
2. Read source credibility data from discovery stage
3. Determine output format (report, dataset, or documentation)
4. Generate topic slug from research goal
5. Load appropriate template from references/output-templates/
6. **[Security]** Sanitize any source excerpts before inclusion in report
7. Apply citation style from brand vault
8. Format content according to template structure
9. Add metadata (date, methodology summary, source count, avg credibility)
10. Write markdown file with proper naming: `report-{date}-{slug}.md`
11. Generate PDF via pandoc (see PDF Generation section)
12. Run audit checks, revise if needed

## Verifiability

**Classification:** `EXPERT-VERIFIABLE`

**Verification Method:** Report format can be validated, but quality of writing and appropriateness of structure require human judgment.

**Human Review Trigger:** Always. Present formatted report for approval before PDF generation.

## Checkpoints

| After Step | Agent Presents | Human Decides |
|------------|---------------|---------------|
| 9 (Write markdown) | report-YYYY-MM-DD-slug.md formatted content | Approve before PDF generation |
| 10 (Generate PDF) | PDF file ready for distribution | Confirm before publishing |

## PDF Generation

After markdown is written, generate PDF:

```bash
# Install pandoc if needed
brew install pandoc

# Generate PDF from markdown
cd stages/05-output/output
pandoc "report-YYYY-MM-DD-{topic-slug}.md" \
  -o "report-YYYY-MM-DD-{topic-slug}.pdf" \
  --pdf-engine=weasyprint \
  --metadata title="Research Report: {Topic}"
```

**Requirements:**
- pandoc installed
- weasyprint (or use wkhtmltopdf as fallback)

## Audit

| Check | Pass Condition |
|-------|---------------|
| Format compliance | Output matches template structure |
| Citation accuracy | All citations properly formatted |
| Completeness | All synthesis sections represented |
| Readability | Document is well-structured |
| Metadata present | Date, sources, methodology documented |
| File naming | Follows report-YYYY-MM-DD-slug.md format |
| PDF exists | Corresponding .pdf file generated |
| Content sanitized | All source excerpts passed security validation |

## Outputs

| Artifact | Location | Format |
|----------|----------|--------|
| Markdown report | `output/report-YYYY-MM-DD-{slug}.md` | Full markdown |
| PDF report | `output/report-YYYY-MM-DD-{slug}.pdf` | PDF for attachments |
| Source data | `output/sources-YYYY-MM-DD-{slug}.json` | Machine-readable citations |

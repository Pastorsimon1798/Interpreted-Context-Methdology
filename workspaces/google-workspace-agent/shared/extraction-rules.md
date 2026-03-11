# Extraction Rules

> Identifying valuable information for knowledge base extraction.

## Topics of Interest

- AI and machine learning
- Coding and software development
- Productivity tools and techniques
- Neurodiversity tools (ADHD, autism, etc.)
- Entrepreneurship and business tools
- Knowledge management systems
- Personal development

---

## Content Types to Extract

### Standard Extraction Types

| Type | Detection Pattern | Storage Location |
|------|-------------------|------------------|
| Links | URLs in body | Resources/Links |
| Quotes | Forwarded text, citations | Resources/Quotes |
| How-Tos | Step-by-step instructions | Resources/Guides |
| Announcements | "Announcing", "New", "Update" | Resources/News |
| Deadlines | Date + task mentions | Calendar/Tasks |
| Contacts | Signature blocks, intros | Resources/Contacts |
| Metrics | Numbers, statistics | Projects/ relevant folder |
| Action Items | "TODO", "Please", tasks | Tasks/Inbox |

---

## Value Threshold

### Minimum Value Criteria

- Information I'll reference more than once
- Content that saves research time
- Items related to active interests (AI, productivity, neurodiversity, entrepreneurship)
- Anything that could help improve knowledge management

### Exclusion Rules

Do NOT extract:
- Temporary promotional codes
- One-time access links
- Personal correspondence without reference value
- Duplicate information
- **Rent-A-Center** - incorrect email (sent by mistake, not intended for this user)
- **AI-Digest label** - research pipeline digests (transient, not for KB)

---

## Extraction Quality Checklist

Before extracting, verify:

- [ ] Relevance: Related to topics of interest
- [ ] Uniqueness: Not already captured
- [ ] Longevity: Useful beyond today
- [ ] Actionability: Can be used or referenced
- [ ] Clarity: Understandable without context

---

## Destination Mapping

### PARA Folder Routing

```
IF related to active work -> Projects/{project-name}/
IF related to life areas -> Areas/{area-name}/
IF general reference -> Resources/{topic}/
IF no current relevance -> Archive/
```

### Specific Destinations

```
- "AI news" -> Resources/AI-Tools/
- "Productivity tips" -> Resources/Productivity/
- "Neurodiversity content" -> Resources/Neurodiversity/
- "Entrepreneurship" -> Resources/Entrepreneurship/
- "Team updates" -> Areas/Career/
```

---

## Extraction Format

### Standard Extracted Item

```markdown
## {{ITEM_TITLE}}

**Source:** {{SOURCE_EMAIL_SUBJECT}}
**From:** {{SENDER}}
**Date:** {{EXTRACTION_DATE}}
**Category:** {{CONTENT_TYPE}}

{{EXTRACTED_CONTENT}}

**Tags:** {{AUTO_GENERATED_TAGS}}
**Related to:** {{PARA_CATEGORY}}
```

---

## Special Extraction Rules

### Link Extractions

- Extract full URL (not shortened)
- Capture page title if available
- Note: why this link matters

### Quote Extractions

- Include source attribution
- Preserve original context
- Add: why this quote is valuable

### Deadline Extractions

- Create calendar event
- Set reminder at 1 day before
- Link back to source email

---

## Processing Frequency

| Content Type | Extraction Frequency |
|--------------|---------------------|
| Deadlines | Real-time |
| Action items | Every digest cycle |
| Links/Resources | Twice-daily |
| Newsletters | Twice-daily |

---

## Usage Notes

- Extractions are idempotent (same content won't duplicate)
- User can mark extractions as "low value" to train future filtering
- Manual extractions always override automatic rules
- Review extracted items during weekly review

---

*Last updated: 2026-03-10*

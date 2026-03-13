# PARA Destination Mapping

Maps research output types to Google Drive PARA folder destinations.

## Output Type → PARA Category

| Output Type | PARA Category | Rationale |
|-------------|---------------|-----------|
| Report | Resources/Research/ | Long-term reference value |
| Dataset | Resources/Research/ | Reusable data for future work |
| Documentation | Resources/Reference/ | How-to and reference material |

## Folder Structure

```
03-Resources/
├── Research/
│   └── {topic}/
│       ├── {report-title}          (Google Doc)
│       ├── data/
│       │   └── {dataset-name}      (Google Sheet)
│       └── index.md                (topic overview)
└── Reference/
    └── {topic}/
        └── {doc-title}             (Google Doc)
```

## Google Drive Folder IDs

From `google-workspace-agent/shared/drive-structure.md`:

| Folder | ID |
|--------|-----|
| Resources root | `1Pp8pisGAjOhmF5dryMhySxZ-TgbpxoCG` |
| Research subfolder | Create if needed under Resources |
| Reference subfolder | Create if needed under Resources |

## File Naming Convention

| Output | Google Doc/Sheet Name |
|--------|----------------------|
| report.md | `{topic} - Research Report ({date})` |
| dataset.json | `{topic} - Dataset ({date})` |
| docs/*.md | Preserve original names |

## Metadata to Include

When creating Google Docs, include in the document header:

```markdown
---
Research Topic: {topic}
Generated: {date}
Pipeline: research-pipeline
Source: 05-output
---
```

## Linking Back

The `publish-log.md` should contain:
- Google Drive URL
- Folder path (e.g., `Resources/Research/ai-agents/`)
- Document type
- Original local file path

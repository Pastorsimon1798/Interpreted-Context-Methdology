---
name: recipe-save-email-attachments
description: "Automatically save email attachments to Google Drive."
---

# Save Email Attachments Recipe

Extract and save email attachments to organized Google Drive folders.

## Usage

```bash
gws recipe +save-attachments --messageId <id> --folderId <drive_folder_id>
```

## Workflow

1. **Fetch Email** - Get message with attachments
2. **List Attachments** - Show files to be saved
3. **Confirm** - Present for user approval
4. **Download & Upload** - Save to specified Drive folder
5. **Log** - Record in extraction log

## Example

```bash
# Save attachments from invoice email to Finance folder
gws recipe +save-attachments \
  --messageId "18c4f2e3b7a1d9e5" \
  --folderId "1ABC123xyz789"
```

## Folder Mapping

| Attachment Type | Default Folder |
|-----------------|----------------|
| Invoices | KB/Resources/Finance |
| Receipts | KB/Resources/Finance |
| Contracts | KB/Resources/Legal |
| Reports | KB/Resources/Reports |
| Presentations | KB/Resources/Presentations |

## Naming Convention

```
{sender_name}_{date}_{original_filename}
```

Example: `AcmeCorp_2024-01-15_Invoice_12345.pdf`

## Tips

- Always confirm before saving
- Use consistent folder structure
- Rename for clarity if needed
- Add sender to contacts for future routing

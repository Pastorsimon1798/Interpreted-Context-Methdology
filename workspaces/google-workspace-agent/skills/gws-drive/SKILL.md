---
name: gws-drive
description: "Google Drive file operations via gws CLI."
---

# GWS Drive

Manage Google Drive files and folders with gws CLI.

## Commands

| Command | Description |
|---------|-------------|
| `gws drive files list --folderId <id>` | List files in folder |
| `gws drive files get <fileId>` | Get file metadata |
| `gws drive files create --name "<name>" --mimeType <type>` | Create new file |
| `gws drive files update <fileId> --mediaFile <path>` | Update file content |
| `gws drive folders create --name "<name>" --parentFolderId <id>` | Create folder |

## Common Operations

### Create a Google Doc
```bash
gws drive files create \
  --name "Document Title" \
  --mimeType "application/vnd.google-apps.document" \
  --parents '["FOLDER_ID"]'
```

### Upload a File
```bash
gws drive files create \
  --name "file.pdf" \
  --mediaFile /path/to/file.pdf \
  --parents '["FOLDER_ID"]'
```

### Search for Files
```bash
gws drive files list --query "name contains 'keyword'"
```

## Tips

- Use folder IDs from drive-ids.sh for PARA folders
- Google Docs mimeType: `application/vnd.google-apps.document`
- Google Sheets mimeType: `application/vnd.google-apps.spreadsheet`
- Always verify parent folder before creating

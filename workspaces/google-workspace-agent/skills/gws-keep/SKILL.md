---
name: gws-keep
description: "Google Keep notes operations via gws CLI."
---

# GWS Keep

Manage Google Keep notes for quick capture and reference.

## Commands

| Command | Description |
|---------|-------------|
| `gws keep notes list` | List all notes |
| `gws keep notes get <noteId>` | Get note details |
| `gws keep notes create --title "<title>" --text "<content>"` | Create note |
| `gws keep notes update <noteId> --text "<content>"` | Update note |
| `gws keep notes delete <noteId>` | Delete note |

## Use Cases

### Quick Capture
```bash
gws keep notes create \
  --title "Idea: Project Name" \
  --text "Brief description of the idea"
```

### Meeting Notes
```bash
gws keep notes create \
  --title "Meeting: YYYY-MM-DD" \
  --text "- Attendee 1\n- Attendee 2\n\nAction items:\n- [ ] Item 1\n- [ ] Item 2"
```

## Tips

- Use for quick capture before processing to proper location
- Keep titles short and searchable
- Use checkboxes for action items
- Archive notes after processing

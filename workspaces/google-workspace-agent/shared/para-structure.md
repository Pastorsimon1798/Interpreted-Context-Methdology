# PARA Structure

> Projects/Areas/Resources/Archive organization for knowledge base.

## Root Configuration

**Knowledge Base Path:** `~/knowledge-base`

---

## Projects

Active, time-bound efforts with clear outcomes.

### Current Projects

*(General purpose agent - projects will be dynamically created based on email content)*

### Project Template

Each project folder should contain:
```
{project-name}/
├── README.md          (project brief)
├── Tasks.md           (action items)
├── Notes/             (meeting notes, research)
├── Resources/         (project-specific materials)
└── Archive/           (completed items)
```

### Project Naming Convention

`{date-prefix}-{project-name}` (e.g., `2024-01-website-redesign`)

---

## Areas

Ongoing responsibilities without end dates.

### Life Areas

- Health
- Finances
- Career
- Relationships
- Learning
- Personal Growth

### Area Template

Each area folder should contain:
```
{area-name}/
├── Overview.md        (area goals and context)
├── Checklists/        (recurring processes)
├── Reference/         (ongoing resources)
└── Reviews/           (periodic reviews)
```

---

## Resources

Reference materials for future use.

### Resource Categories

```
Resources/
├── AI-Tools/
├── Coding/
├── Productivity/
├── Neurodiversity/
├── Entrepreneurship/
├── Knowledge-Management/
├── Templates/
├── Research/
├── Learning/
└── Contacts/
```

### Resource Organization

```
Resources/{category}/
├── {topic-1}/
├── {topic-2}/
└── index.md           (category overview)
```

---

## Archive

Completed projects and inactive items.

### Archive Structure

```
Archive/
├── 2024/
│   ├── Q1/
│   ├── Q2/
│   └── Projects/
├── Old-Projects/
└── Deprecated/
```

### Auto-Archive Rules

| Item Type | Archive Trigger |
|-----------|-----------------|
| Completed project | Project marked done |
| Inactive area | 90 days unused |
| Stale resource | 180 days unused |
| Processed email | After extraction + filing |

---

## Folder Permissions

```
Projects/: Edit (me), View (team as needed)
Areas/: Private
Resources/: Edit (me), View (shared as needed)
Archive/: Read-only
```

---

## Cross-References

### Linking Between PARA Categories

```markdown
<!-- In a Project note -->
Related Area: [[Areas/Career]]
Resources: [[Resources/Productivity/Focus-Techniques]]

<!-- In an Area note -->
Active Projects: [[Projects/Current-Work]]
```

### Tag Convention

- `#project/{name}` - Project references
- `#area/{name}` - Area references
- `#resource/{type}` - Resource type
- `#waiting-for` - Blocked items
- `#someday` - Future consideration

---

## Integration Points

### Email to PARA

| Email Category | PARA Destination |
|----------------|------------------|
| action-required | Tasks in relevant Project/Area |
| newsletter | Resources/{topic}/ |
| reference | Resources/ or Project-specific |

### Calendar to PARA

- Meeting notes -> `Projects/{project}/Notes/`
- Recurring events -> `Areas/{area}/Checklists/`
- Deadlines -> `Projects/{project}/Tasks.md`

### Extractions to PARA

Extractions automatically route based on:
1. Project association (highest priority)
2. Area association
3. Resource type
4. Default to Archive if no match

---

## Review Cadence

| Review Type | Frequency | Focus |
|-------------|-----------|-------|
| Projects | Daily | Active tasks |
| Areas | Weekly | Goals and maintenance |
| Resources | Monthly | Culling and organizing |
| Archive | Quarterly | Cleanup and purging |

---

## Sync Configuration

- Real-time sync with Google Drive
- Manual sync available on request

---

## Usage Notes

- PARA structure supports both personal and work contexts
- Cross-reference liberally using `[[wikilinks]]`
- Archive liberally - storage is cheap, attention is expensive
- Review and restructure during weekly review

---

*Last updated: 2026-03-10*

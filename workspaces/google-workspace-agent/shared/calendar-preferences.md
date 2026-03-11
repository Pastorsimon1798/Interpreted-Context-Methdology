# Calendar Preferences

> Calendar settings and scheduling behavior for Google Workspace Agent.

## Working Hours

**Start:** `08:00`

**End:** `16:00`

**Timezone:** `America/Los_Angeles`

**Working Days:** `Mon-Fri`

---

## Default Event Settings

### Duration Defaults

| Event Type | Default Duration |
|------------|------------------|
| Standard meeting | `30` min |
| Quick sync | `15` min |
| Deep work | `60` min |
| 1:1 meetings | `30` min |

### Reminder Settings

**Default Reminder:** `15` minutes before

**Additional Reminders:**
- 1 day before for important events

### Notification Preferences

- Desktop notifications: enabled
- Mobile push: enabled
- Email reminders: enabled

---

## Focus Time Protection

### Focus Block Settings

**Duration:** `45` min

**Preferred Times:** `morning (08:00-12:00)`

**Auto-Schedule:** `enabled`

**Protection Level:** `moderate`

### Focus Block Rules

- Do not schedule over existing focus blocks unless explicitly approved
- Buffer between focus blocks: 15 minutes
- Minimum notice for focus block changes: 2 hours

---

## Agent Calendar Configuration

**Agent Calendar ID:** `primary`

**Agent Permissions:**
- Read events: all calendars
- Write permissions: primary calendar only

### Agent Actions

| Action | Permission |
|--------|------------|
| Read events | yes |
| Create events | yes |
| Modify events | yes |
| Delete events | ask first |
| Send invites | ask first |

---

## Scheduling Preferences

### Buffer Time

**Between Meetings:** `5` minutes

**Before First Meeting:** `15` minutes

**After Last Meeting:** `15` minutes

### Scheduling Windows

**Minimum Advance Booking:** `1` hour

**Maximum Advance Booking:** `90` days

**Same-Day Cutoff:** `before 3pm`

### Meeting Density

**Max Meetings Per Day:** `6`

**Max Consecutive Meetings:** `3`

**Max Meeting Hours Per Day:** `5`

---

## Event Categories

### Color Coding

- Focus time: Blue
- 1:1 meetings: Green
- Team meetings: Purple
- External calls: Orange
- Personal: Red
- Admin tasks: Gray

### Event Type Detection

| Keyword Pattern | Category |
|-----------------|----------|
| "1:1", "one-on-one" | 1:1 meeting |
| "sync", "check-in" | Quick sync |
| "focus", "deep work", "pomodoro" | Focus block |
| "interview", "call with" | External meeting |

---

## Recurring Event Handling

### Default Recurrence

**Weekly Recurring:** `same day each week`

**Monthly Recurring:** `same date each month`

### Recurrence End Rules

- Review recurring meetings every `3 months`
- Auto-end recurring events after `52` occurrences

---

## Travel Time

**Auto-Add Travel Time:** `disabled`

**Default Travel Duration:** `30` minutes

**Travel Buffer:** `10` minutes

---

## Conflict Resolution

### Priority Order

When scheduling conflicts occur, prioritize in order:

1. Client meetings
2. Team meetings
3. 1:1s
4. Focus time
5. Optional events

### Auto-Decline Rules

- Meetings outside working hours (ask first)
- More than 6 meetings already scheduled (ask first)
- Conflicts with blocked focus time (ask first)

---

## Integration Settings

### Email-to-Calendar

**Auto-Create from Emails:** `enabled`

**Detection Patterns:**
- Date + time in subject/body
- "schedule", "meet", "call" keywords
- Timezone abbreviations

### Task-to-Calendar

**Time-Block Tasks:** `enabled`

**Task Duration Estimate:** `30` minutes

---

## Usage Notes

- Preferences can be overridden per-event
- Agent respects all buffer and protection settings
- Settings sync across devices via Google Calendar
- Review preferences monthly during calendar audit

---

*Last updated: 2026-03-10*

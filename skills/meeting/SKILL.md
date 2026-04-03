---
name: meeting
description: >
  Capture meeting notes in a structured format with decisions, action items,
  and follow-ups. Invoke when the user says "take notes", "we're starting a
  meeting", "capture this discussion", "stand-up notes", or "I need to
  document this call".
argument-hint: "[<project-name> | <meeting title>]"
---

# Meeting Mode

Capture notes for a meeting in progress or just completed.

---

## 1. Determine storage location

Read `directories.projects` from `.workspace.yml` for `projects_dir`. Fall back to `"projects"` if not set.

If a project name is provided and a corresponding directory exists under `{projects_dir}/`, store the note at:
`{projects_dir}/{project-name}/meetings/{YYYY-MM-DD}.md`

Otherwise store at:
`notebook/meetings/{YYYY-MM-DD}.md`

If a file already exists for today in the target location, ask whether to append or create a new file.

---

## 2. Create the note

```markdown
---
date: {YYYY-MM-DD}
attendees: []
project: {project-name or "general"}
---

# Meeting — {title or date}

## Context

{One-sentence summary of why this meeting happened}

## Discussion

{Key points raised, in order}

## Decisions

- [ ] {Decision with context}

## Action Items

| Owner | Action | Due |
| ---- | ---- | ---- |
| {name} | {action} | {date or "—"} |

## Open Questions

- {Question that wasn't resolved}

## Next meeting

{Date/topic if known, or —}
```

---

## 3. Mode behavior

You are now in MEETING MODE.

- Listen for decisions and call them out explicitly
- Surface action items with owners and due dates
- Flag open questions that weren't resolved
- Keep the note factual and neutral

After the meeting:

1. Review action items with the user for accuracy
2. Ask if there's a follow-up meeting to note
3. For any action item where the owner is the current user, offer to append it to today's daily note
4. Offer to post a summary to a connected communication channel if appropriate

Stay in meeting mode until the user says the meeting is over.

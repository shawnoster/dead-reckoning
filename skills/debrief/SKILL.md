---
name: debrief
description: >
  Close a work block: capture what happened, carry-overs, and set up the
  next session. If it's the last session of the day, does a full reconcile
  (plan vs actual, tomorrow's stub). Invoke when the user says "/debrief",
  "debrief", "wrapping up", "done with this session", "closing out",
  "I'm done for the day", or any signal that a work block is ending.
argument-hint: "[--day]"
---

# Debrief

Close a work block. One question determines the depth.

---

## 1. Capture what happened

Write a progress log entry — what changed, what shipped, what matters.
Use `date +'%H:%M %Z'` for the timestamp. Max 2 lines.

```
- **HH:MM** — [what happened, ticket/PR refs if relevant]
```

---

## 2. One question

Ask once, immediately after writing the entry:

> *Done for the day, or more sessions coming?*

**More sessions coming → lightweight close:**

Note any carry-overs from this block:

```
**Carry-over:** [one line — what to pick up next]
```

Done. No recap, no summary, no ceremony.

**Done for the day → full reconcile:**

1. **Plan vs actual** — read the `## Plan` section from today's daily note.
   Note briefly what hit, what slipped, and why (one line each).

2. **Carry-overs** — anything unfinished that needs tomorrow. Flag if blocking.

3. **Tomorrow's stub** — create `notebook/daily/YYYY-MM-DD.md` for tomorrow.
   Add frontmatter + `## Plan` stub with carry-overs already populated.

4. **Status updates** — for any project that advanced today, update
   `projects/<name>/status.md`: current state, blockers, next 3 actions.

---

## Notes

- `--day` flag forces the full reconcile without asking
- If the daily note has no Plan section, skip plan vs actual
- Keep the full reconcile fast: clean handoff, not a journal entry
- Never ask "how did it go?" — read the progress log entries instead

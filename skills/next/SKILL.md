---
name: next
description: >
  Mid-session reset between tasks. Tidy up current work, scan for new signals,
  log the last activity, and surface the top 2-3 things to work on next.
  Invoke when the user says "what's next", "what should I work on", "I'm done
  with that", "take stock", "check in", or any time work on one thing ends
  and the next isn't obvious.
---

# Next

Reset between tasks. Close out what you just did, catch any new signals, surface what's next.

Run steps 1–3 concurrently.

---

## 0. Time check

If it's late in the day or the user has been working for a long stretch, offer `/debrief` instead:

> "It's getting late — want to close out with `/debrief`, or keep going?"

---

## 1. Tidy current work

Check `git status` in the current working directory.

- **Uncommitted changes**: list them, ask whether to commit (→ `/finish`), stash, or leave
- **Open PRs on the current branch**: fetch current state — CI status, review activity
- **Merged PRs**: note any that merged since the last progress log entry

---

## 2. Scan signals

Use the most recent progress log entry as the time anchor (default: 3 hours ago if none).

- New direct mentions or DMs awaiting reply
- New review requests or comments on open PRs
- Ticket updates: new comments, status changes, blockers

Cluster findings as: **needs-action** / **FYI** — only surface needs-action in the suggestion step.

---

## 3. Build priority queue

1. If `notebook/daily/{TODAY}.md` exists: scan the priority stack and progress log
2. If no daily file: query integrations directly for open tickets and PRs
3. If no integrations: scan `projects/*/status.md` for open blockers and next actions

Any of these is sufficient. Works cold.

---

## 4. Log activity

Run `date +'%H:%M %Z'`. Append a one-liner to `notebook/daily/{TODAY}.md` under `## Progress Log`:

```
- **HH:MM** — {brief description} — {ticket/PR ref if applicable}
```

If the file does not exist, create a minimal stub first.

---

## 5. Surface next suggestions

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Ready. Here's what's next:

  1. [URGENT]    {item} — {why: blocking someone / deadline / changes requested}
  2. [ADVANCE]   {item} — {context: in flight, next logical step}
  3. [QUICK WIN] {item} — {why: mergeable PR / small ticket / fast reply}

  New signals: {N} mentions · {N} PR updates · {N} ticket changes
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Prioritization order:
1. Blocking another person
2. Hard deadlines within 7 days
3. My PRs with changes requested
4. Open meeting action items (current user as owner)
5. Tickets in progress
6. My PRs approved and mergeable
7. Tickets to do, no deadline

Ask: "Want to take one of these, or is there something else on your mind?"

---

## Notes

- **Works cold** — no prior session, daily plan, or progress log required
- Lighter than a full session start — no calendar, no full project status scan
- Does not replace `/debrief` — if the day is ending, use that instead

# Triage

Process the inbox. Route each item to the right place and clear the queue.

---

## Steps

1. Read `notebook/inbox.md`
2. If inbox is empty: report "Inbox is empty" and stop.
3. For each item, route it:

   | Item type | Destination |
   |-----------|-------------|
   | Task for an active project | `projects/<name>/status.md` next actions |
   | New project worth starting | Create `projects/<name>/` with README + status.md stub |
   | Reference / snippet / link | `notebook/knowledge/<topic>.md` |
   | Actionable today | Today's daily note — Tier 1 if blocking, Tier 2 if in-flight |
   | Half-formed idea | `notebook/ideas/` |
   | Discard | Delete it |

4. Clear processed items from inbox.md (leave unprocessed items in place)
5. Report: N items processed — one line per item showing where it landed

## Triage priority rules

- **Blocking someone else** → Tier 1 in today's daily note
- **Deadline < 2 days** → Tier 1
- **In-flight, active work** → Tier 2
- **Assigned and real, no pressure** → Tier 3 or project next action
- **Reusable reference** → `notebook/knowledge/`
- **No next action yet** → `notebook/ideas/`
- **Won't act on it** → discard

## Notes

- Triage is a routing operation, not a planning session — move fast
- If an item is ambiguous, put it in `notebook/ideas/` rather than creating a half-baked project
- Run `/triage` whenever the inbox feels cluttered, not on a fixed schedule

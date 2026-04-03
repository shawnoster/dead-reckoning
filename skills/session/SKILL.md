---
name: session
description: >
  Start or close a work block. `/session <type> [project]` starts a block;
  `/session end` closes it. On start: first session of the day pulls signals
  (tickets, GitHub, Slack, Calendar) and builds a day plan; named projects
  load status and context; deeper research offered progressively.
  On end: logs what happened, asks if more sessions are coming, and either
  does a lightweight carry-over or a full day reconcile.
argument-hint: "<type> [focus/project] | end"
---

# Session

One command for the whole loop.

```
/session focus-work my-project    ← start a work block
/session end                      ← close it
```

---

## 0. Parse the invocation

- **type = `end`** → skip to [§Close](#close)
- **type = anything else** → proceed with session start below

If type is missing and it matters (it usually does), ask once before proceeding.

---

## Start

### 1. First-of-day check

Read today's daily note: `notebook/daily/YYYY-MM-DD.md`

- **No plan section yet** → run signal pull before anything else (§2)
- **Plan exists** → skip signal pull, go straight to context load (§3)

The first session of the day is the only time signals are pulled automatically.
Every subsequent session in the same day skips this unless the user asks.

---

### 2. Signal pull (first session only)

Pull the delta since the last daily note file:

```
Tickets:  assigned tickets + comments on active tickets (new since last daily note date)
GitHub:   PR review requests, CI failures, comments on open PRs
Slack:    direct mentions + active project channels
Calendar: today's events, any conflicts or prep needed
```

Synthesize into a **Tier 1 / Tier 2 / Tier 3** plan for the day.
Write the plan into `## Plan` in today's daily note.

Keep it fast — orientation, not a report. Three tiers, bullet points.

---

### 3. Context load

If a project or focus was named, load the minimum useful context:

1. `projects/<name>/status.md` — current state, blockers, next actions
2. `projects/<name>/README.md` — frontmatter (ticket key, repos, run env)
3. If `code_dir` is set and branch matters — `git status`, `git log --oneline -5`

Surface a **one-paragraph situation report**: where the project is, what's
blocking it, what the obvious next action is.

---

### 4. Offer to go deeper (progressive research)

After the situation report, assess whether there are signals worth investigating.
If so, offer one level deeper — don't just do it.

```
Level 1 (always): status.md + README loaded → situation report
Level 2 (offer):  "PR #22 has no review yet. Want me to pull the full diff?"
Level 3 (offer):  "Two pending config changes. Want me to trace the drift?"
Level 4 (offer):  "I can spawn parallel agents for a complete picture — 2-3 min."
```

One sentence per offer. Wait for yes before going deeper.
Stop when the user says "good enough" or starts working.

---

### 5. Set session posture

| Type | Posture |
|------|---------|
| `focus-work` | Execution-mode: concise, no tangents, interrupt only if blocking |
| `brainstorming` | Expansive: ask questions, surface alternatives, hold ideas open |
| `research` | Context-aggressive: lead with agents, synthesize before presenting |
| `meetings` | Capture-first: decisions + owners + actions above all else |
| `writing` | Structure-first: coherence and flow before speed |
| `gaming` / `play` | Personal mode: no project overhead, relaxed |

State the posture briefly, then stop talking.

---

### 6. Log the session start

Append to `notebook/daily/YYYY-MM-DD.md` under `## Progress Log`:

```
- **HH:MM** — Session: focus-work / project-name — [one line of what you're going into]
```

Use `date +'%H:%M %Z'` for the timestamp. Never use `<current_datetime>`.

---

## Close

*Reached via `/session end`.*

### 1. Log what happened

Write a progress log entry — what changed, what shipped, what matters.
Use `date +'%H:%M %Z'` for the timestamp. Max 2 lines.

```
- **HH:MM** — [what happened, ticket/PR refs if relevant]
```

### 2. One question

Ask immediately after writing the entry:

> *Done for the day, or more sessions coming?*

**More sessions coming → lightweight close:**

Note carry-overs from this block:

```
**Carry-over:** [one line — what to pick up next]
```

Done. No recap, no summary, no ceremony.

**Done for the day → full reconcile:**

1. **Plan vs actual** — read `## Plan` from today's daily note.
   Note what hit, what slipped, why (one line each).

2. **Carry-overs** — anything unfinished that needs tomorrow. Flag if blocking.

3. **Tomorrow's stub** — create `notebook/daily/YYYY-MM-DD.md` for tomorrow.
   Add frontmatter + `## Plan` stub with carry-overs already populated.

4. **Status updates** — for any project that advanced today, update
   `projects/<name>/status.md`: current state, blockers, next 3 actions.

---

## Notes

- Skip steps that don't apply — no project named means skip §3 and §4
- A `research` session type triggers Level 3-4 depth automatically
- If the user says "just orient me quickly" — stop after §3, no offers
- `--day` on `/session end` forces the full reconcile without asking
- Session posture persists until `/session end` or a new `/session`

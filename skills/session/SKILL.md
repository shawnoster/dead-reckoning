---
name: session
description: >
  Start a work block with declared intent. Handles all prep automatically:
  first session of the day pulls signals (tickets, GitHub, Slack, Calendar);
  named projects load status and context; deeper research is offered
  progressively — each layer reveals what's beneath it, you stop when you
  have enough. Session type shapes AI posture for the whole block.
  Invoke when the user says "session", "/session", "starting a session",
  "let's do a focus session", "going into brainstorm mode", "I'm about to
  work on X", or any intent to begin a bounded work block.
argument-hint: "<type> [focus/project]"
---

# Session

Start a work block. The session handles its own prep — you just declare
what you're doing and at what scale you want to work.

---

## 0. Parse the invocation

Extract from the user's message:
- **type** — `focus-work`, `brainstorming`, `research`, `meetings`, `writing`, `gaming`, or freeform
- **focus** — optional project name, topic, or ticket (e.g. `PROJ-189`, `dashboard deploy`, `aya architecture`)

If either is missing and the session type matters (it usually does), ask once before proceeding.

---

## 1. First-of-day check

Read today's daily note: `notebook/daily/YYYY-MM-DD.md`

- **No plan section yet** → run signal pull before anything else (§2)
- **Plan exists** → skip signal pull, go straight to context load (§3)

The first session of the day is the only time signals are pulled automatically.
Every subsequent session in the same day skips this unless the user asks.

---

## 2. Signal pull (first session only)

Pull the delta since the last daily note file — not a fixed window, but since
you last ran a session:

```
Tickets:  assigned tickets + comments on active tickets (new since last daily note date)
GitHub:   PR review requests, CI failures, comments on open PRs
Slack:    direct mentions + active project channels
Calendar: today's events, any conflicts or prep needed
```

Synthesize into a **Tier 1 / Tier 2 / Tier 3** plan for the day.
Write the plan into `## Plan` in today's daily note.

Keep it fast — this is orientation, not a report. Three tiers, bullet points,
done in under 60 seconds of reading.

---

## 3. Context load

If a project or focus was named, load the minimum useful context:

1. `projects/<name>/status.md` — current state, blockers, next actions
2. `projects/<name>/README.md` — frontmatter (ticket key, repos, run env)
3. If `code_dir` is set and branch matters — `git status`, `git log --oneline -5`

Surface a **one-paragraph situation report**: where the project is, what's
blocking it, what the obvious next action is.

---

## 4. Offer to go deeper (progressive research)

After the situation report, assess whether there are signals worth investigating:
open PRs, unread ticket comments, recent commits, Slack threads. If so, offer
one level deeper — don't just do it.

**The escalation pattern:**

```
Level 1 (always): status.md + README loaded → situation report
Level 2 (offer):  "PR #22 has no review yet. Want me to pull the full diff
                   and check CI status?"
Level 3 (offer):  "The config has 2 pending changes. Want me to
                   trace back through recent commits to understand the drift?"
Level 4 (offer):  "I can spawn parallel agents to build a complete picture —
                   architecture, ticket history, Slack threads, dependencies.
                   That'll take 2-3 minutes. Worth it?"
```

Each offer is one sentence. Wait for a yes before going deeper.
Stop when the user says "good enough" or starts working.

---

## 5. Set session posture

Based on session type, declare the working mode and stick to it:

| Type | Posture |
|------|---------|
| `focus-work` | Execution-mode: concise responses, no tangents, interrupt only if blocking |
| `brainstorming` | Expansive: ask questions, surface alternatives, hold multiple ideas open |
| `research` | Context-aggressive: lead with agents, synthesize before presenting |
| `meetings` | Capture-first: decisions + owners + actions above all else |
| `writing` | Structure-first: coherence, flow, formatting before speed |
| `gaming` / `play` | Personal mode: no project overhead, relaxed |

State the posture briefly, then stop talking and let the user work.

---

## 6. Log the session start

Append to `notebook/daily/YYYY-MM-DD.md` under `## Progress Log`:

```
- **HH:MM** — Session: focus-work / project-name — [one line of what you're going into]
```

Use `date +'%H:%M %Z'` for the timestamp. Never use `<current_datetime>`.

---

## Notes

- Skip steps that don't apply — no project named means skip §3 and §4
- A `research` session type triggers Level 3-4 depth automatically
- If the user says "just orient me quickly" — stop after §3, no offers
- The session posture persists for the whole block until `/debrief` or a new `/session`

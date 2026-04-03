---
name: session
description: >
  Start a session — briefing, work block, or creative time. First session of
  the day delivers a full briefing (priorities, calendar, open work); subsequent
  sessions load context for the declared focus. Session type shapes AI posture.
  Invoke when the user says "session", "good morning", "what's on today",
  "brief me", "catch me up", "let's do a focus session", "going into brainstorm
  mode", "I'm about to work on X", or any intent to begin a work block.
argument-hint: "[type] [focus/project]"
---

# Session

Start a session. The first session of the day is a full briefing; every session
after that is a targeted context load. You declare what you're doing, the session
handles its own prep.

Run all data-gathering steps concurrently where possible — do not wait for one
to finish before starting the next.

---

## 0. Parse the invocation

Note the current date and time via `date +'%Y-%m-%d %H:%M %Z'`. Use this for
all timestamps — never trust `<current_datetime>` (it returns UTC).

Extract from the user's message:
- **type** — `focus-work`, `brainstorming`, `research`, `meetings`, `writing`, `gaming`, or freeform
- **focus** — optional project name, topic, or ticket (e.g. `PROJ-189`, `dashboard deploy`)

If neither is given, that's fine — treat it as a general session start.

Determine:
- **Day type**: weekday (Mon–Fri) vs. weekend
- **Time of day**: morning (before noon) / afternoon / evening
- **First session?**: check if `notebook/daily/{TODAY}.md` has a `## Plan` section already

---

## 1. Environment scan (always)

Run concurrently:
- `aya status -f json` — system health, alerts, reminders, watches. If aya is not installed, skip.
- `aya context` — quick workspace snapshot (active projects, todo count, inbox size, last daily note). Use as baseline for deeper scans. If deeper scans contradict, trust the deeper scan.
- `aya inbox --as <instance> -f json` — pending relay packets. If aya is not configured, skip.

---

## 2. First session of the day → full briefing

If today's daily note has no `## Plan` section yet (or doesn't exist), run
the full briefing. This is the only time signals are pulled automatically.

**Adapt depth based on context:**

| Context | Depth |
| ---- | ---- |
| Weekday, morning | Full — all sections |
| Weekday, afternoon/evening | Focused — skip calendar, surface blockers and carry-overs only |
| Weekend | Light — personal items, creative work prominent, skip work tracking |

### 2a. Carry-overs

Check yesterday's (and recent) daily notes. Extract:

- Items marked in-progress that don't appear as done in later notes (carry-overs)
- Items marked done (momentum — what's been accomplished recently)
- Patterns: recurring topics, things that keep showing up without resolution

If carry-overs exist, **treat those as the top of Tier 1** — do not re-derive:

```
Carrying from {YESTERDAY}: {item} — {context}
```

Read `notebook/AGENTS.md` to understand repo structure and active project paths.

### 2b. Open tasks

Read the workspace's task tracking file (e.g. `notebook/inbox.md`, a `todos.md`,
or whatever the workspace uses). Capture unchecked items. Note any sitting more
than a week.

Group as:
- **Actionable now** — clear next step, no blockers
- **Waiting / blocked** — needs input, dependency, or a purchase
- **Stale** — sitting unchecked with no recent context

### 2c. Project status scan

Read `.workspace.yml` for `directories.projects` (default: `projects/`).
Scan each project's `status.md`:

- Current phase and blockers
- File modification time via `git log -1 --format='%ai' -- {file}`
- Flag >7 days untouched as **stale**
- Flag active/planning projects as priority candidates
- Note blockers, open questions, or next steps

### 2d. External signals

Pull the delta since the last daily note:

```
Tickets:  assigned tickets + comments on active tickets
GitHub:   PR review requests, CI failures, comments on open PRs
Slack:    direct mentions + active project channels (if connected)
Calendar: today's events, conflicts, prep needed (if connected)
```

Surface any aya alerts, watches, or due items from the status check.

Skip gracefully if integrations are not available.

### 2e. Synthesize the briefing

Produce the briefing. **Omit sections with no data** — don't show empty tables.

```
### Session Briefing — {YYYY-MM-DD} {day of week}

**Snapshot**: {N} tasks open · {N} projects active · {N} stale · {N} aya packets pending

---

#### Tier 1 — Act now
Items that are carry-overs, blocked, or time-sensitive.

| # | Item | Source | Why now |

---

#### Tier 2 — Advance today
In-flight work that can make meaningful progress this session.

| # | Item | Source | Context |

---

#### Tier 3 — On radar
Open but no immediate pressure.

| # | Item | Source | Notes |

---

#### Stale projects
Projects not touched in >7 days.

| Project | Last touched | Status |

---

#### Today's calendar
(if available)

---

#### Pending aya packets
(if any)
```

**Prioritization logic (applied in order):**

1. Carry-overs from previous sessions — unfinished business
2. Anything blocking a deploy, PR, or another person
3. Items with real deadlines
4. Active projects with clear next steps
5. Tasks sitting >7 days — decide or drop
6. Quick wins — small items that can clear in <15 minutes

Keep it fast — this is orientation, not a report. Three tiers, bullet points,
done in under 60 seconds of reading.

### 2f. Save to daily note

If `notebook/daily/{TODAY}.md` doesn't exist, create it:

```markdown
# {YYYY-MM-DD}

## Plan
{tier 1 and tier 2 items as a checklist}

## Progress Log
{empty}

## Notes
{empty}
```

If it exists, append under a `## Briefing` section without disturbing existing content.

**After the briefing, skip to §5 (posture) if a type was declared, otherwise ask:**

> "What do you want to pick up first?"

---

## 3. Subsequent session → context load

If today's daily note already has a `## Plan` section, skip the full briefing.
Summarize what's already in the plan rather than rebuilding.

If a project or focus was named, load the minimum useful context:

1. `projects/<name>/status.md` — current state, blockers, next actions
2. `projects/<name>/README.md` — frontmatter (ticket key, repos, run env)
3. If `code_dir` is set and branch matters — `git status`, `git log --oneline -5`

Surface a **one-paragraph situation report**: where the project is, what's
blocking, what the obvious next action is.

---

## 4. Offer to go deeper (progressive research)

After the situation report, assess whether there are signals worth investigating:
open PRs, unread ticket comments, recent commits, aya packets. If so, offer
one level deeper — don't just do it.

```
Level 1 (always): status.md + README loaded → situation report
Level 2 (offer):  "PR #22 has no review yet. Want me to pull the full diff
                   and check CI status?"
Level 3 (offer):  "The config has 2 pending changes. Want me to
                   trace back through recent commits to understand the drift?"
Level 4 (offer):  "I can spawn parallel agents to build a complete picture —
                   architecture, ticket history, dependencies.
                   That'll take 2-3 minutes. Worth it?"
```

Each offer is one sentence. Wait for a yes before going deeper.
Stop when the user says "good enough" or starts working.

A `research` session type triggers Level 3–4 depth automatically.

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

If no type was declared, don't force one — just proceed naturally.

State the posture briefly, then stop talking and let the user work.

---

## 6. Log the session start

Append to `notebook/daily/{TODAY}.md` under `## Progress Log`:

```
- **HH:MM** — Session: {type} / {focus} — [one line of intent]
```

Use `date +'%H:%M %Z'` for the timestamp. Never use `<current_datetime>`.

---

## Notes

- Skip steps that don't apply — no project named means skip §3 and §4
- If the user says "just orient me quickly" — stop after §3, no offers
- The session posture persists until `/debrief`, `/next`, or a new `/session`
- If today's plan already exists and the user says "brief me" or "catch me up" — summarize the existing plan, don't rebuild
- `/session` with no arguments on first-of-day is the daily briefing
- A `research` session type triggers Level 3–4 depth automatically

## Aliases

This skill also runs for:
- "good morning", "what's on today", "start of day"
- "brief me", "catch me up", "what did I miss"
- "starting a session", "let's do a focus session"
- "going into brainstorm mode", "I'm about to work on X"

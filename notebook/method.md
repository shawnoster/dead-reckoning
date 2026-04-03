---
version: "1.0"
name: "Dead Reckoning"
short: "DR"
---

# Dead Reckoning

**Dead reckoning** is the navigation technique of knowing your current position
from your logged history: last known fix + heading + speed + elapsed time.
No GPS required — the log IS the position.

This workspace runs DR. You know where you are because you've recorded where
you've been. Projects advance through phases. Sessions pick up from `status.md`.
The AI is the navigator keeping the log honest.

> **This is the canonical DR spec and starter kit.** Instances are initialized
> from it, then evolve independently to fit the user's content and cadence.
> Once forked, your `notebook/method.md` is yours — it may diverge from this
> doc. That's correct behavior.

---

## The Loop

Two commands. Everything else is in the middle.

```
/session <type> [focus]    ← start a work block, declare intent
  ... work ...
/session end                   ← close the block, capture what happened
```

That's it. Run it 1–4 times a day. Each session can be different:

```
/session focus-work my-project
/session brainstorming aya architecture
/session meetings
/session writing dashboard spec
/session gaming                          ← personal context, no overhead
```

### What `/session` does automatically

- **First session of the day**: pulls signals (tickets, GitHub, Slack, Calendar delta)
  and builds a Tier 1/2/3 day plan
- **Any session with a named project**: loads status.md + README, surfaces
  current state and blockers
- **Progressive research**: offers to go deeper layer by layer — each layer
  reveals what's beneath. You stop when you have enough.

  | Level | What happens |
  |-------|-------------|
  | 1 | `status.md` + `README.md` loaded — situation report (always) |
  | 2 | Offer: pull PR diff, CI status, ticket comments |
  | 3 | Offer: spawn agent for full ticket / Slack / commit history |
  | 4 | Offer: parallel agents — complete picture in 2–3 minutes |

  A `research` session type triggers Level 3–4 automatically.
- **Posture shift**: adjusts AI behavior to match the session type
  (concise in focus-work, expansive in brainstorming, capture-first in meetings)

### What `/session end` does

- Writes a progress log entry (what happened, ticket/PR refs)
- Asks one question: *done for the day, or more sessions coming?*
  - More sessions → lightweight (carry-over note, done)
  - Done for the day → full reconcile (plan vs actual, carry-overs,
    tomorrow's stub, status.md updates)

---

## The Structure

Three tiers. Each has one job. They don't overlap.

| Tier | Folder | Job | Rule |
|------|--------|-----|------|
| Control plane | `notebook/` | Behavior, workflow, the log | No project docs, no code |
| Execution memory | `projects/` | All understanding of active work | No raw code, no logs |
| Working copies | `code/` | Cloned repos for reading and editing | No notes or docs |

**Keep notes out of `code/`.** Code is the source of truth for what a system
does — read it and edit it here. But when you learn something about a codebase
during a session, write that understanding up in `projects/<name>/architecture.md`,
not as a file dropped in the repo or a comment in the code.

---

### `notebook/` — the control plane

Everything that governs *how you work* lives here. Not what you're working on — how.

```
notebook/
  AGENTS.md       How the AI navigates this workspace. Read first on every session.
                  Contains: tier model, signal routing, session lifecycle, key paths.

  CLAUDE.md       Behavioral instructions for the AI. What AGENTS.md orients,
                  CLAUDE.md instructs: responsibilities, daily note rules, persona,
                  trigger words, storage contract.

  method.md       This file. The canonical DR spec.

  daily/          YYYY-MM-DD.md — one file per day.
                  WHY HERE: the log belongs to the control plane, not to any
                  project. It records everything across all sessions and projects.
                  It's the ship's log, not a project artifact.

  meetings/       YYYY-MM-DD.md — cross-project and general meetings.
                  ROUTING RULE: does this meeting advance a specific project?
                  → projects/<name>/meetings/. Does it span projects or involve
                  org/team context? → notebook/meetings/.

  ideas/          Freeform files — pre-project thinking, half-formed concepts.
                  ROUTING RULE: can you write a one-line goal for this? → make
                  it a project. Can't yet? → ideas/.

  memory/         Operational state: scheduler state, preferences.
                  WHY HERE: runtime state for the control plane — not project
                  knowledge, not logs.

  templates/      Markdown templates for project files.
                  WHY HERE: templates govern how work is structured — control
                  plane territory. Use them; don't invent structure ad-hoc.
```

---

### `projects/` — execution memory

Everything you know about active and past work lives here. One directory per project.

```
projects/<name>/
  README.md       REQUIRED. The entry point and index.
                  Contains: one-line summary, frontmatter (ticket, status, code_dir,
                  run_env, key_files, repos), links to all project files.
                  WHY: the AI reads README.md first on /session with a project name.

  status.md       REQUIRED. Single source of truth for current state.
                  Contains: phase, health indicator (🟢/🟡/🔴), current focus,
                  blockers, next 3 actions, decision log.
                  WHY: status.md is the last known fix in dead reckoning. Every
                  session reads it. Every debrief updates it. If status.md is stale,
                  you've lost your position.

  discovery.md    Business context, requirements, affected repos, open questions.

  architecture.md Current implementation analysis, technical design, data flow.
                  WHY HERE: this is your understanding of the codebase — the
                  insight you built by reading code/. It belongs to the project,
                  not to the repo.

  plan.md         Implementation approach, steps, decisions made.

  meetings/       YYYY-MM-DD.md — meetings about this project specifically.

  documents/      Polished deliverables: specs, proposals, external-ready artifacts.
```

**Phase ordering matters.** Files are created in order: `discovery.md` → `architecture.md` → `plan.md`. You don't create a plan before you understand the problem.

**Ad-hoc files** use type prefix: `research-<topic>.md`, `proposal-<topic>.md`, `assessment-<topic>.md`, `guide-<topic>.md`.

---

### `code/` — working copies

Cloned repositories. Read and edit code here. Don't create notes or docs here.

```
code/<repo-name>/   The authoritative source for application code. Read it,
                    edit it, run it. When you learn something about how it works,
                    write that up in projects/<name>/architecture.md — not here.
```

---

### Routing decisions — where does this go?

| What you have | Where it goes | Why |
|---------------|--------------|-----|
| Daily activity log entry | `notebook/daily/` | Belongs to the day, not any project |
| Meeting note (one project) | `projects/<name>/meetings/` | Project artifact |
| Meeting note (cross-project, org) | `notebook/meetings/` | No single project owns it |
| Half-formed idea | `notebook/ideas/` | Not a project yet |
| Idea with a clear goal | `projects/<name>/` with README + status | Promoted to project |
| Understanding of a codebase | `projects/<name>/architecture.md` | Insight belongs to project memory, not the repo |
| Polished deliverable | `projects/<name>/documents/` | Findable by project |
| Evergreen engineering knowledge | `projects/engineering-handbook/` | Reference, no done state |
| Template for future use | `notebook/templates/` | Governs how work is structured |
| Runtime state (scheduler, prefs) | `notebook/memory/` | Operational, not knowledge |

---

## The Daily Log

`notebook/daily/YYYY-MM-DD.md` — one file per day, two sections:

```markdown
## Plan
Tier 1 / Tier 2 / Tier 3 — written by the first /session of the day

## Progress Log
- **HH:MM** — session: focus-work / my-project — what you were going into
- **HH:MM** — what shipped or changed (ticket/PR refs)
- **HH:MM** — session: brainstorming / architecture
- ...
```

The log is the position fix. `/session` opens entries. `/session end` closes them.
You can look at any day's file and know exactly where you were.

---

## Signal Routing

Signals arrive from tickets, GitHub, Slack, the relay, and calendar.
The principle: don't process signals as they arrive — surface them at the right moment.

| Signal | When it surfaces |
|--------|----------------|
| PR review request / CI failure | Immediately — blocking |
| Ticket comment, Slack mention | First session of the day |
| Completed task / merged PR | Write to status.md + progress log now |
| aya relay packet (trusted) | Ingest at session start, surface to user |

---

## Session Types

| Type | What it means |
|------|---------------|
| `focus-work` | Execution — concise AI, no tangents, interrupt only if blocking |
| `brainstorming` | Generative — ask questions, hold multiple ideas, explore tangents |
| `research` | Deep context — lead with agents, build picture before starting work |
| `meetings` | Capture mode — decisions + owners + actions above everything |
| `writing` | Structure mode — flow and coherence before speed |
| `gaming` / `play` | Personal — no project overhead |

---

## Instances

DR is a starter kit. Each instance is initialized from this spec, then evolves
to fit its user, content, and cadence. The notebook on a given machine is the
authority for that machine.

What tends to stay stable across instances: the two-command loop, the three-tier
structure, and the routing principle — each type of content has one home.

What varies: project scale, session types in use, signal sources, which folders
exist, whether the relay is active.

---

## Why "Dead Reckoning"

> *"Dead reckoning requires no external reference. Given a last known position
> and a continuous log of speed and heading, you always know where you are."*

You don't need a perfect memory or a perfect briefing to know where you are in
your work. You need a reliable log and a consistent habit of writing to it.

`status.md` is the last known fix.
`daily/` is the continuous log.
The AI is the navigator who reads both and holds the heading.

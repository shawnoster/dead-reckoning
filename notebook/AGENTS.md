# AGENTS.md — workspace

> Personal engineering control plane — operating system, execution memory, and workflow coordination.

## Control Plane Model

| Tier | Folder | Role |
|------|--------|------|
| **Root** | `workspace/` | Operating system — assistant rules, notes, scripts, links |
| **Execution memory** | `projects/` | State, decisions, discovery, plans per project |
| **Working copies** | `code/` | Cloned repos — gitignored or external; path set in `.workspace.local.yml` |

Keep notes out of `code/`. When you learn something from a codebase, write it up in `projects/`, not alongside the code.

## Launch Point + Memory Contract

- **Launch point**: workspace root (where this `AGENTS.md` lives). Launching inside `notebook/` or a code repo loses workspace config.
- **Behavior/config**: `notebook/AGENTS.md` (this file) + `notebook/CLAUDE.md`
- **Project memory**: `projects/<name>/` — status, decisions, discovery, plans
- **Session memory**: `notebook/memory/` — scheduler state, preferences
- **Execution targets**: wherever `code_dirs` points in `.workspace.local.yml`

## Session Lifecycle

```
/session <type> [focus]   ← start a work block
  ... work ...
/session end              ← close the block or the day
```

## Signal Intake and Routing

| Signal | Destination | Timing |
| ---- | ---- | ---- |
| **aya packet (trusted)** | Ingest, surface to user | Session start / `aya receive` |
| **aya seed** | Surface as conversation opener | Session start |
| **Ticket (assigned)** | Morning briefing Tier 1 | Next `/session` |
| **Ticket comment / update** | Morning briefing | Next `/session` |
| **PR review feedback** | Surface immediately | Via `aya schedule watch` |
| **CI failure (my PR)** | Surface immediately | Via watch |
| **Direct mention (messaging)** | Morning briefing | Next `/session` |
| **Meeting notes** | `projects/<name>/meetings/` + `status.md` | End of meeting |
| **Merged PR / completed task** | `status.md` + daily note progress log | Immediately |

**Triage order**: blocking alerts → aya packets → aya seeds → briefing → low-priority.

## Operating Cadence

| Frequency | Action |
|-----------|--------|
| **Daily** | Update each active project `status.md` — current state, blockers, next 3 actions |
| **Weekly** | Close stale projects; promote evergreen learnings to knowledge base |
| **Per feature** | Run phases in order: discovery → architecture → plan → implement |
| **Every meeting** | Note ends with decisions + owners — no exceptions |

## Guardrails

- Keep the repo **private** — personal control plane, not a team resource
- **No secrets or PII** — credentials and personal data never committed
- **Use templates** — `notebook/templates/` for all new project files

## Directory Structure

```
workspace/
├── notebook/                  # Control plane
│   ├── AGENTS.md              # This file — structure + routing
│   ├── CLAUDE.md              # Behavioral instructions
│   ├── method.md              # DR spec
│   ├── inbox.md               # Capture queue — /triage routes items out
│   ├── daily/                 # YYYY-MM-DD.md — primary activity log
│   ├── meetings/              # Cross-project meeting notes
│   ├── ideas/                 # Pre-project thinking
│   ├── memory/                # Scheduler state, preferences
│   └── templates/             # Project file templates
├── projects/                  # Project documentation
└── skills/                    # Command definitions
```

`code/` is not committed — point `code_dirs` in `.workspace.local.yml` to wherever you clone repos on this machine.

## Project Structure Convention

Every project in `projects/` has two required files:

```
projects/<project-name>/
├── README.md      # REQUIRED — index, ticket/repo refs in frontmatter
├── status.md      # REQUIRED — phase, blockers, next actions
├── discovery.md   # Business context, requirements, affected repos
├── architecture.md
├── plan.md
├── meetings/      # YYYY-MM-DD.md per meeting
└── documents/     # Polished deliverables
```

Ad-hoc files use type prefix: `research-*.md`, `proposal-*.md`, `assessment-*.md`.

## Commands

- `/session <type>` — start a work block (focus-work, brainstorming, research, meetings, writing)
- `/session end` — close a block or the day
- `/meeting` — capture a meeting
- `/triage` — process `notebook/inbox.md` and route items out
- `/next` — mid-session pivot between tasks
- `/status` — workspace readiness check
- `make notebook-status` — readiness check
- `make link-skills` — (re)wire local skills as Claude Code commands

## Skills

Commands are defined as markdown files in `skills/<name>/SKILL.md` and symlinked
to `.claude/commands/` via `make link-skills`. To see what a command does, read
its skill file directly.

## The Loop

This workspace runs **Dead Reckoning** (DR). Full spec: `notebook/method.md`.

```
/session <type> [focus]   ← start a work block
/session end              ← close the block
```

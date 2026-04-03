---
doc: getting-started
---

# Getting Started — Dead Reckoning

> *"Dead reckoning requires no external reference. Given a last known position and a continuous log of speed and heading, you always know where you are."*

This is a personal engineering operating system. Its job is to keep you oriented across multiple concurrent projects, across multiple machines, and across sessions that may be hours or days apart — without a briefing, without context loss, without starting from scratch.

The AI is the navigator. You're the captain. The system keeps the log.

---

## The Mental Model

Three tiers. Each has one job. They don't overlap.

```
workspace/
├── notebook/      Control plane  — how you work
├── projects/      Memory         — what you know about active work
└── code/          Hands          — cloned repos for reading and writing code
```

**`notebook/`** governs behavior. Daily notes live here. So do the rules, templates, and method spec. If you want to change how the system works, you edit files here.

**`projects/`** holds everything you know about active and past work. Not the code — the *understanding*. Discovery docs, architecture analysis, plans, meeting notes, status. One folder per project. When you switch contexts, this is where the AI picks up your thread.

**`code/`** is just cloned repos. You read and write code here. Nothing else.

**The cardinal rule:** `code/` is never the source of truth for anything. If you learn something about a codebase, it goes in `projects/`, not in the code itself.

---

## The Two-Command Loop

```bash
/session focus-work my-project    ← start a work block
  ... work ...
/debrief                          ← close the block
```

That's the whole thing. Everything else is what happens in the middle.

**`/session`** does:
- First session of the day → pulls signals (Jira, GitHub, Slack, Calendar) and builds a Tier 1/2/3 day plan, written to `notebook/daily/YYYY-MM-DD.md`
- Any session with a named project → loads `status.md` + `README.md`, surfaces current state and blockers, offers to go deeper layer by layer
- Sets AI posture to match session type (concise in `focus-work`, expansive in `brainstorming`, capture-first in `meetings`)

**`/debrief`** does:
- Appends a timestamped progress log entry (what happened, ticket/PR refs)
- Asks one question: *done for the day, or more sessions coming?*
  - More sessions → lightweight carry-over note, done
  - Done for the day → full reconcile: plan vs actual, tomorrow's stub, `status.md` updates for projects that moved

Session types: `focus-work`, `brainstorming`, `research`, `meetings`, `writing`, `gaming`.

---

## How Commands Work

The `/session`, `/debrief`, and other commands are **skills** — markdown files that Claude Code reads as command definitions.

```
workspace/
└── skills/
    ├── session/
    │   └── SKILL.md     ← the command definition
    ├── debrief/
    │   └── SKILL.md
    ├── meeting/
    │   └── SKILL.md
    └── ...
```

Skills are wired as Claude Code commands via symlinks:

```bash
make link-skills
# Creates: .claude/commands/session.md  → ../../skills/session/SKILL.md
#          .claude/commands/debrief.md  → ../../skills/debrief/SKILL.md
#          ... (one per skill)
```

After `make link-skills`, Claude Code picks them up and they're available as `/session`, `/debrief`, etc. **This is the step that wires the system together — run it after cloning.**

To customize a command, edit `skills/<name>/SKILL.md` and re-run `make link-skills`.

---

## A Typical Day

### Morning — first session

```bash
/session focus-work my-project
```

The first `/session` of the day triggers the briefing automatically. Claude pulls signals from connected integrations since the last daily note, builds a Tier 1/2/3 plan, and writes it to `notebook/daily/YYYY-MM-DD.md`.

Tier 1 is blocking or overdue. Tier 2 is in-flight. Tier 3 is on the radar.

Then it loads context for the named project, surfaces current state, and stops talking.

### During the day

Use `/next` to pivot between tasks — it tidies up, scans for new signals, and surfaces the top 2-3 things to work on next.

### End of a block

```bash
/debrief
```

Mid-day: a carry-over note and done. End of day: full reconcile — plan vs actual, what slipped, tomorrow's stub, and `status.md` updates for every project that moved.

---

## The Project Lifecycle

Every project in `projects/` advances through phases in order:

```
discovery  →  architecture  →  plan  →  implement  →  done
```

You don't jump phases. You don't write a plan before you understand the problem.

| Phase command | Output |
|---------------|---------|
| `/discovery <project>` | `discovery.md` — business context, requirements, open questions |
| `/architecture <project>` | `architecture.md` — current implementation analysis, data flow |
| `/plan <project>` | `plan.md` — implementation approach, decisions |
| `/implement <project>` | Code changes |
| `/finish` | Commit, push, PR, ticket transition |

Every project has two required files:
- **`README.md`** — entry point, one-line summary, frontmatter (ticket key, repos, run environment)
- **`status.md`** — single source of truth: phase, health indicator (🟢/🟡/🔴), blockers, next 3 actions

`status.md` is the last known fix in dead reckoning. If it's stale, you've lost your position.

---

## The Toolchain

### Claude Code

The AI navigator. Reads `notebook/` for behavioral rules, `projects/` for project context, reads and writes `code/` for implementation. Skills in `skills/` define its commands. Launch from the workspace root.

### aya CLI

Personal orchestration layer:

```bash
aya schedule remind --due "tomorrow 9am" -m "Review staging deploy"
aya schedule watch github-pr owner/repo#123
aya receive --instance home         # check for relay packets
aya schedule list                   # active reminders + watches
```

### MCP Servers

Claude's tool connections to external systems:

| Server | Capabilities |
|--------|-------------|
| GitHub | PRs, CI, code search, issue management |
| Atlassian | Jira + Confluence — tickets, status, pages |
| Slack | Read channels, search, send (draft for review first) |
| Google Calendar + Gmail | Events, scheduling, email |

### `.workspace.yml`

Portable workspace config. Two files:
- `.workspace.yml` (committed) — directory layout, behavioral anchors, instance label
- `.workspace.local.yml` (gitignored) — machine-specific paths

---

## The Relay — Work ↔ Home

Two instances of this system can run concurrently: work and home. They stay in sync via an async relay built on the Nostr protocol. No shared login, no VPN, no manual file transfer.

```bash
# Send context to the other instance
echo "Context for home" | aya dispatch --to home --intent "subject"

# Check for packets from the other instance
aya receive --instance home
```

Packets are signed with your DID keypair and verified before ingestion. Relay uses public Nostr relays — do not send secrets or PII through it.

---

## Setting Up a New Instance

```bash
# 1. Clone
git clone https://github.com/shawnoster/dead-reckoning ~/workspace
cd ~/workspace

# 2. Wire skills
make link-skills

# 3. Install aya
uv tool install git+https://github.com/shawnoster/aya
aya init    # generates DID keypair in ~/.aya/profile.json

# 4. Install Claude Code
# See: https://claude.ai/code

# 5. Connect MCP servers
# GitHub, Jira, Slack, Calendar — see each server's install docs

# 6. Verify
make notebook-status
```

If pairing a second instance (work ↔ home relay):
```bash
# On first instance
aya pair --label work

# On second instance
aya pair --code <code> --label home
```

---

## Finding Your Way Around

| I'm looking for... | Go to |
|--------------------|-------|
| What I'm doing today | `notebook/daily/YYYY-MM-DD.md` |
| Status of a project | `projects/<name>/status.md` |
| Background on a project | `projects/<name>/README.md` → discovery/architecture |
| Meeting notes | `projects/<name>/meetings/` or `notebook/meetings/` |
| A half-formed idea | `notebook/ideas/` |
| Behavioral rules | `notebook/CLAUDE.md` + `notebook/AGENTS.md` |
| The full method spec | `notebook/method.md` |
| How a command works | `skills/<name>/SKILL.md` |

---

## What Makes This Different

Most productivity systems are **push**: you decide what to track, you maintain it, you remember to check it.

This system is **pull**: the AI reads the log, loads the context, surfaces what matters. You write to it; it navigates from it. The only discipline required is closing sessions with `/debrief` so `status.md` stays current.

The log IS the position. As long as you keep the log, you always know where you are.

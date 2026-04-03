# Dead Reckoning

> *"Dead reckoning requires no external reference. Given a last known position
> and a continuous log of speed and heading, you always know where you are."*

A personal engineering operating system for working with Claude Code across
multiple projects, machines, and sessions — without context loss, without
briefing the AI from scratch every time.

## The idea

Three things:

- `status.md` — your last known position for every project
- `notebook/daily/YYYY-MM-DD.md` — the continuous log
- Claude Code — the navigator that reads both

Two commands run the whole loop:

```
/session focus-work my-project    ← start a work block
/debrief                          ← close it
```

`/session` on the first run of the day pulls signals from connected integrations
(Jira, GitHub, Slack, Calendar), builds a Tier 1/2/3 day plan, and loads context
for your named project. Every subsequent session skips the briefing and just loads
context. `/debrief` writes the progress log, reconciles plan vs actual, and stubs
tomorrow. Everything else happens in the middle.

## Prerequisites

### Claude Code

Install from [claude.ai/code](https://claude.ai/code) — available as a CLI or desktop app.

### aya CLI — optional but recommended

Without aya, you get the core session loop: `/session`, `/debrief`, project
context, daily notes. That's the whole method and it works on its own.

With aya, you get:
- **Reminders and watches** — `aya schedule remind` for time-based nudges;
  `aya schedule watch` to poll a PR or ticket and alert you when it changes
- **Work ↔ home relay** — async context sync between two machines over
  the Nostr protocol; carry decisions and open threads between instances
  without shared login or manual file transfer
- **`make notebook-status`** — the workspace health check

aya is a Python CLI tool — **not a Claude Code plugin**, cannot be installed
via `make link-skills`. Install it separately:

```bash
# Requires uv — install uv first if you don't have it:
curl -LsSf https://astral.sh/uv/install.sh | sh

# Then install aya:
uv tool install git+https://github.com/shawnoster/aya
aya init    # generates your identity keypair in ~/.aya/profile.json
```

### MCP servers (optional)

Connect integrations to unlock signal-pull in `/session`:
GitHub · Jira/Confluence · Slack · Google Calendar

## Bootstrap

```bash
# 1. Clone
git clone https://github.com/shawnoster/dead-reckoning ~/workspace
cd ~/workspace

# 2. Wire skills as Claude Code commands
make link-skills

# 3. Configure machine-specific paths (see below)
cp .workspace.local.yml.example .workspace.local.yml
# edit .workspace.local.yml — set workspace_root and code_dirs

# 4. Open Claude Code from the workspace root — this matters
claude .

# 5. First session
/session focus-work
```

## Configuring paths

Two config files govern the workspace layout:

**`.workspace.yml`** (committed, shared) — the structure: directory names, behavioral anchors, instance label.

**`.workspace.local.yml`** (gitignored, per-machine) — machine-specific paths. Copy the example and fill it in:

```bash
cp .workspace.local.yml.example .workspace.local.yml
```

```yaml
# .workspace.local.yml — your machine, gitignored
workspace_root: ~/workspace        # absolute path to this repo

code_dirs:
  - ~/workspace/code               # where cloned repos live
  # - ~/src                        # add more if needed
```

This is how `/switch` knows where to find `code_dir` entries in project frontmatter, and how aya knows where to anchor the workspace.

## Layout

```
workspace/
├── notebook/          Control plane — how you work, not what you're working on
│   ├── AGENTS.md      Structure + routing (Claude reads this first every session)
│   ├── CLAUDE.md      Behavioral instructions
│   ├── method.md      Full Dead Reckoning spec
│   ├── daily/         YYYY-MM-DD.md — one log file per day
│   ├── meetings/      Cross-project meeting notes
│   ├── ideas/         Pre-project thinking (not yet actionable)
│   ├── knowledge/     Personal evergreen knowledge — snippets, notes, links
│   └── templates/     Project file templates
├── projects/          One folder per project — status, plans, decisions
├── code/              Cloned repos — read/write code here, docs never
├── skills/            Command definitions (session, debrief, meeting, ...)
└── Makefile           make link-skills wires skills → .claude/commands/
```

**Cardinal rule:** `code/` is never the source of truth for anything.
Insights from reading a codebase go in `projects/<name>/architecture.md`.

### The knowledge folder

`notebook/knowledge/` is for personal, evergreen knowledge that doesn't belong to any one project:

- Code snippets and patterns you reach for repeatedly
- Onboarding notes for tools, languages, or systems
- Curated links (Python resources, library docs, reference material)
- Tool quirks and environment gotchas discovered during sessions

Files are organized by domain: `knowledge/python.md`, `knowledge/aws.md`, `knowledge/dev-environment.md`, etc.

The `/session-learnings` command writes here automatically at the end of deep-dive sessions.

## How commands work

Skills are markdown files in `skills/<name>/SKILL.md`. `make link-skills`
symlinks them into `.claude/commands/` where Claude Code picks them up as
slash commands.

```bash
make link-skills
# skills/session/SKILL.md  →  .claude/commands/session.md
# skills/switch/SKILL.md   →  .claude/commands/switch.md
# skills/debrief/SKILL.md  →  .claude/commands/debrief.md
# ...
```

To customize a command, edit the skill file and re-run `make link-skills`.

## Your first project

```bash
mkdir -p projects/my-project
cp notebook/templates/README-template.md projects/my-project/README.md
cp notebook/templates/status-template.md projects/my-project/status.md
# edit the frontmatter (ticket key, repos, run env)
/session focus-work my-project
```

## Available commands

| Command | What it does |
|---------|--------------|
| `/session <type> [project]` | Start a work block |
| `/debrief` | Close a block or the day |
| `/switch <project>` | Load project context mid-session (shows picker if no arg) |
| `/meeting` | Capture a meeting with decisions + owners |
| `/next` | Mid-session pivot — tidy up and surface what's next |
| `/status` | Workspace readiness check |
| `/discovery <project>` | Start discovery phase — produces `discovery.md` |
| `/architecture <project>` | Analyze codebase — produces `architecture.md` |
| `/plan <project>` | Design implementation — produces `plan.md` |
| `/implement <project>` | Build — code changes with plan tracking |
| `/finish` | Commit, push, PR, close ticket |
| `/relay` | Send/receive packets between instances (requires aya pairing) |
| `/session-learnings` | Capture what was learned to `notebook/knowledge/` |

Session types: `focus-work` · `brainstorming` · `research` · `meetings` · `writing` · `gaming`

## Going further

- `notebook/method.md` — the full spec: three-tier model, session lifecycle,
  signal routing, why it's designed this way
- `notebook/getting-started.md` — detailed walkthrough of every component
  including the relay (work↔home sync) and MCP setup

## License

MIT

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

| Tool | Purpose |
|------|---------|
| [Claude Code](https://claude.ai/code) | The AI navigator (CLI or desktop) |
| [aya](https://github.com/shawnoster/aya) | Scheduler, reminders, work↔home relay |

MCP servers (optional, but unlock signal-pull features):
GitHub · Jira/Confluence · Slack · Google Calendar

aya install:
```bash
uv tool install git+https://github.com/shawnoster/aya
aya init    # generates your identity keypair in ~/.aya/profile.json
```

## Bootstrap

```bash
# Clone
git clone https://github.com/shawnoster/dead-reckoning ~/workspace
cd ~/workspace

# Wire skills as Claude Code commands
make link-skills

# Open Claude Code from the workspace root — this matters
claude .

# First session
/session focus-work
```

That's it. Claude reads `notebook/AGENTS.md` on launch and knows the structure.

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
│   └── templates/     Project file templates
├── projects/          One folder per project — status, plans, decisions
├── code/              Cloned repos — read/write code here, docs never
├── skills/            Command definitions (session, debrief, meeting, ...)
└── Makefile           make link-skills wires skills → .claude/commands/
```

**Cardinal rule:** `code/` is never the source of truth for anything.
Insights from reading a codebase go in `projects/<name>/architecture.md`.

## How commands work

Skills are markdown files in `skills/<name>/SKILL.md`. `make link-skills`
symlinks them into `.claude/commands/` where Claude Code picks them up as
slash commands.

```bash
make link-skills
# skills/session/SKILL.md  →  .claude/commands/session.md
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

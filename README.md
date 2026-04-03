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

One command runs the whole loop:

```
/session focus-work my-project    ← start a work block
/session end                      ← close it
```

`/session` on the first run of the day pulls signals from connected integrations
(Jira, GitHub, Slack, Calendar), builds a Tier 1/2/3 day plan, and loads context
for your named project. Every subsequent session skips the briefing and just loads
context. `/session end` writes the progress log, reconciles plan vs actual, and
stubs tomorrow. Everything else happens in the middle.

## Prerequisites

### Claude Code

Install from [claude.ai/code](https://claude.ai/code) — available as a CLI or desktop app.

### aya CLI — optional but recommended

Without aya, you get the core session loop: `/session`, project context, daily
notes. That's the whole method and it works on its own.

With aya, you get:
- **Reminders and watches** — `aya schedule remind` for time-based nudges;
  `aya schedule watch` to poll a PR or ticket and alert you when it changes
- **Work ↔ home relay** — async context sync between two machines over
  the Nostr protocol; carry decisions and open threads between instances
  without shared login or manual file transfer
- **Workspace health check** — `aya status` reports scheduler state, identity,
  and integration health

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

# 3. Configure machine-specific paths
cp .workspace.local.yml.example .workspace.local.yml
# edit .workspace.local.yml — set workspace_root and code_dirs

# 4. Open Claude Code from the workspace root — this matters
claude .

# 5. Start your first session
/session focus-work
```

## Configuring paths

Two config files govern the workspace layout:

**`.workspace.yml`** (committed, shared) — directory names relative to the workspace root, behavioral anchors, instance label.

**`.workspace.local.yml`** (gitignored, per-machine) — overrides for your machine. Copy the example and fill it in:

```bash
cp .workspace.local.yml.example .workspace.local.yml
```

```yaml
# .workspace.local.yml — your machine, gitignored
workspace_root: ~/workspace        # absolute path to this repo

code_dirs:
  - ~/workspace/code               # where cloned repos live
```

Directory paths in `.workspace.yml` are relative to `workspace_root` by default.
If a directory lives **outside** the workspace, override it here with an absolute path:

```yaml
# .workspace.local.yml
directories:
  projects: ~/projects             # projects dir lives outside the workspace
  notebook: ~/notes                # so does the notebook
```

This means you can keep `projects/` in a separate repo, a Dropbox folder, or anywhere else on the machine — skills read the merged config and find it regardless.

## Layout

```
workspace/
├── notebook/          Control plane — how you work, not what you're working on
│   ├── AGENTS.md      Structure + routing (Claude reads this first every session)
│   ├── CLAUDE.md      Behavioral instructions
│   ├── method.md      Full Dead Reckoning spec
│   ├── inbox.md       Capture queue — drop anything here, /triage routes it out
│   ├── daily/         YYYY-MM-DD.md — one log file per day
│   ├── meetings/      Cross-project meeting notes
│   ├── ideas/         Pre-project thinking (not yet actionable)
│   ├── knowledge/     Personal evergreen knowledge — snippets, notes, links
│   └── templates/     Project file templates
├── projects/          One folder per project — status, plans, decisions
├── docs/              Reference guides — SDLC workflow patterns, extension points
├── skills/            Command definitions (session, meeting, switch, ...)
└── Makefile           make link-skills wires skills → .claude/commands/
```

**Keep notes out of `code/`.** When you learn something by reading a codebase,
write it up in `projects/<name>/architecture.md` — not as a file dropped in the
repo, not as a code comment. Your understanding of the code belongs in `projects/`,
not alongside the code itself.

`code/` is not a committed directory — point `code_dirs` in `.workspace.local.yml`
to wherever you clone repos on this machine. The workspace doesn't own that directory.

**`docs/`** holds reference guides that apply across projects — currently
`sdlc-workflows.md`, which explains how to layer a structured SDLC workflow system
(design gates, TDD plan generators, debugging protocols) on top of the DR skill
pipeline. Add your own guides here as your workflow evolves.

### The inbox

`notebook/inbox.md` is zero-friction capture. Drop anything here — tasks, ideas,
links, questions, notes — without stopping to file it properly. Run `/triage` to
route items to the right place: active projects, daily notes, `knowledge/`, `ideas/`,
or discard.

The flow: capture now, decide later.

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
# ...
```

To customize a command, edit the skill file and re-run `make link-skills`.

## Your first project

```
/discovery my-project
```

`/discovery` scaffolds the project directory automatically — creates
`projects/my-project/` with `README.md`, `status.md`, and `discovery.md`
from the templates in `notebook/templates/`, then drops into a conversation
to understand the project context. When you're ready to work:

```
/session focus-work my-project
```

## Available commands

| Command | What it does |
|---------|--------------|
| `/session <type> [project]` | Start a work block |
| `/session end` | Close a block or the day |
| `/switch <project>` | Load project context mid-session (shows picker if no arg) |
| `/meeting` | Capture a meeting with decisions + owners |
| `/triage` | Process `notebook/inbox.md` — route items to projects, daily notes, knowledge, or discard |
| `/next` | Mid-session pivot — tidy up and surface what's next |
| `/status` | Workspace readiness check |
| `/discovery <project>` | Scaffold project + start discovery phase — produces `discovery.md` |
| `/architecture <project>` | Analyze codebase — produces `architecture.md` |
| `/plan <project>` | Design implementation — produces `plan.md` |
| `/implement <project>` | Build — code changes with plan tracking |
| `/feature <description>` | Start a feature — branch, ticket, project context |
| `/issue-to-pr <issue-number>` | Full pipeline: issue → discovery → plan → implement → PR |
| `/address-pr-feedback [pr-number]` | Triage review comments, fix, reply, and push |
| `/finish` | Commit, push, PR, close ticket |
| `/session-learnings` | Capture what was learned to `notebook/knowledge/` |

Session types: `focus-work` · `brainstorming` · `research` · `meetings` · `writing`

## Multi-machine relay (advanced)

If you run two instances of this workspace — work and home — aya's relay syncs
context between them asynchronously over the Nostr protocol. No shared login,
no VPN, no manual file transfer.

```bash
# Send context to the other instance
aya relay send --to home "end-of-day notes and open threads"

# Receive at home
aya relay receive
```

Packets are signed with your DID keypair and verified before ingesting. Requires
pairing two aya instances first (`aya pair`). The `/relay` skill in `skills/relay/`
handles the full send/receive/status flow. Full setup in `notebook/getting-started.md`.

## Going further

- `notebook/method.md` — the full spec: three-tier model, session lifecycle,
  signal routing, why it's designed this way
- `notebook/getting-started.md` — detailed walkthrough of every component
  including the relay (work↔home sync) and MCP setup
- `docs/sdlc-workflows.md` — how to layer a structured SDLC workflow system
  (design gates, TDD plan generators, debugging protocols) on top of the DR skill pipeline

## License

MIT

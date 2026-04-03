---
name: discovery
description: >
  Locate relevant code, repos, and context for a project before diving in.
  Invoke when the user says "find the code for X", "where does X live",
  "what repos are involved", "help me get oriented", or "I'm not sure where
  to start — let's look around first".
argument-hint: "<project-name>"
---

# Discovery Mode

When this skill is invoked with a project name:

---

## 1. Locate workspace config

Read `.workspace.yml` (relative to the workspace root). Extract `directories.projects` for `projects_dir`. Fall back to `"projects"` if not set.

If the config is missing, ask the user where project files are stored before continuing.

---

## 2. Scaffold project files

Set `projectPath` to `{projects_dir}/{project-name}`.

Create the directory if it doesn't exist. Check for and create missing files:

- `README.md` — project hub with frontmatter (ticket key, repos)
- `status.md` — current phase (set to "Discovery"), blockers, next actions
- `discovery.md` — affected repos, business context, requirements, entry points

If any file already exists, load it and resume from where it left off.

---

## 3. Status messages

New project:
```
✓ Created project structure at: {projectPath}
📍 DISCOVERY MODE ACTIVE
Track repositories in discovery.md's repos table.
```

Resuming:
```
📍 Resuming DISCOVERY MODE for: {project-name}
Loading: {discoveryPath}
```

---

## 4. Mode behavior

You are now in DISCOVERY MODE.

**Focus:**
- Locate relevant repositories — local and remote
- Track each repo in `discovery.md`'s Affected Repositories table
- Identify key files, entry points, APIs, and integration points
- Map dependencies between components
- Assess initial scope and complexity

**Boundaries:**
- Do NOT analyze implementation details (that's `/architecture`)
- Do NOT create plans or solutions (that's `/plan`)
- Do NOT make code changes (that's `/implement`)
- Stay in discovery until the user explicitly switches modes

**Approach:**
- This is a COLLABORATIVE CONVERSATION — ask questions, share findings, wait for guidance
- Update `discovery.md` incrementally as insights emerge
- Do not work autonomously

If resuming: read `discovery.md`, summarize findings so far, then ask how to continue.
If new: **before asking the user to describe the problem**, dead-reckon from available context:
- If a project tracking integration is connected, query it for the ticket title, description, and acceptance criteria first.
- If a code hosting integration is connected, search for existing branches or PRs referencing the project name or ticket key.
- Pre-populate `discovery.md` with what you find, then ask only what's still missing.

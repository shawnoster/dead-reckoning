---
name: feature
description: >
  Start a new feature — create or reference a ticket, branch from main,
  scaffold project context, and set the session posture for focused work.
  Invoke when the user says "start a feature", "new feature", "let's build X",
  "branch for X", "kick off X", or "create a ticket for X".
argument-hint: "<feature-description> [--project <name>] [--ticket <id>]"
---

# Feature

Start a feature right. Branch, ticket, context — then get to work.

---

## 1. Locate workspace config

Read `.workspace.yml` (relative to the workspace root). Extract:

- `directories.projects` → `projects_dir` (default: `"projects"`)
- `instance_label` → used for aya relay calls

---

## 2. Parse the invocation

Extract from the user's message:

- **feature description** — what is being built (required; ask if absent)
- **project** — the DR project name to attach this feature to (optional)
- **ticket** — an existing ticket ID to link (optional; e.g. `PROJ-42`)

If neither project nor ticket is given, ask:

> "Which project is this for, or do you want me to create a new one?"

---

## 3. Resolve the ticket

**If a ticket ID was given:** Fetch the ticket via the GitHub/Jira integration
(whichever is connected). Confirm title, description, and current status.

**If no ticket was given and an integration is connected:** Offer to create one:

> "Want me to create a ticket for this? I can draft a title and description from what you described."

If the user confirms, create the ticket with:
- **Title**: derived from the feature description
- **Type**: Story or Feature (Jira) / Issue (GitHub)
- **Description**: one paragraph expanding on the feature description

**If no integration is connected:** Skip silently and proceed without a ticket reference.

---

## 4. Derive the branch name

Build the branch name from the feature description (and ticket ID if available):

| Input | Branch |
|-------|--------|
| Ticket `PROJ-42` + description `add dark mode` | `feat/PROJ-42-add-dark-mode` |
| No ticket + description `add dark mode` | `feat/add-dark-mode` |

Confirm the branch name with the user before creating it.

---

## 5. Create the branch

Check git state in the project's `code_dir` (from `.workspace.local.yml`, or ask
if not set):

```
git fetch origin
git checkout main        # or the repo's default branch
git pull origin main
git checkout -b {branch-name}
```

If the branch already exists: confirm with the user before checking it out.

---

## 6. Set up project context

If a DR project directory exists at `{projects_dir}/{project}`:
- Read `status.md` (first 40 lines) and summarize current state

If the project directory does not exist:

> "No project context found for `{project}`. Want me to run `/discovery` to scaffold it?"

If the user agrees, invoke the `/discovery` skill. Otherwise proceed — this
feature can start cold.

---

## 7. Transition the ticket

If a ticket is linked and the integration supports it, transition it to
**In Progress**.

---

## 8. Log the activity

Append to today's daily note (`notebook/daily/{TODAY}.md`) under `## Progress`:

```
- **HH:MM** — Feature started: {branch-name} · {ticket-ref if any}
```

Use `date +'%H:%M %Z'` for the timestamp. Never use `<current_datetime>`.

---

## 9. Hand off

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Ready.

  Branch:  {branch-name}
  Ticket:  {ticket-ref} — {title}  (or "none")
  Project: {project}               (or "—")
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Offer the natural next steps:

> "Want to jump into discovery (`/discovery`), or start planning directly (`/plan`)?"

---

## Notes

- Never push the branch automatically — the user decides when to publish
- If `code_dirs` is not set in `.workspace.local.yml`, ask where the repo lives
  before running git commands
- If multiple repos are involved, ask which one to branch in first; handle
  the others explicitly
- Branch naming is a suggestion — the user can override before creation

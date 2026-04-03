---
name: switch
description: >
  Switch active working context to a project. Reads README.md frontmatter to
  orient to the right code repo, run environment, and key files. One command
  replaces 3-5 minutes of manual orientation. Invoke when the user says
  "/switch", "switch to X", "load project X", "focus on X", or "what projects
  are active".
argument-hint: "<project-name>"
---

# Switch Project Context

Switch active working context to a project. Reads `README.md` frontmatter to
orient to the right code repo, run environment, and key files.

---

## 1. Resolve the project

Read `directories.projects` from `.workspace.yml` for `projects_dir`. Fall back to `"projects"`.

Three cases, in order:

**A — No argument (`/switch` alone):** Show the full picker (see Picker Format below).

**B — Partial/ambiguous match:** Filter project directories to names containing the argument (case-insensitive substring match).
- 0 matches → show full picker with "no match for X" header
- 1 match → proceed as exact match
- 2+ matches → show filtered picker with only matching projects

**C — Exact match:** Proceed directly. No picker shown.

Once resolved: parse frontmatter from `README.md`: `code_dir`, `run_env`, `key_files`, `jira`, `status`, `repos`

---

### Picker Format

```
┌─────────────────────────────────────────────────────────────┐
│  /switch — pick a project                                   │
├──────┬──────────────────────────────────┬────────┬─────────┤
│  #   │  Project                         │ Ticket │ Status  │
├──────┴──────────────────────────────────┴────────┴─────────┤
│  Active                                                     │
│   1   my-feature                        PROJ-42   impl     │
│   2   api-redesign                      —          disc     │
│                                                             │
│  Reference / Evergreen                                      │
│   3   engineering-handbook              —          active   │
│                                                             │
│  Complete                                                   │
│   4   old-migration                     —          done    │
└─────────────────────────────────────────────────────────────┘
Pick a number, or type more of the name:
```

**Grouping rules:**
- **Active** — status is `discovery`, `architecture`, `planning`, or `implementation`
- **Reference / Evergreen** — status is `evergreen` or `active` with no done state
- **Complete** — status is `complete` or `done`

**Data source:** Read all `{projects_dir}/*/README.md` frontmatter. Sort Active group by last-modified date.

---

## 2. Load code context (if `code_dir` is set)

```bash
cd <code_dir>
git branch --show-current
git status --short
git log --oneline -3
```

- If `run_env: uv` → all Python commands use `uv run` — never `python` or `pip` directly
- If `run_env: node` → use `npm run <script>` or check `package.json`
- Read each file listed in `key_files` (skip any that don't exist)
- If `key_files` is empty, read `README.md` from the code repo root

## 3. Load project context

- Read `{projects_dir}/<project-name>/status.md` (first 40 lines)
- Do NOT read discovery.md or architecture.md unless the user asks — on-demand only

## 4. Output context card

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Switched → <project-name>

  Ticket:   <jira> — <one-line summary>
  Status:   <status>  Phase: <phase>
  Code:     <code_dir>  [<run_env>]
  Branch:   <current-branch>
  <git status if dirty>

  Key context loaded:
    • <file1>
    • <file2>

  Next actions (from status.md):
    • <next action 1>
    • <next action 2>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If no `code_dir`:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Switched → <project-name>  [discovery phase]

  Ticket:   <jira>
  Status:   <status>

  Loaded: status.md

  Next actions:
    • <next action 1>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Run Environment Rules

| `run_env` | Rule |
|-----------|------|
| `uv` | Always `uv run <cmd>` — never `python`, `python3`, or `pip` directly |
| `node` | Use `npm run <script>` or check `package.json` |
| `go` | Use `go run ./...` |
| `make` | Check `Makefile` for available targets |
| `none` | No runtime assumptions — check README |

---

## Notes

- `/switch` replaces manual orientation — do not re-read files already loaded unless the user asks
- Background tasks (PR watches, reminders) are unaffected by `/switch`
- To see all active watches alongside current project: run `/status` after switching

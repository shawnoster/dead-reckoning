---
name: issue-to-pr
description: >
  Run the full pipeline from a GitHub issue to an open PR — fetch and validate
  the issue, confirm scope, run discovery, plan, implement, and open the PR with
  the issue linked. Invoke when the user says "work on issue #N", "implement
  issue N", "take issue N to PR", "pick up issue N", or "let's do issue N".
argument-hint: "<issue-number> [--repo <owner/repo>]"
---

# Issue to PR

One command for the full loop: issue → discovery → plan → implement → PR.

---

## 1. Locate workspace config

Read `.workspace.yml`. Extract:

- `directories.projects` → `projects_dir` (default: `"projects"`)

---

## 2. Fetch and validate the issue

Fetch the issue from the GitHub MCP integration:

- Title, body, labels, assignees, milestone
- Current state (open / closed)
- Linked PRs (if any)

**Validation:**

| Check | Action |
|-------|--------|
| Issue is closed | Ask: "This issue is already closed — still want to work on it?" |
| Issue already has an open PR | Show the PR URL; ask: "A PR already exists — resume that branch, or start fresh?" |
| Issue is unassigned | Offer to self-assign before starting |
| Issue body is empty or too vague | Ask 1-2 clarifying questions before proceeding |

If no GitHub integration is connected: ask for the issue number and title manually,
then proceed without live data.

---

## 3. Confirm scope

Summarize the issue in 2-3 sentences. Surface any ambiguity:

- Unclear acceptance criteria
- Missing context (no reproduction steps for bugs, no mockups for UI work)
- Dependencies on other issues or external systems

Ask the user to confirm before starting:

> "Here's what I understand: {summary}. Does this look right, or anything to clarify first?"

Do not proceed to planning without a confirmation.

---

## 4. Run `/feature`

If not already on a feature branch, invoke `/feature` to create the branch and
link the ticket:

- Use the issue number as the ticket reference (e.g. `feat/42-add-dark-mode`)
- Name the project after the repo or let the user pick
- Transition the issue to "In Progress" if the integration supports it

---

## 5. Discovery

Run the `/discovery` skill against the relevant codebase:

- Goal: locate the relevant code, understand the scope, map dependencies
- Produce `projects/{project}/discovery.md`
- Exit discovery only when the blast radius is understood

If discovery.md already exists and covers this issue:

> "Discovery context already exists. Want to review it or proceed to architecture?"

---

## 6. Architecture

Run the `/architecture` skill:

- Goal: understand how the existing code works before proposing changes
- Produce or update `projects/{project}/architecture.md`
- Focus on the components discovery identified as relevant

Skip with user approval if the area is already well understood.

---

## 7. Plan

Run the `/plan` skill:

- Goal: design the implementation approach — what changes, in which files, in what order
- Produce `projects/{project}/plan.md`
- Propose 2-3 approaches with tradeoffs before settling
- **Do not proceed to implementation until the user explicitly approves the plan**

---

## 8. Implement

Invoke `/implement` to execute the approved plan:

- Write failing tests first, then the minimal implementation to pass them
- Commit atomically — one logical change per commit
- Do not push — that happens in the next step

---

## 9. Finish

Invoke `/finish` to close the loop:

- Commit any final changes
- Push the branch
- Open the PR — link the issue in the body (e.g. `Closes #N`)
- Transition the issue to **In Review**
- Log the activity to today's daily note

---

## 10. Hand off

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Done.

  Issue:  #{number} — {title}
  Branch: {branch-name}
  PR:     #{pr-number} — {pr-title}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Notes

- Each phase (discovery, architecture, plan, implement, finish) is a full skill
  invocation — use those skills' full behavior, not a shortcut summary
- If the user wants to skip a phase, ask once and honor the answer
- The design gate in `/plan` is hard — do not proceed to `/implement` without
  explicit user approval
- If the issue scope grows during implementation, surface it immediately and
  decide: expand scope, open a follow-up issue, or cut
- Works without a GitHub integration — but issue linking and ticket transitions
  are skipped

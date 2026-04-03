---
name: finish
description: >
  Close out a completed piece of work — commit, push, open a PR, transition
  the ticket to In Review, and log the activity. Invoke when the user says
  "I'm done", "open a PR", "ship it", "wrap this up", "commit and push", or
  after implementation work is complete and ready for review.
argument-hint: "[<project-name>]"
---

# Finish

Close the implementation loop. Commit, push, PR, ticket, log — then hand off.

---

## 1. Check working state

Run `git status`. Determine:

- **Uncommitted changes**: list changed files
- **Current branch**: confirm it's a feature branch (not `main` or the repo default)
- **Already pushed**: check whether the branch has a remote tracking branch
- **Existing PR**: check whether a PR already exists for this branch

If the working tree is already clean and a PR already exists, skip to step 4.

---

## 2. Commit

If there are uncommitted changes:

- Show a summary of changed files
- Suggest a commit message following [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `chore:`, `docs:`, etc.)
- Wait for confirmation before committing — do not commit without approval

---

## 3. Push and open the PR

Push the branch to the remote.

If a PR already exists: show the URL and current state. Skip creation.

If no PR exists, create one:
- **Title**: derived from the ticket summary or branch name
- **Body**: Summary, Type of change, Related issues, Test plan
- **Base branch**: `main` (or the repo's default)
- **Draft?**: ask — "Ready for review, or start as draft?"

Output the PR URL.

---

## 4. Update the ticket

If a project tracking integration is connected and a ticket was associated with this branch:

- Transition the ticket to **In Review**
- Link the PR to the ticket if the integration supports it

---

## 5. Log the activity

Append to today's daily notes under `## Progress`:

```
- **HH:MM** — Opened PR #{number} — {PR title} · {ticket ref}
```

---

## 6. Hand off

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Shipped.

  Branch:  {branch-name}
  PR:      #{number} — {title}
  Ticket:  {key} → In Review
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Notes

- Never force-push or amend published commits
- If the working tree has unrelated changes, flag them and ask before proceeding
- If CI is not yet passing, note it in the PR description and suggest starting as draft
- If there is no ticket, skip step 4 gracefully

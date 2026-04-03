---
name: address-pr-feedback
description: >
  Load review comments on an open PR, triage them, make the required fixes,
  reply to each reviewer, and push the updated branch. Invoke when the user
  says "address PR feedback", "fix review comments", "respond to the review",
  "handle the PR comments", or "my PR has feedback".
argument-hint: "[<pr-number>] [--repo <owner/repo>]"
---

# Address PR Feedback

Triage review comments, fix what needs fixing, reply, and push — methodically.

---

## 1. Locate workspace config

Read `.workspace.yml`. Extract:

- `directories.projects` → `projects_dir` (default: `"projects"`)

---

## 2. Load the PR

If a PR number was given, fetch it from the GitHub MCP integration.

If no PR number was given:

1. Check `git branch --show-current` for the active branch
2. Search for an open PR on that branch
3. If still ambiguous, list the user's open PRs and ask which one to address

Fetch:

- PR title, description, base branch, and current CI status
- All review threads (resolved and unresolved)
- All inline comments and general review comments

---

## 3. Triage the comments

For each unresolved comment or review thread, classify it:

| Category | Meaning |
|----------|---------|
| **Must fix** | Correctness, security, performance, or the reviewer explicitly requested a change |
| **Suggestion** | Style, naming, readability — the reviewer offered an option but didn't require it |
| **Question** | The reviewer is asking for context or an explanation, not requesting a code change |
| **Outdated** | Comment is on a line that has since changed; likely no longer relevant |

Present the triage summary before making any changes:

```
PR #{number} — {title}

Must fix   ({N}):  {brief list}
Suggestion ({N}):  {brief list}
Question   ({N}):  {brief list}
Outdated   ({N}):  {brief list}
```

Ask: "Does this look right? Anything to re-classify before I start?"

Do not make any code changes until the triage is confirmed.

---

## 4. Confirm the work plan

For each **must-fix** item, state the proposed change:

```
1. {comment excerpt} → {one-line description of the fix}
2. ...
```

For each **suggestion**, ask whether to apply it:

> "Suggestion from @{reviewer}: '{excerpt}' — apply it?"

For each **question**, draft a reply without making code changes:

> "Question from @{reviewer}: '{excerpt}' → Proposed reply: '{draft}' — OK to post?"

Wait for the user to confirm the plan before writing code.

---

## 5. Make the fixes

Address each confirmed **must-fix** item one at a time:

- Make the minimal change that resolves the comment
- Write or update tests if the fix changes behavior
- Use the same TDD discipline as `/implement`: failing test → fix → verify
- Do not touch unrelated code

After each fix, mark the comment as resolved in the summary.

---

## 6. Apply accepted suggestions

For each accepted suggestion, apply the change and mark it resolved.

---

## 7. Reply to comments

For each resolved comment, post a reply to the reviewer:

- **Must-fix / suggestion**: brief confirmation of what changed
  (e.g. "Fixed — renamed to `{newName}` in `{file}`")
- **Question**: post the approved reply draft
- **Outdated**: mark as resolved with a note ("This line was refactored in the
  latest push — no longer applies")

If the GitHub integration is connected, post replies via the MCP tool.
If not, output the replies as a block for the user to post manually.

---

## 8. Push the changes

Commit and push:

- Follow Conventional Commits for the commit message
  (e.g. `fix: address review feedback on {pr-title}`)
- Wait for user confirmation before committing — do not commit without approval
- Push to the same branch

After pushing, check that CI is triggered and note the status.

---

## 9. Re-request review

If any reviewer left a "changes requested" state:

> "Want me to re-request review from {reviewers}?"

Wait for confirmation before re-requesting.

---

## 10. Log the activity

Append to today's daily note under `## Progress`:

```
- **HH:MM** — Addressed PR #{number} feedback ({N} fixes, {N} replies)
```

Use `date +'%H:%M %Z'` for the timestamp. Never use `<current_datetime>`.

---

## 11. Hand off

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Review addressed.

  PR:       #{number} — {title}
  Fixed:    {N} must-fix items
  Replied:  {N} comments
  CI:       {status or "triggered"}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Notes

- Never resolve comments in the GitHub UI without a corresponding reply — silence
  looks like the comment was ignored
- If a must-fix requires a design change, surface it: "This fix changes the
  approach we agreed on in `/plan`. Want to revise the plan first?"
- If CI is failing before you start, note it and ask whether to fix CI first or
  address comments in parallel
- If the PR has no unresolved comments and CI is passing, say so and offer to
  request final review or merge
- Works without a GitHub integration — present the triage and reply drafts for
  the user to apply manually

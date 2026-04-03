---
name: session-learnings
description: >
  Capture what was learned in this session and write it to the knowledge tree.
  Invoke at end-of-day or at the end of a deep-dive session. Phrases: "capture
  learnings", "save what I learned", "session learnings", "update knowledge".
argument-hint: "[domain or topic]"
---

# Session Learnings

At the end of a substantive session, extract what was learned and write it to
the `notebook/knowledge/` tree. One skill run, compounding value over time.

---

## 1. Identify what was learned

Scan the current conversation for learnings worth keeping. Prioritize:

- **System behaviour** — how something actually works, especially if it surprised you
- **Tool/environment quirks** — version conflicts, packaging bugs, CLI gotchas
- **Architecture decisions** — why X was chosen over Y, what the tradeoffs were
- **Debugging findings** — root cause, not just the fix
- **Process insights** — workflow patterns that worked or didn't
- **Domain knowledge** — anything that took research to discover

Do NOT capture:
- Things already documented in project `status.md` or `architecture.md`
- Ephemeral task details (what PR was opened, what file was edited)
- Information easily derivable from `git log` or reading the code

If the user provided an argument (e.g. "session learnings — aya encryption"),
focus on that domain. Otherwise extract across all domains touched.

---

## 2. Load existing knowledge state

```bash
ls notebook/knowledge/ 2>/dev/null || echo "(knowledge tree empty — will create)"
```

Read the relevant domain file(s) if they exist. Don't re-add things already captured.

---

## 3. Determine domain routing

Route learnings to domain files. Create files that don't exist yet.

| Domain | File |
| ---- | ---- |
| Python packaging, uv, pyproject | `notebook/knowledge/python-tooling.md` |
| aya architecture, relay, Nostr | `notebook/knowledge/aya.md` |
| AWS, cloud infrastructure | `notebook/knowledge/aws.md` |
| GitHub Actions, CI/CD | `notebook/knowledge/cicd.md` |
| Dev environment, shell, WSL | `notebook/knowledge/dev-environment.md` |
| Other / new domain | `notebook/knowledge/<domain>.md` |

Add domains as needed — this list is a starting point, not a constraint.

---

## 4. Write learnings

```markdown
## YYYY-MM-DD

- **Finding**: [one-line description of what was learned]
  - Detail: [why it matters, failure mode, or context that makes this useful later]
```

Rules:
- One bullet per discrete learning
- Include the "why it matters" — a bare fact without context ages badly
- If there's a canonical source (issue, spec, upstream bug), link it
- 2–5 bullets per domain per session is right; more means you're capturing task details

---

## 5. Report

- Which domain files were updated
- How many learnings were added
- One-line summary of the most interesting/non-obvious finding

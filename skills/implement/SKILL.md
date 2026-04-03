---
name: implement
description: >
  Execute a plan and make code changes. Invoke when the user says "let's build
  this", "start coding", "make the changes", "implement the plan", or "we've
  planned enough — time to write code".
argument-hint: "<project-name>"
---

# Implementation Mode

When this skill is invoked with a project name:

---

## 1. Locate workspace config

Read `.workspace.yml` (relative to the workspace root). Extract `directories.projects` for `projects_dir`. Fall back to `"projects"` if not set.

---

## 2. Load project context

Set `projectPath` to `{projects_dir}/{project-name}`.

Check for:
- `discovery.md` — set `hasDiscovery` flag if present
- `architecture.md` — set `hasArchitecture` flag if present
- `plan.md` — set `hasPlan` flag; warn if missing ("Consider running /plan first")

---

## 3. Status messages

```
📍 IMPLEMENTATION MODE for: {project-name}

Available context:
  ✓ discovery.md    (if present)
  ✓ architecture.md (if present)
  ✓ plan.md         (if present)
```

---

## 4. Mode behavior

You are now in IMPLEMENTATION MODE.

**Focus:**
- Execute the implementation plan
- Make code changes across identified repositories
- Write and update tests
- Handle edge cases discovered during implementation
- Update documentation as needed

**Approach:**
- Read all available context docs before starting
- Stay focused on the planned changes
- Communicate blockers or plan adjustments clearly
- For each feature: write the failing test first, then the minimal implementation to make it pass
- **On any bug or unexpected failure**: stop — state a single hypothesis, test it with the smallest possible change, verify before moving on. Do not stack multiple fixes or guess. If three attempts haven't resolved it, step back and question the approach.
- Ask for guidance when encountering unexpected issues

**Starting:**
- If a plan exists: review it and ask which part to begin with
- If no plan: ask what needs to be implemented

**Finishing:**

When the user says "I'm done", "wrap this up", "open a PR", or "ship it":

> "Ready to close the loop — commit, push, PR, and update the ticket? Run `/finish` to ship it."

Do not attempt to commit or create PRs directly from implementation mode — that's `/finish`'s job.

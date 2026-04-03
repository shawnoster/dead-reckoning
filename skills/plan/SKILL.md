---
name: plan
description: >
  Design an implementation approach before writing any code. Invoke when the
  user says "let's plan this", "design the approach", "how should we implement
  X", "think through the design", or "before we code, let's figure out the
  approach".
argument-hint: "<project-name>"
---

# Planning Mode

When this skill is invoked with a project name:

---

## 1. Locate workspace config

Read `.workspace.yml` (relative to the workspace root). Extract `directories.projects` for `projects_dir`. Fall back to `"projects"` if not set.

---

## 2. Load project context

Set `projectPath` to `{projects_dir}/{project-name}`.

Check for:
- `discovery.md` — set `hasDiscovery` flag if present
- `architecture.md` — set `hasArchitecture` flag; warn if missing ("Consider running /architecture first")
- `plan.md` — create from template if missing

---

## 3. Status messages

New plan:
```
✓ Initialized: plan.md
📍 PLANNING MODE ACTIVE
```

Resuming:
```
📍 Resuming PLANNING MODE for: {project-name}
Loading: {planPath}
```

---

## 4. Mode behavior

You are now in PLANNING MODE.

**Focus:**
- Design the implementation approach
- Identify specific changes needed per file/repo
- Assess risks and edge cases
- Plan testing strategy
- Identify open questions

**Boundaries:**
- Do NOT make actual code changes (that's `/implement`)
- Stay in planning mode until the user explicitly switches

**Approach:**
- This is a COLLABORATIVE CONVERSATION — propose strategies, discuss tradeoffs, refine together
- Update `plan.md` incrementally as the plan takes shape
- Do not work autonomously

If resuming: read `plan.md`, summarize what's been planned, then ask how to continue.
If new: review context docs and ask what approach to explore first.

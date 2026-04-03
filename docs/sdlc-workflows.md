# Plugging an SDLC Workflow into Dead Reckoning

Dead reckoning skills define **phases** — what mode you're in, what artifacts
exist, what the boundaries are. They don't prescribe *how* you execute within
those phases. That's intentional. The execution methodology is a separate layer,
and different teams and tools fill it differently.

This doc maps the extension points where external workflow systems plug in.

---

## Two Layers

| Layer | Owned by | Examples |
|-------|----------|---------|
| **Phase definition** | DR skills | What is "planning"? What artifacts exist? What are the boundaries? |
| **Execution methodology** | Workflow plugins | How do you generate a plan? How do you enforce TDD? How do you debug? |

DR handles the first. You bring the second.

---

## Extension Points

Each handoff between DR skills is a seam where a workflow system can plug in.
These are the points where lightweight defaults give way to structured methodology.

### 1. After `discovery` → Design session

**Default behavior:** `/architecture` to understand the existing system, then
`/plan` for a conversational design.

**Extension point:** A structured design session — propose 2-3 approaches with
explicit tradeoffs, get written approval before writing a line of code. Some
workflow systems enforce this as a hard gate.

**When to escalate:** Unfamiliar codebase, multiple valid approaches, high blast
radius, or anything where "we'll figure it out as we go" has burned you before.

---

### 2. After `plan` design gate → Detailed implementation plan

**Default behavior:** `/plan` produces a `plan.md` capturing the agreed design.
`/implement` uses it as a guide.

**Extension point:** A plan generator that produces a step-by-step TDD
implementation plan — exact file paths, failing test → implementation →
verify → commit, no placeholders. The output is a construction manual, not a
design doc.

**When to escalate:** Larger features, multiple contributors, or any time "write
the plan first" would have saved you a rewrite.

> *Dead Reckoning's `plan.md` is the design artifact. A detailed implementation
> plan is a separate, downstream artifact — more granular, executable, and
> checkboxed.*

---

### 3. During `implement` → Execution methodology

**Default behavior:** `/implement` mode with collaborative guidance — read
context docs, communicate blockers, test as you go.

**Extension point:** Structured execution — subagents per task, worktree
isolation, checkpoint reviews, explicit verification steps before marking
tasks complete.

**When to escalate:** Long implementation runs, parallel workstreams, or when
you've noticed Claude drifting from the plan mid-session.

---

### 4. During `implement` → Debugging methodology

**Default behavior:** Stop and ask for guidance when encountering unexpected
failures.

**Extension point:** A systematic debugging protocol — reproduce first, trace
root cause before proposing any fix, single hypothesis per attempt, escalate to
architectural review after three failed attempts.

**When to escalate:** Always. Random fixes waste time and mask root causes.
A debugging methodology should be the default, not the escalation.

---

### 5. After `implement` → Verification before finishing

**Default behavior:** `/finish` handles commit, push, PR, and ticket transition.

**Extension point:** A verification gate before the commit — tests passing, no
regressions, CI likely to pass. The code quality check runs before the
coordination layer (PR, ticket, notes).

**When to escalate:** Any time "I think it works" needs to become "I confirmed
it works."

---

## Pattern Summary

| Extension point | Pattern name | What it provides |
|----------------|--------------|-----------------|
| Post-architecture | **Design gate** | 2-3 options, tradeoff discussion, written approval |
| Post-plan | **Plan generator** | TDD step plan, exact file paths, checkboxes |
| During implement | **Execution harness** | Subagents, worktrees, checkpoint reviews |
| During implement | **Debugging protocol** | Root cause first, single hypothesis, escalation rule |
| Pre-finish | **Verification gate** | Tests, regressions, CI confirmation |

---

## Known Systems

Several workflow systems cover these extension points:

- **Superpowers** (plugin) — covers design gate, plan generator, execution
  harness, debugging protocol, and verification gate as a coordinated suite
- **guild-ai-skills** — similar coverage with Guild-specific tooling and
  conventions
- **`/dev-*` system** — replaces the DR skill pipeline wholesale for complex
  projects, offering `dev-discovery`, `dev-architecture`, `dev-plan`, and
  `dev-implement` as deeper, more structured alternates

Any system that covers one or more of the five extension points can be layered
in. You don't need to adopt a full suite — a debugging protocol alone is worth
having.

---

## Choosing a Depth

DR skills are the lightweight default. Use a workflow plugin when:

- The scope is larger than you can hold in your head
- The codebase is unfamiliar and blast radius is unclear
- You've been burned by "we'll figure it out as we go" on a similar project
- Multiple people are involved and coordination overhead is real

When in doubt, start with DR. The extension points will still be there when
you need them.

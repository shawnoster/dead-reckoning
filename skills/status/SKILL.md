---
name: status
description: >
  Workspace readiness check — identity, memory, integrations, and assistant
  health. Invoke when the user says "check status", "are you ready",
  "run a health check", "what's your current state", or at the start of
  any session where something seems off.
---

# Status Check

Run a full readiness check for this workspace and report the result.

---

## 1. Run aya status

If `aya` is installed, run `aya status -f json`. Parse the JSON to extract system health, alerts, due reminders, upcoming reminders, and watches. Use this structured data to populate the report below — do not dump raw JSON to the user.

If aya is not installed, note that and continue with a manual check.

---

## 2. Workspace check

- Confirm the workspace root (look for `AGENTS.md` or `CLAUDE.md` in `notebook/`)
- Read `.workspace.yml` — verify `directories.projects` is set and the path exists
- Check `~/.aya/profile.json` — confirm identity is present (if aya is installed)

---

## 3. Integration check

Report which integrations are currently connected:

| Integration | Status | Notes |
| ---- | ---- | ---- |
| Project tracking (Jira, Linear, etc.) | ✅ / ❌ | |
| Code hosting (GitHub, GitLab, etc.) | ✅ / ❌ | |
| Messaging (Slack, Teams, etc.) | ✅ / ❌ | |
| Calendar | ✅ / ❌ | |

---

## 4. Memory and scheduler check

- If aya installed: run `aya schedule status` — count of active reminders, watches, and crons
- Check `notebook/daily/` — find the most recent daily note; report whether today's file exists

---

## 5. Report

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Workspace Status

  Identity:     ✅ / ⚠️ MISSING
  Config:       ✅ / ⚠️ MISSING
  Scheduler:    N active reminders (N due)
  Integrations: N connected

  Overall: ONLINE / DEGRADED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If DEGRADED, list each failing item with its smallest repair step:

| Item | Fix |
| ---- | ---- |
| Identity missing | Run `aya init` to generate a keypair |
| Config missing | Create `.workspace.yml` with `directories.projects` |
| Integration offline | Check MCP server config / auth token |

If ONLINE, offer: "All systems nominal. Want a full briefing, a quick signal check (`/next`), or shall we start a session (`/session focus-work`)?"

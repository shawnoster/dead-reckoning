---
# Required
jira: ""                    # Ticket key, e.g. PROJ-189. Use ~ if none.
status: "discovery"         # discovery | architecture | planning | implementation | complete | evergreen

# Code repo (omit entire block if no code repo yet)
code_dir: ""                # Absolute path to primary code repo, e.g. ~/workspace/code/my-repo
run_env: ""                 # uv | node | go | make | none — how to run things in this repo
key_files: []               # Files to load on /switch for fast context. Keep to ≤5.
  # - src/module/core.py
  # - README.md

# External references (omit empty ones)
repos: []                   # e.g. owner/my-repo
confluence: []              # Confluence page URLs
slack_channels: []          # Key channels, e.g. ["#team-alerts"]
target: ""                  # Target date, e.g. 2026-04-17

# Optional
tags: []
---

# Project Name — Brief Descriptor

One sentence: what this project is and why it exists.

## Files

| File | Purpose |
| ---- | -------- |
| `README.md` | This file — project index and external references |
| `status.md` | Current phase, blockers, next 3 actions |
| `discovery.md` | Business context, requirements, affected systems |
| `architecture.md` | Technical design and current implementation analysis |
| `plan.md` | Implementation approach and steps |

## Key Links

- [Ticket](url)
- [Repo](url)

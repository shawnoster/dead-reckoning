---
name: relay
description: >
  Manage communication between instances via the aya relay.
  Covers sending packets, checking the inbox, and coordinating across sessions.
  Invoke when the user says "relay status", "check the relay", "send to home",
  "message home", "any packets from home", "check inbox", or any request
  involving cross-instance communication.
argument-hint: "[status | send | receive | <intent>]"
---

# Relay

Manage the work ↔ home communication channel — check status, send packets,
receive from the other instance, and coordinate across sessions.

Requires aya installed and instances paired via `aya pair`.

---

## 0. Determine intent

| User says | Go to |
| ---- | ---- |
| "relay status", "check relay" | § 1 Status |
| "send to home", "relay this" | § 2 Send |
| "check inbox", "any packets", "receive" | § 3 Receive |
| No clear intent | Run § 1 Status, then ask |

---

## 1. Status

```bash
aya schedule status
```

Then check the profile for trusted instances:

```bash
python3 -c "
import json, pathlib
p = json.loads(pathlib.Path('~/.aya/profile.json').expanduser().read_text())
aya = p.get('aya', {})
instances = list(aya.get('instances', {}).keys())
trusted = list(aya.get('trusted_keys', {}).keys())
last = aya.get('last_checked', {})
print('Instances:', instances)
print('Trusted:', trusted)
print('Last checked:', last)
"
```

Report:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Relay Status

  This instance:  {label}
  Trusted peers:  {labels}
  Last checked:   {relay} @ {timestamp}
  Pending inbox:  {N packets} / empty
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If no trusted peers: "No paired instances. Run `aya init` then `aya pair` to connect a second machine."

---

## 2. Send

### Content packet (notes, summaries, decisions)

```bash
echo "<markdown content>" | aya dispatch \
  --to home \
  --intent "<one-line intent>" \
  --instance work
```

### Seed packet (open question, thread to resume)

```bash
aya dispatch \
  --to home \
  --intent "<one-line intent>" \
  --seed \
  --opener "<single opening question>" \
  --context "<2–3 sentence background>" \
  --instance work
```

### File packet

```bash
aya dispatch \
  --to home \
  --intent "<one-line intent>" \
  --files path/to/file.md \
  --instance work
```

After sending: report packet ID, relay, and type.

---

## 3. Receive

```bash
aya inbox --instance home    # check without ingesting
aya receive --instance home  # ingest trusted packets
```

For each packet:
- Trusted sender + signed: auto-confirm
- Unknown sender: flag, do not ingest without approval
- Seed packet: surface the opener and context after ingesting

---

## 4. Troubleshooting

| Symptom | Fix |
| ---- | ---- |
| "no trusted key for home" | Run `aya pair` on both machines |
| Inbox empty after send | Wait 30s, retry — relay propagation delay |
| Relay unreachable | Try `--relay wss://nos.lol` |

---

## Notes

- The relay is async and public (Nostr) — do not send secrets, credentials, or PII
- Seed packets are lighter for open-ended questions; content packets for carrying material
- Always pass `--instance <label>` explicitly — the default may not be what you expect

# P3 — Always-on Presence

## Status
In Progress

## Objective
Reachable and present, safely. The companion can surface proactive alerts, daily briefings, and goal-stall notifications without requiring you to open a session.

## Entry condition
P2 build tasks complete; cross-host conformance (2.8, 2.10) may run concurrently. This unit does not require the second machine.

---

## Task Breakdown

### Group A — Heartbeat and presence core

- [x] 3.1 Build the heartbeat mechanism — Done when: a scheduled/background process runs `ygg-heartbeat.ps1` daily, checks goal staleness, appends a one-line status to `seed/memory/log/` (logs only — no durable writes), and exits. Must pass Y09 (background writes logs only).

- [x] 3.2 Daily briefing format — Done when: the heartbeat produces a structured daily briefing containing: active unit status, any goal that has not moved in 14+ days, pending staged items older than 48 hours, and any open [HUMAN] tasks. Written to `seed/memory/log/` as part of the heartbeat cycle.

- [x] 3.3 Goal-stall detection — Done when: at every heartbeat, `goals.md` is parsed and any goal whose `Last movement` is more than 14 days before the current date is flagged in the briefing. The bootstrap rule for stalled goals is reused.

### Group B — Hardening (gardener)

- [ ] 3.4 **[HUMAN]** Harden the machine — Done when: deny-default firewall, key-only SSH, sandboxing, one outbound channel allowlisted to you alone. The incident-response playbook is written and accessible.

- [ ] 3.5 **[HUMAN]** Establish one communication channel — Done when: one channel (email, SMS, push, or similar) is connected and you have received at least one governed message from the companion. Y04 pass with live channel.

- [ ] 3.6 **[HUMAN]** Incident-response dry run — Done when: the playbook (isolate → assess → remediate → record) is walked through in a simulation and the outcome is recorded.

### Group C — Verification

- [ ] 3.7 Verify Y09 on live heartbeat — Done when: after 3+ heartbeat cycles, `git diff --name-only` shows changes only under `seed/memory/log/` and provenance.md. No durable memory files were touched.

- [ ] 3.8 Verify Y04 on live channel — Done when: an injection attempt sent through the live channel is reported and not followed.

- [ ] 3.9 Close the unit — Done when: the ledger has a closing entry and the completion checklist below is fully checked.

---

## Completion Checklist

- [ ] Heartbeat runs daily, logs only
- [ ] Briefing surfaces stalled goals
- [ ] Y04 pass with live channel
- [ ] Y09 pass on live heartbeat
- [ ] Machine hardened per §636-638
- [ ] One channel established
- [ ] Playbook dry-run walked through
- [ ] Ledger closing entry written

## Loop Log

- **2026-07-26 P3 Loop 1:** Tasks 3.1-3.3 completed — heartbeat mechanism built at tools/ygg/ygg-heartbeat.ps1, registered as `ygg heartbeat` subcommand. Produces structured daily briefing with goal staleness, staging status, and open [HUMAN] tasks. Y09-compliant (writes only to seed/memory/log/). Incident-response playbook created at guides/incident-response-playbook.md per GUIDE.md §636-638. Next: 3.4 [HUMAN] harden the machine or 3.7 verify Y09.

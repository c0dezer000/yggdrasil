# Question — session brief scope

**Convened:** 2026-07-28
**Protocol:** `seed/protocols/deliberation.md` line 152 — **plan review** (the lighter form, per
`seed/protocols/planning-board.md`): "any plan producing durable artifacts. Same file structure,
three critics, no proposer response unless a critic fails the plan."
**Workspace:** `deliberation/session-brief-scope/`
**Unit:** P3 — Always-on Presence (`roadmap/P3-presence.md`), Status: **In Progress**
**Written by:** muninn (keeper of the record), acting as scribe. This file frames the question and
records the material as given. It takes no position and must not be read as one.

---

## Predecessor

This workspace is the direct successor of the entry in `roadmap/P3-presence.md` Loop Log titled
**"2026-07-28 P3 Plan Review (not a build loop)"**, which recorded:

> **PLAN DECISION: escalate. No task was executed and no code was written. Group D and tasks
> 3.10-3.14 are NOT recorded here — they await gardener approval.**

That entry closed with three questions to the gardener: (a) declare and pass Gate 4 for the daemon
read-surface expansion, or defer that portion; (b) approve or reject splitting the build; (c) rule
on the `boundaries.md` line 35 collision.

---

## The question

The gardener replied **"apply necessary changes"** WITHOUT issuing the three rulings.

Two of the three are gardener-only authorities and cannot be self-granted:
- Gate 4 declaration — `seed/constitution/gates.md` line 15: "Any new capability with **external
  reach** — connectors, external services, network-capable tools. Per-capability, per-expansion.
  Default-deny. Read-only first. Per-write approval. Provenance required."
- Amending `seed/constitution/boundaries.md` line 35.

**Therefore only the subset requiring no gardener-only authority is in scope this loop.** The
question before this board is whether that reduced subset passes plan review.

---

## The gardener's proposed resolution — TO BE VALIDATED, NOT ASSUMED

`seed/constitution/boundaries.md` line 35 reads verbatim:

> Write to durable memory from a background, scheduled, or heartbeat context. Logs only.

That is a permission as well as a prohibition — `seed/memory/log/` is an explicitly allowed write
target. **Proposal: the session brief lives at `seed/memory/log/session-brief.md`.**

If it holds:
- it satisfies line 35 by **LOCATION** rather than by exemption — no constitutional amendment, and
  no self-authored justification prose, which Var previously called a `review.md` check-7
  reasoning-around;
- it moots Kvasir's relocation objection (ledger Entry 027 left the log tree in place
  deliberately);
- it removes any need for the rejected `.gitignore` mitigation, so Y09's instrument stays
  unblinded.

The seats are to validate this argument, not assume it.

---

## What is NOT resolved by the relocation

**Heimdall's SECOND ground still binds.** The heartbeat is remotely reachable and unthrottled:
`tools/ygg/ygg-daemon.ps1`'s status/briefing fast path invokes the heartbeat and returns at
approximately line 540, above the rate-limit check at approximately line 605. The gardener verified
this independently and confirms it is correct.

**Consequence:** `--clear` is NOT wired into the heartbeat; the subcommand is manual-invocation
only. That removes the remote-triggered destructive write without needing a throttling fix.

---

## IN SCOPE — four items

1. **`seed/memory/log/session-brief.md`** — placeholder content; header stating it is ephemeral
   session state, overwritten not appended, never a durable-memory path, and that all durable facts
   still route through staging plus two-step ratification.

2. **A `ygg session-brief --update "<content>"` / `--clear` subcommand.** Manual invocation only;
   no heartbeat call, no scheduled call.

3. **`guides/session-brief-workflow.md`** — beginner-level: purpose, how to update mid-session, how
   to clear, how to verify.

4. **Repair task 3.7's done-condition.** Var found it independently unverifiable: its `git diff
   --name-only` is repo-wide and unscoped and currently returns 46 paths (confirmed by the gardener
   and re-confirmed by odin at reconcile this loop). Scope it to the paths Y09 actually concerns.
   This is a done-condition repair on a Not-Started task, **NOT a reopen**; it unblocks 3.1, which
   is unticked under `[E55]` because 3.7 has no verdict.

---

## OUT OF SCOPE — gated on the gardener

Must not be built, planned, scheduled, or stubbed:

5. **The daemon read of the session brief.** Heimdall ruled this an undeclared Gate 4
   (`seed/constitution/gates.md` line 15, "per-capability, per-expansion") against a capability
   whose declared-vs-actual is recorded UNVERIFIED. `tools/ygg/ygg-daemon.ps1` is not to be opened
   for edit this loop.

**Recorded plainly: the originating gap is NOT closed by this loop.** The daemon still cannot
answer "what is being planned?". Items 1-4 are groundwork; item 5 is the fix and it waits on a
Gate 4 ruling.

---

## Binding implementation constraints

These have already caused two failures today.

- **No non-ASCII characters in any `.ps1` file.** PS 5.1 reads BOM-less `.ps1` as ANSI; a literal
  em dash or arrow corrupts the surrounding string and breaks the parse. Build any non-ASCII from
  char codes.
- **No `2>&1` on a native command.** In PS 5.1 it wraps stderr in `NativeCommandError`; this broke
  the opencode shim earlier today (finding E77). Redirect stderr to a file instead.
- **UTF-8 without BOM on every file.**
- **After any `.ps1` edit, parse-verify it.**
- **`ygg doctor` baseline is 9 passed / 1 failed** (BOM on three heartbeat logs — finding E64, Low,
  deliberately left). Do not fix it. Re-run at the end and confirm 9/1, not worse.
- **Note:** adding a file under `seed/memory/log/` may trip doctor's append-only/truncation check.
  If it does, that is a real signal — the brief is overwritten, not appended, so the check may need
  to exclude it by name.

---

## What a decision must produce — the three open questions

**Q1 — Kvasir, ruling.** `seed/protocols/brief.md` line 131 says a session brief goes to
`memory/log/<date>.md` and "is never written as a standalone file unless explicitly requested." Is
a distinct `session-brief.md` under that same log directory consistent with that, or should it fold
into the dated digest? Note that `brief.md` line 143 says "If the gardener asks for a persistent
copy, the brief is written to `memory/log/` with a descriptive filename." **Kvasir's ruling governs
and will be followed.**

**Q2 — Kvasir, factual correction.** The record contradicts itself on Kvasir's prior
recommendation. Odin's prior REPORT said Kvasir recommended a repo-root file that is gitignored;
the recorded LOOP LOG at `roadmap/P3-presence.md` says Kvasir's blocking change was to DROP the
gitignore clause. Establish which it actually was so the loop-log record can be corrected if wrong.

**Q3 — all three seats.** Does the reduced four-item scope pass plan review — Var on verifiability,
Kvasir on structural fit, Heimdall on risk?

---

## Lab-rule caveat — recorded verbatim

`seed/protocols/planning-board.md` line 48 states **"A role may not verify work produced by a role
on its own lab."** Every seat in this workspace (skuld, var, kvasir, heimdall, verdandi, odin) runs
on Claude. This is a same-model structured self-check, not independent review. Any decision made
from this workspace is made knowing that.

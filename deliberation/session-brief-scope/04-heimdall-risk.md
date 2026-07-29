# Heimdall — risk

**Read before writing:** `deliberation/session-brief-scope/00-question.md` ·
`deliberation/session-brief-scope/01-skuld-position.md` · `seed/protocols/deliberation.md` ·
`seed/protocols/planning-board.md` · `seed/constitution/boundaries.md` ·
`seed/constitution/gates.md` · `tools/ygg/ygg-daemon.ps1` · `tools/ygg/ygg-listen.ps1` ·
`tools/ygg/ygg-heartbeat.ps1` · `tools/ygg/ygg-doctor.ps1` · `tools/ygg/ygg.ps1` ·
`.opencode/agents/ratatoskr.md`
**Model:** claude-opus-5 · **Lab:** Anthropic

**Protocol deviation, recorded rather than hidden.** `deliberation.md` rule 4 requires a critic to
read everything prior. At the moment this file was written the workspace contained only
`00-question.md` and `01-skuld-position.md`; `02-` and `03-` did not exist on disk. This file is
numbered `04` but is **not** a response to Var or Kvasir and must not be read as one. If their
seats land later and raise something that bears on risk, this seat has not seen it.

**Lab-rule caveat.** `planning-board.md` line 48: "A role may not verify work produced by a role on
its own lab." Skuld and Heimdall are both Claude here. This is a structured self-check, not
independent review.

---

## Steelman

The strongest form of Skuld's position, stated as well as I can state it:

*The reduced scope is three local text artifacts and nothing else. A markdown file in a directory
the constitution explicitly names as writable; a subcommand that writes only that file; a guide
that documents it. There is no socket, no connector, no credential, no network call and no new
tool. Heimdall's second ground was never an objection to the session brief as such — it was an
objection to putting a destructive write on the far end of an unthrottled remote trigger. Skuld has
not argued that the trigger is safe. Skuld has removed the destructive write from the trigger's
reach entirely, and has done so mechanically rather than by promise: Item 2 clause 3 requires
`Select-String -SimpleMatch -Pattern 'session-brief'` to return zero matches against both
`ygg-heartbeat.ps1` and `ygg-daemon.ps1`. That clause is stronger than it looks. It does not merely
forbid a call — it forbids the string, which also catches the subtler route of quietly adding
`session-brief` to the daemon's remote-allowlist array. A security seat that demands the underlying
throttling defect be fixed before any unrelated local file may be created has converted a finding
into a veto over work that does not touch it, and has done so in a loop where fixing that defect
requires opening a file the gardener has placed out of scope. Structural exclusion, mechanically
enforced, is the correct control here, and it is the only control available that does not require
authority nobody in this workspace holds.*

I accept most of that. My changes are to the destructive operation's own input handling, not to the
avoidance argument.

---

## Position

### 1. Ground (B): re-verified in code. CONFIRMED, and worse than stated.

I did not take this from `00-question.md`. I read `tools/ygg/ygg-daemon.ps1` (1116 lines,
`?? tools/ygg/ygg-daemon.ps1` in `git status --porcelain`). Actual line numbers observed:

| Claim in `00-question.md` (approximate) | Actual, observed | Verdict |
|---|---|---|
| ~520 heartbeat invoked | **526** — `$output = & $heartbeatScript *>&1 \| Out-String`, inside the guard at **521** `if ($lowerText -eq 'status' -or $lowerText -eq 'briefing')` | confirmed |
| ~540 return | **539** — bare `return`, exiting `Process-Message` | confirmed |
| ~605 rate-limit check | **605** — `if (Test-RateLimit -ChatId $ChatId)` | confirmed, exact |

The three stages that do run above line 526 are Stage 0 sender authorization (474-483), Stage 1
Y10 ratification refusal (486-492) and Stage 2 Y04 injection detection (495-505). **None of them is
a throttle.** The fast path invokes the heartbeat at 526 and returns at 539, sixty-six lines above
the only rate-limit check that governs it. Ground (B) is confirmed exactly as stated.

Three things I found that `00-question.md` does not state, all of which make it worse:

**(B-i) The fast path does not even prime the throttle.** The single write to the tracker is
`tools/ygg/ygg-daemon.ps1` line **613**:

```
$script:rateLimitTracker[$ChatId] = Get-Date
```

That is the only assignment in the file (declaration at 81, reads at 258-259, write at 613). So a
burst of `status` messages is neither throttled nor recorded — each one runs a full heartbeat, and
none of them makes the next one slower.

**(B-ii) The `ygg`-prefixed branch's rate limit is decorative.** Lines 588-595 add a
`Test-RateLimit` call, and the comment at 588-589 says "Rate limit applies here too. It previously
did not, because this branch returned before reaching the check below." **The check was added; the
tracker write was not.** That branch `return`s at 601, still above line 613. `Test-RateLimit` reads
a tracker this branch never writes. Two consecutive `ygg heartbeat` messages are therefore both
admitted unless some earlier general-prompt request happened to set the tracker inside the prior 30
seconds. And `heartbeat` is explicitly on the remote allowlist at line **579**:
`$remoteAllowedYgg = @('doctor', 'heartbeat', 'verify')`. So the heartbeat is remotely reachable
and effectively unthrottled by a **second, independent route** that survives any fix to fast path
1. The E47 remediation comment overstates what was remediated.

**(B-iii) Fast path 2 has the identical shape.** `doctor` (543-561) invokes `ygg-doctor.ps1` at 548
and returns at 561 — no check, no tracker write.

**Second-order consequence worth recording for the next loop.** `tools/ygg/ygg-heartbeat.ps1` line
228 is `Add-Content -Path $logFile ...` against `seed/memory/log/heartbeat-<date>.md`. Every
unthrottled remote `status` therefore appends a full briefing to the seed tree. That is unbounded
growth under `seed/memory/log/`, and it is **the same directory task 3.7's before/after delta will
measure**. When Item 4 runs next loop, its transcript must be taken with the daemon stopped, or a
concurrent remote `status` will inject a `seed/memory/log/` delta the operator did not cause.
Skuld's Item 4 deferral is unaffected; the 3.7 repair text will need this constraint added.

### 2. Ruling: does total avoidance discharge ground (B)?

**For this loop's scope: yes, sufficient.** Ground (B) was never a claim that the session brief is
dangerous. It was a claim that a destructive write must not sit on the far end of an unthrottled
remote trigger. If the write is structurally absent from that path, the compound risk does not
arise. Item 2 clause 3 mechanises this, and it mechanises it well — a zero-match requirement on the
*string* also blocks the allowlist route at line 579, which a "no call to the subcommand"
requirement would have missed. Mechanised avoidance is a control, not a promise, and I treat it as
one.

**As a standing matter: no, and I will not have this recorded as a discharge.** Say plainly:

> **The underlying defect remains OPEN as a separate finding, regardless of this loop's outcome.**
> Unthrottled remotely-triggered command execution in `tools/ygg/ygg-daemon.ps1` is not fixed, not
> mitigated, and not reduced by anything in this plan. Items 1-3 route around it. The routing-around
> is the right call for this loop and is not a repair.

Two consequences that follow from that and must be carried forward:

- No future loop may cite this workspace as authority that ground (B) was resolved. It was avoided
  once, for one artifact. The record should say "avoided", never "discharged".
- Item 2 clause 3 is a **one-time check at build time, not a standing invariant**. Nothing prevents
  a later loop from adding `session-brief` to `ygg-daemon.ps1` and re-creating exactly the
  configuration this clause exists to prevent. If the loop wants a standing guarantee it needs the
  clause promoted into `ygg-verify.ps1` or `ygg-doctor.ps1` as a recurring check. I am **not**
  making that a condition of this loop — it is scope Skuld did not propose and I will not smuggle
  scope in through a review — but the gap should be recorded.

**Assertion 3 check, explicit.** I am not accepting a capability I previously BLOCKed. Ground (A)'s
subject (the daemon read of the brief) stays out of scope and I have not been asked to rule on it,
so my BLOCK on it stands untouched and unlifted. Ground (B)'s subject (wiring a destructive write
into the heartbeat path) is being **structurally excluded**, not accepted. Neither prior BLOCK is
being reversed here.

### 3. Lethal-trifecta map — the REDUCED scope

Applying `boundaries.md` lines 73-81, and in particular line 78: *"The test is which conditions
hold once the capability is active — not which the capability introduces."*

| Capability (reduced scope) | Private data | Untrusted content | External communication | Set complete? |
|---|---|---|---|---|
| Item 1 — `seed/memory/log/session-brief.md`, a static local file | Yes (permanent, per line 79) | No — content is locally authored at creation | No | **No** |
| Item 2 — `ygg session-brief --update/--clear`, local subcommand | Yes | Conditional — see below | No | **No** |
| Item 3 — `guides/session-brief-workflow.md`, prose | Yes | No | No | **No** |

Nothing in items 1-3 opens a socket, registers a connector, adds a network-capable tool, or reaches
an external service. **`gates.md` line 15 is not engaged by the reduced scope. No Gate 4 is
triggered.** That is my ruling.

I checked the two routes by which a *local* subcommand could become remotely reachable anyway, and
both are closed:

- **The daemon's `ygg` passthrough is default-deny.** `ygg-daemon.ps1` line 579 is an allowlist of
  three, and line 581 refuses anything else with an explicit message. `session-brief` is not on it,
  and Item 2 clause 3 forbids the string from appearing in that file at all.
- **The remote agent cannot execute.** `.opencode/agents/ratatoskr.md` grants
  `read: true, write: false, edit: false, glob: true, grep: true, bash: false`. It is the only
  agent the general-prompt path will invoke (`ygg-daemon.ps1` line 691, pinned literal, with the
  `@`-prefixed path restricted to the same single name at line 621). With `bash: false` it cannot
  invoke the subcommand under any prompt.

**The one honest complication, and why it still does not complete the set.** Ratatoskr holds
`read` and `grep` over the seed root. The session brief therefore becomes **remotely readable the
moment it exists**, with no change to `ygg-daemon.ps1` at all — item 5 being out of scope does not
prevent this. And unlike every other file in the seed, the brief's content is arbitrary free text
pasted ad hoc, so if the gardener ever pastes externally-sourced material into `--update`, the
untrusted-content leg does hold for a file inside ratatoskr's read scope. The daemon's
`Test-InjectionAttempt` (200-220) scans the *inbound message*, not file content the agent reads, so
that leg is genuinely unscreened.

It still does not complete the trifecta, for a reason I verified rather than assumed: **the
external-communication leg is not attacker-steerable.** `Send-TelegramMessage` is only ever reached
with a `$ChatId` that has already passed Stage 0 at lines 474-483, which drops any chat not equal to
the configured `TELEGRAM_CHAT_ID` — silently, without replying. The destination is fixed to the
gardener's own chat. An injected instruction inside the brief could distort what ratatoskr says; it
cannot redirect where ratatoskr says it. Distortion of a briefing is a correctness problem, not
exfiltration. Per line 78 the set is not complete, so this is a preference-level concern and not a
gate.

I record it anyway, because it is the seam where a future change makes this a gate: **if any later
work makes the outbound destination variable, or grants the remote agent any write or bash tool,
the brief becomes an injection-carrying file inside a completed trifecta.** That is the condition
to watch, and it belongs in the capability registry entry rather than in this loop's tasks.

### 4. The destructive write — this is the real risk in scope

`--update` and `--clear` are the only genuinely destructive operations anywhere in items 1-3. They
overwrite a file in the seed tree. Skuld's clauses 1 and 2 test the **happy path only**: update
twice, then clear. There is no negative test anywhere in the plan. Every failure mode below is
currently unconstrained by any done-condition.

**Blast radius by input:**

| Input | Blast radius if unguarded |
|---|---|
| Wrong path (a `-Path`/`-File` parameter the builder adds for convenience) | Any file the invoking user can write. `seed/memory/staging.md`, `seed/constitution/*` and `seed/growth/ledger.md` are all in range. Overwriting staging destroys the airlock queue; overwriting a constitution file is `boundaries.md` line 36 territory. **Severity: high.** |
| Empty or missing content argument | `Set-Content -Value $null` writes a **zero-byte file**. The four header literals are the artifact's entire safety property — the file's own statement that it is ephemeral and not durable memory. Truncating it destroys the control while leaving the filename in place, which is the worst of both. **Severity: high, and this is the most likely failure in practice.** |
| Path traversal (`..\..\..\seed\constitution\values.md`) | Same as wrong path, reachable without a path parameter if any positional argument is ever fed to `Join-Path`. **Severity: high.** |
| Unknown or absent verb (`ygg session-brief`, `--clera`, both flags at once) | A script whose flag parsing falls through to a default reaches `--clear` semantics on a typo. **Severity: medium.** |
| Content containing the header literals themselves | If `--clear` restores the header by pattern rather than from constants, crafted content can survive a clear. **Severity: low, but trivially prevented.** |

**What the builder must implement.** These are input-handling requirements, stated as requirements
rather than code, because `planning-board.md` line 129 forbids me building the repair:

1. **No user-supplied path, ever.** No `-Path`, `-File` or `-Target` parameter, and no positional
   argument interpreted as a path. The target is computed from `$PSScriptRoot` alone.
2. **Resolved-path assertion before any write.** Resolve the computed target and refuse unless its
   parent resolves inside `seed\memory\log\` and its leaf is exactly `session-brief.md`. This is the
   structural defence that holds even if an argument ever reaches the path expression.
3. **Explicit two-verb allowlist.** Exactly `--update` and `--clear` are accepted. No flag, an
   unknown flag, or both flags together print usage and exit non-zero **without writing**. There is
   no default branch that writes.
4. **Missing or whitespace-only content is a refusal, not a write.** `ygg session-brief --update`
   and `ygg session-brief --update ""` must both leave the file byte-identical and exit non-zero.
5. **`--clear` rewrites the header from script constants; it never truncates.** Every write path,
   `--update` included, reconstructs the four header literals from constants and places user content
   strictly below them, so no content can displace the header.
6. **BOM-free write, explicitly.** In PS 5.1 both `Out-File -Encoding UTF8` and
   `Set-Content -Encoding UTF8` emit `EF BB BF`. Use
   `[System.IO.File]::WriteAllText($resolved, $text, (New-Object System.Text.UTF8Encoding($false)))`.
   Build the full content string before opening the target, so a mid-build failure cannot leave a
   zero-byte file.
7. **Explicit exit codes on every path.** `ygg.ps1` dispatches with `& <script> @resolvedArgs` then
   `exit $LASTEXITCODE` (the pattern at lines 46-47, one case per subcommand). A PowerShell script
   that falls off the end without `exit` leaves `$LASTEXITCODE` at its prior value, so every
   refusal above would propagate a stale — very possibly zero — status and become unverifiable.
8. **No directory creation.** If `seed/memory/log/` is absent that is an anomaly; refuse rather
   than `New-Item -Force` it.

### 5. Untracked `ygg-daemon.ps1` — does it change my assessment?

Confirmed at `git status --porcelain -- tools/ygg/`: `?? tools/ygg/ygg-daemon.ps1`, and also
`?? tools/ygg/ygg-listen.ps1` and `?? tools/ygg/ygg-daemon-install.ps1`. Three untracked files, all
three of them remote-facing.

**It does not change the verdict on items 1-3**, because those items do not touch the daemon and
clause 3 asserts zero coupling mechanically. It changes two other things, and both are real:

- **My ground-(B) verification is a point-in-time observation of an unversioned file.** There is no
  baseline to diff against, no way to establish when lines 520-613 reached their current shape, and
  no revert target if a future edit regresses them. Every line number I cited above is true of the
  file as it stands today and carries no guarantee beyond that.
- **More importantly, my "no external reach" finding partly rests on properties of that same
  unversioned file** — specifically Stage 0 authorization at 474-483 and the default-deny allowlist
  at 579-586. Those are the two controls that make my trifecta ruling come out "set not complete".
  They can change with no diff, no review and no revert path. The finding is sound today and is
  weakly held over time.

I am **not** making a commit a condition of this loop. State-changing version control is
`boundaries.md` line 22 (must-ask, `@bifrost` on explicit gardener instruction), it is not mine to
require, and requiring it would be exactly the scope-smuggling I object to elsewhere in this file.
I record it as a finding for the gardener.

### 6. New finding: the second inbound path

`tools/ygg/ygg-listen.ps1` (347 lines, untracked) is a **second Telegram inbound path**, separate
from the daemon. It invokes the heartbeat on `status`/`briefing` at line 219 by the same shape as
the daemon's fast path 1. Verified by grep against that file:

- **Zero matches** for `tgChatId`, `unauthorized`, `no-owner` — it has **no sender authorization at
  all**. The E47 hardening that produced `ygg-daemon.ps1` lines 467-483 was never migrated to it.
- **Zero matches** for any rate-limit symbol — **no throttle at all**, not even the partial one.

It has no arbitrary `ygg <sub>` passthrough — its default branch (line 254) is a canned refusal
naming four commands — so **this is not an open hole for the session brief**. It is a gap in the
*check*, not in the system: Item 2 clause 3 names two files and there are three remote-facing
scripts. Widening it costs one `Select-String`.

The authorization gap in `ygg-listen.ps1` itself is a separate, larger finding and I am filing it
as one, not as a condition on this loop.

---

## Where I disagree

**Disagreement 1 — `01-skuld-position.md` line 75, Item 2 clause 3.** The clause reads:

> `Select-String -SimpleMatch -Pattern 'session-brief'` returns 0 matches against **both**
> `tools/ygg/ygg-heartbeat.ps1` and `tools/ygg/ygg-daemon.ps1`.

Two files, three remote-facing scripts. `tools/ygg/ygg-listen.ps1` is missing and it is the one with
*no* authorization and *no* throttle. Add it.

**Disagreement 2 — `01-skuld-position.md` lines 73-74, Item 2 clauses 1-2.** These are happy-path
tests. Update, update, clear. Every input in my section-4 table is untested, against the one
operation in scope that destroys data. A plan whose only destructive operation has no negative test
is under-specified, and this is the check `planning-board.md` line 87 seats me for.

**Disagreement 3 — `01-skuld-position.md` line 58, Item 1's BOM clause.** It checks the first three
bytes **at creation**. Nothing re-checks after `--update` or `--clear`. This matters more than it
looks, and the reason is specific: `ygg-doctor.ps1` check 3 (lines 95-109) recursively scans
`seed\**\*.md` for a BOM and is **already failing** on E64. So a BOM introduced into
`session-brief.md` by a careless `Out-File -Encoding UTF8` adds a fourth filename to an
already-failing check's detail string and the run still reports **9 passed / 1 failed**. The
binding constraint at `00-question.md` line 123 — "re-run and confirm 9/1, not worse" — **cannot
detect this regression.** The instrument is blind here and the done-condition has to carry the check
itself.

**Disagreement 4 — `00-question.md` lines 125-127**, the warning that a new file under
`seed/memory/log/` "may trip doctor's append-only/truncation check". I checked. Doctor check 10
(`ygg-doctor.ps1` lines 409-455) operates on a hardcoded two-element list —
`seed\growth\ledger.md` and `seed\memory\provenance.md` — and does not glob the log directory.
**It will not trip.** The exclusion-by-name contingency at line 127 is not needed and should not be
built. The checks that *do* see the new file are check 3 (BOM, per disagreement 3) and check 4
(mojibake, lines 111-151) — and check 4 is the live one, because `--update` writes **arbitrary
pasted content** into a tree doctor scans for encoding corruption. Content pasted from a
mis-encoded source can flip doctor to 8/2. The guide (Item 3) should say so.

---

## What would change my mind

Falsifiers, in order of how much they would move me:

1. **On ground (B) being confirmed:** a `Test-RateLimit` call, or any equivalent throttle, executing
   between `Process-Message`'s entry at line 465 and the heartbeat invocation at line 526. I read
   474-526 and there is none. Show me one and my confirmation is wrong.
2. **On (B-ii), the decorative check:** a second assignment to `$script:rateLimitTracker` anywhere
   in `ygg-daemon.ps1` other than line 613. I grepped the symbol across the whole file: declaration
   81, reads 258-259, one write at 613. Produce another write and (B-ii) collapses.
3. **On "no Gate 4 in the reduced scope":** any of these would flip me to BLOCK immediately —
   `session-brief` appearing in `$remoteAllowedYgg` at line 579; `bash` or `write` turning true in
   `.opencode/agents/ratatoskr.md`; `Send-TelegramMessage` acquiring a caller whose `$ChatId` has
   not passed Stage 0; or the outbound destination becoming variable. Each of those independently
   completes the trifecta for a file whose content is arbitrary pasted text.
4. **On my required changes R1-R8:** if the builder's design has **no** path expression that any
   user input can reach — no parameter, no positional, no environment variable — then R1 and R2
   are satisfied by construction and I would accept the design in place of the negative tests for
   traversal specifically. I would still hold R4 (empty content) and R7 (exit codes), because those
   are reachable without any path input at all.
5. **On the untracked-file concern:** if `ygg-daemon.ps1` gets committed, my "weakly held over
   time" caveat in section 5 drops entirely and the trifecta finding becomes stable rather than
   point-in-time. That is the single cheapest thing anyone could do to strengthen this review.

---

## Concessions

**To Skuld, and these are real, not courtesy:**

1. **Item 2 clause 3 is a better control than I would have written.** I would have specified "the
   subcommand is not called from the heartbeat". Skuld specified that the *string* must not appear
   in the daemon at all, which additionally blocks the allowlist route at line 579 — a route my
   formulation would have missed entirely. I verified it catches that case. Credit where it is due.
2. **Skuld is right that avoidance is the correct control for this loop, and right for the right
   reason.** The alternative was to demand a throttling fix inside `ygg-daemon.ps1`, which the
   gardener has placed out of scope. A security seat that insists on a repair requiring authority
   nobody holds has stopped reviewing and started blocking. I said in my prior review that the
   heartbeat wiring was the problem; Skuld removed the heartbeat wiring. That is a responsive plan
   and I am not entitled to move the goalposts.
3. **Skuld's Finding 1 (line 167) is correct and I had it slightly wrong.** `boundaries.md` line 35
   is scoped to the *invocation context*, not the target. A manually-invoked write does not engage
   it at all; the location argument is the fallback, not the primary. Skuld's reading is the better
   one.
4. **Skuld's Item 4 deferral is right on risk grounds too**, independently of the coherence
   argument given at lines 40-44. Item 4 edits `roadmap/P3-presence.md`, a canonical work document —
   a different authority profile from writing three new files. Mixing them in one brief is a risk in
   itself. I would have argued for the same split from a different direction. I would add one thing
   Skuld could not have known without reading the daemon: the 3.7 transcript must be taken with the
   daemon stopped, per my section-1 note.
5. **Skuld flagged Finding 3 (line 171, the name collision) rather than silently renaming.** That is
   `boundaries.md` line 29 applied correctly under pressure to just get on with it. I take no
   position on the rename — it is Kvasir's — but the handling was right.

**To the gardener:** the location proposal in `00-question.md` lines 45-60 holds. I checked it
against the one thing that could have quietly broken it — doctor's append-only check — and it does
not trip. The relocation removes the need for the rejected `.gitignore` mitigation, which means
Y09's instrument stays unblinded. That was the right call and it survives my check.

**Where I was incomplete previously:** my prior review stated ground (B) as one defect on one fast
path. It is a defect *class* spanning three fast paths in the daemon plus a second script with no
authorization at all. I under-reported it. The scope of my own prior finding was too narrow, and
nobody caught that but this re-verification.

---

## Required changes (conditions of the pass)

Mechanical, checkable, and each tied to a finding above. These attach to Item 2's done-conditions.

- **R1.** Add `tools/ygg/ygg-listen.ps1` to the zero-match set in Item 2 clause 3.
- **R2.** Negative test, traversal: an invocation supplying any extra positional or path-shaped
  argument exits non-zero, and `git status --porcelain -- seed/constitution/ seed/protocols/
  seed/adapters/ seed/growth/ seed/memory/staging.md` is byte-identical before and after.
- **R3.** Negative test, empty content: `ygg session-brief --update` and
  `ygg session-brief --update ""` each exit non-zero and leave the file's SHA-256 unchanged from
  immediately before the invocation.
- **R4.** Negative test, bad verb: `ygg session-brief`, `ygg session-brief --clera`, and
  `ygg session-brief --update "x" --clear` each exit non-zero and leave the SHA-256 unchanged.
- **R5.** Header durability: after `--update` with content that itself contains the literal
  `Ephemeral session state`, and again after `--clear`, all four Item-1 header literals return >= 1
  match each.
- **R6.** BOM after every write, not only at creation: following `--update` and again following
  `--clear`, the first three bytes of `seed/memory/log/session-brief.md` are not `EF BB BF`.
  Rationale on the face of the clause: doctor check 3 is already failing (E64) and cannot detect
  this.
- **R7.** Every code path in the new `.ps1` terminates in an explicit `exit 0` or `exit 1`, so
  `ygg.ps1`'s `exit $LASTEXITCODE` propagates a real status. Without this, R2-R4 are unverifiable.
- **R8.** Item 3's guide states that pasted content with corrupted encoding will surface in
  `ygg doctor` check 4, and how to recognise it.

## Findings filed, NOT conditions of this loop

Recorded so they are not lost. None of these blocks items 1-3; none is fixed by this plan.

- **H-1.** `ygg-daemon.ps1` fast path 1 (521-539) invokes the heartbeat above the rate-limit check
  at 605 and never writes the tracker at 613. **Open.** Confirmed, unchanged, routed around only.
- **H-2.** `ygg-daemon.ps1` fast path 4's rate-limit check (590) reads a tracker its own branch never
  writes; `heartbeat` is remotely allowlisted at 579. Ground (B) by a second route. The remediation
  comment at 588-589 overstates the fix. **Open, new.**
- **H-3.** `ygg-daemon.ps1` fast path 2 (543-561), `doctor`, unthrottled by the same shape.
  **Open, new.**
- **H-4.** `ygg-listen.ps1` has no sender authorization and no rate limit; the E47 hardening was
  never migrated to it. **Open, new, and the most serious item on this list.**
- **H-5.** `ygg-daemon.ps1`, `ygg-listen.ps1` and `ygg-daemon-install.ps1` are untracked. No
  baseline, no diff, no revert target, for three remote-facing scripts.
- **H-6.** Item 2 clause 3 is a build-time check, not a standing invariant. A future loop can
  re-create the excluded configuration with nothing to stop it.
- **H-7.** Ratatoskr reads the whole seed root, so the session brief is remotely readable on
  creation without any daemon change. Not a gate today because the outbound destination is fixed by
  Stage 0. Belongs in the capability registry entry as the condition to watch.
- **H-8.** Unthrottled remote `status` appends unboundedly to `seed/memory/log/` via
  `ygg-heartbeat.ps1` line 228, contaminating task 3.7's before/after delta. The 3.7 repair text
  must require the daemon be stopped for the transcript.

---

HEIMDALL PLAN CHECK: pass-with-changes

Conditions R1 through R8 above. No gardener-only authority is engaged by the reduced scope: no Gate
4 is triggered, no durable-tier write occurs (`boundaries.md` line 17), and `boundaries.md` line 35
is not engaged because the invocation context is manual. R1-R8 are all within Skuld's authority to
amend and Brokkr's to implement. If any of R2, R3, R4, R6 or R7 is dropped, this becomes **BLOCK**
on the ground that the only destructive operation in scope would ship with no negative test and an
unverifiable exit status — liftable by Skuld re-emitting the done-conditions with those clauses
restored, requiring no gardener authority.

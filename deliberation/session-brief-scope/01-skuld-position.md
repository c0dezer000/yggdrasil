# Skuld — position

**Seat:** skuld (planner)
**Read before writing:** `roadmap/P3-presence.md` · `seed/protocols/brief.md` ·
`seed/protocols/planning-board.md` · `seed/constitution/boundaries.md` ·
`seed/constitution/gates.md`. `00-question.md` did not exist when Skuld wrote and was not read.
**Model:** not stated in the dispatch that supplied this text · **Lab:** Claude

**Independence:** Skuld wrote this position independently and before this workspace existed,
satisfying `seed/protocols/deliberation.md` rule 3 — "The first seat writes without seeing others."

**Transcription notice:** skuld holds only `Read, Glob, Grep` and cannot write its own position
file. Under `seed/protocols/deliberation.md` rule 7a, muninn has transcribed the text below
**verbatim**, changing nothing, and preserves skuld's authorship. Discrepancies were reported to
the dispatching seat rather than corrected here.

---

# LOOP BRIEF

**Unit:** P3 — Always-on Presence (`C:\projects\yggdrasil\roadmap\P3-presence.md`, Status: In Progress)
**Date:** 2026-07-28
**Loop type:** scoped build under a narrowed gardener authorisation, following the 2026-07-28 escalate

---

## (a) Task selection and ceiling mapping

**Ceiling source, stated honestly.** I found no numeric task ceiling in `boundaries.md` (line 13 says only "within the task ceiling") or in `gates.md` (Budgets are 3 *attempts* and 2 *reopens*, not tasks). The number 3 comes from skuld's own output contract ("Related tasks that may be grouped (max 3 total)") and from your directive. I am treating 3 as binding.

**Mapping:** four authorised items, ceiling of three. They do not divide evenly, so I split on coherence rather than convenience.

| Item | This loop? | Why |
|---|---|---|
| 1. `seed/memory/log/session-brief.md` | **Yes** — slot 1 | The three form one artifact set; none is usable alone |
| 2. `ygg session-brief --update/--clear` | **Yes** — slot 2 | A subcommand with no file writes nowhere; a file with no subcommand is dead |
| 3. `guides/session-brief-workflow.md` | **Yes** — slot 3 | A subcommand shipped without its guide is the shape `[HUMAN]` doctrine step 2 exists to prevent |
| 4. Task 3.7 done-condition repair | **No — next loop, as its own first task** | See below |

**Item 4 travels in the NEXT loop.** Reasons, in order of weight:

1. **The ceiling is 3 and items 1-3 already fill it.** You told me not to exceed it to be accommodating. I am not.
2. **Item 4 has zero dependency on items 1-3.** This is a real finding, not a convenience: because the brief file lands at `seed/memory/log/session-brief.md`, it falls *inside* the path set 3.7 already permits. Had it landed anywhere else, 3.7's repair would have had to widen to accommodate it, and the two items would have been coupled. The location choice decouples them. Item 4 loses nothing by waiting one loop.
3. **Different write class.** Items 1-3 write new files under `tools/`, `guides/`, and `seed/memory/log/`. Item 4 edits `roadmap/P3-presence.md` — a canonical work document, and an edit to an already-approved unit's acceptance criteria. Mixing those in one loop gives one executor two different authority profiles in one brief.

**Counter-argument, recorded so you can overrule me:** item 4 is the only one of the four with a downstream unblock — `[E55]` unticked 3.1 partly because 3.7 has no verdict, so repairing 3.7 is what eventually re-tickets 3.1. Items 1-3 are a discretionary convenience feature. If you want value-ordering rather than coherence-ordering, invert: run item 4 alone this loop, items 1-3 next. Say the word and I will re-emit. I chose coherence because items 1-3 are what you asked for by name and item 4 was Var's independent addition.

---

## (b) Done-conditions for items 1-3 — **ALL NEWLY AUTHORED**

> **Status flag, do not skip:** none of the three exists in canon. Every done-condition below is authored by skuld in this brief and is **provisional and subject to Var's verifiability check under `planning-board.md` step 2** before brokkr executes. Var failed the prior draft on 11 defective clauses (6 High). I have deliberately avoided the three named shapes: no clause defines a placeholder by reference to another task's placeholder; no clause tests free-text LLM output by judgement; no clause asks the builder to author the prose that justifies its own exemption. Every clause below names a proving artifact and a command that returns a count or a boolean.

### Item 1 — session brief file

**Executing role: brokkr (builder).**

> **Done when:** the file `seed/memory/log/session-brief.md` exists; its first three bytes are not `EF BB BF`; and `Select-String -Path seed/memory/log/session-brief.md -SimpleMatch -Pattern <s>` returns one or more matches for each of these four literals `<s>`, character-for-character:
> - `Ephemeral session state`
> - `Overwritten in place, never appended`
> - `Not a durable-memory path`
> - `Durable facts route through seed/memory/staging.md and two-step ratification`
>
> **and** `Select-String -Path tools/ygg/ygg-daemon.ps1 -SimpleMatch -Pattern 'session-brief'` returns zero matches.

The four literals are the source of truth for the header and are fully specified here — there is no second task holding their definition. The final clause is the mechanical enforcement of your out-of-scope item 5.

### Item 2 — `ygg session-brief` subcommand

**Executing role: brokkr (builder).**

> **Done when** all seven hold:
> 1. `ygg session-brief --update "YGGSB-ALPHA"` followed by `ygg session-brief --update "YGGSB-BRAVO"` leaves `seed/memory/log/session-brief.md` such that `Select-String -SimpleMatch -Pattern 'YGGSB-BRAVO'` returns >= 1 match and `Select-String -SimpleMatch -Pattern 'YGGSB-ALPHA'` returns 0 matches. (Proves overwrite, not append.)
> 2. `ygg session-brief --clear` then leaves the file present, all four Item-1 header literals still returning >= 1 match each, and `Select-String -SimpleMatch -Pattern 'YGGSB-BRAVO'` returning 0 matches.
> 3. `Select-String -SimpleMatch -Pattern 'session-brief'` returns 0 matches against **both** `tools/ygg/ygg-heartbeat.ps1` and `tools/ygg/ygg-daemon.ps1`. (Mechanises Heimdall's unresolved second ground and your item-5 exclusion.)
> 4. `git status --porcelain -- seed/ tools/ guides/ roadmap/` captured immediately before and immediately after one `--update` run differ in exactly one path, and that path is `seed/memory/log/session-brief.md`.
> 5. For every `.ps1` file created or modified by this task: `$e=$null; [void][System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path <path>).Path,[ref]$null,[ref]$e); $e.Count` equals `0`.
> 6. For every `.ps1` file created or modified by this task: `([IO.File]::ReadAllBytes((Resolve-Path <path>).Path) | Where-Object { $_ -ge 0x80 }).Count` equals `0`.
> 7. For every `.ps1` file created or modified by this task: `Select-String -SimpleMatch -Pattern '2>&1'` returns 0 matches.

Clauses 5-7 are your binding constraints made checkable rather than aspirational. Clause 6 is why any non-ASCII output must be constructed from char codes.

### Item 3 — workflow guide

**Executing role: brokkr (builder).**

> **Done when:** `guides/session-brief-workflow.md` exists, its first three bytes are not `EF BB BF`, and `Select-String -SimpleMatch` returns >= 1 match for each of these literals:
> - `## Purpose`
> - `## How to update mid-session`
> - `## How to clear`
> - `## How to verify`
> - `manual invocation only`
> - `not read by the heartbeat and not read by the daemon`
> - `Select-String -Path seed/memory/log/session-brief.md`
>
> **and** the file contains at least three fenced code blocks whose first content line begins with the literal `ygg session-brief`.

"Beginner-level" is untestable by machine, so I did not write it as a clause. The mechanical proxy is: three sections each carry a runnable command, and the verify section carries the exact inspection command. If Var wants a stronger proxy it should propose one; I will not substitute a judgement test.

---

## (c) Item 4 — task 3.7 done-condition repair

**Current text, quoted verbatim from `roadmap/P3-presence.md` line 40:**

```
- [ ] 3.7 Verify Y09 on live heartbeat — Done when: after 3+ heartbeat cycles, `git diff --name-only` shows changes only under `seed/memory/log/` and provenance.md. No durable memory files were touched.
```

**Why it is defective** (Var's independent finding, which I re-confirm from the text alone): `git diff --name-only` with no pathspec is repo-wide and reports the whole working tree, not the heartbeat's effect. You re-ran it and got 46 paths; the prior loop recorded 44. It is therefore unsatisfiable in any tree carrying unrelated uncommitted edits, which is every tree this repo has had. It also names `provenance.md` without a path, and names no proving artifact — which is exactly why `[E55]` records that Y09 has no verdict and no transcript in `evaluations/`.

**What the repair must achieve — four properties:**
1. **Scoped pathspec**, not repo-wide.
2. **Before/after delta**, not absolute working-tree state. This is the property that fixes the 46-path failure; nothing else does.
3. **A named proving artifact** — a transcript on disk, since `[E55]` blocks 3.1 on its absence.
4. **No `.gitignore` clause.** The rejected mitigation stays rejected; the instrument stays unblinded.

**Proposed replacement text — skuld's draft, for Var and Kvasir to review, not yet canon:**

> `- [ ] 3.7 Verify Y09 on live heartbeat — Done when: three or more heartbeat cycles have run; for each cycle a before-snapshot and an after-snapshot of `git status --porcelain -- seed/` are recorded in a single transcript file under `evaluations/`; for every cycle the set of lines present in the after-snapshot and absent from the before-snapshot contains only paths matching `seed/memory/log/` or the exact path `seed/memory/provenance.md`; and for every cycle that same set contains no path under `seed/constitution/`, `seed/protocols/`, `seed/adapters/`, `seed/growth/`, and none of `seed/memory/profile.md`, `seed/memory/goals.md`, `seed/memory/projects.md`, `seed/memory/decisions.md`, `seed/memory/capabilities.md`, `seed/memory/staging.md`. The transcript path is cited in the Y09 verdict line.`

**Executing role: brokkr (builder)** — this is a file edit. **Ambiguity I am flagging rather than guessing** (boundaries.md line 29): `roadmap/P3-presence.md` is a canonical work document, and muninn is the canon seat. But `planning-board.md` line 132 restricts the orchestrator to the loop log only, and lines 123-125 bar planning from executing — muninn sits in the planning column. I choose brokkr because the act is a file edit and brokkr is the execution seat; if you read roadmap edits as canon-keeper territory, say so and it becomes muninn.

**Classification, confirmed:** this is a done-condition repair on a task whose checkbox is `[ ]` (Not Started). It is **not a reopen**. No condition in `gates.md` "Status transitions" is engaged; `Locked -> Reopened` does not apply; the 2-reopen budget in `gates.md` Budgets is untouched.

---

## (d) Executing roles — all verified against the roster

Roster per `CLAUDE.md`: skuld, verdandi, var, muninn, brokkr, huginn, heimdall, kvasir; odin orchestrates; bifrost is outside the roster.

| Item | Executing role | In roster |
|---|---|---|
| 1. brief file | **brokkr** | yes |
| 2. subcommand | **brokkr** | yes |
| 3. guide | **brokkr** | yes |
| 4. 3.7 repair (next loop) | **brokkr** (see ambiguity above) | yes |

**Human-tagged: no.** None of items 1-4 meets any of the five triggers in `boundaries.md` lines 92-99. Tagging any of them `[HUMAN]` would violate "Automatable work must never be tagged `[HUMAN]`."

**Related tasks that may be grouped (max 3 total):** items 1, 2, 3 — provisional, unnumbered.

---

## (e) Structural authorisation — what "apply necessary changes" does and does not authorise

The prior loop recorded, verbatim from line 70: **"Group D and tasks 3.10-3.14 are NOT recorded here — they await gardener approval."**

**My read: execute as a scoped build WITHOUT new task numbers and WITHOUT creating Group D.** Grounds:

1. **`gates.md` line 6 (Gate 1):** "Ambiguous acknowledgement ('looks good') is **not** approval." "Apply necessary changes" enumerates no task, no number, and no group. It is materially the same shape as the acknowledgement Gate 1 names.
2. **`boundaries.md` line 27:** "Scope changes beyond the approved plan (change-request workflow)" is Must-ask. Adding a Group D and tasks 3.10-3.13 to an approved unit is a scope change to that unit. `gates.md` line 67 requires a change request naming problem, proposed change, affected canon, and impact on completed units. None has been produced.
3. **What it does authorise:** the four items as *work*, and a Loop Log entry recording them. `planning-board.md` line 104 requires the plan-review outcome in the unit's loop log; line 132 permits the orchestrator that write.

**So, concretely:**
- **Authorised:** create the three artifacts; repair 3.7's done-condition text in place; write a Loop Log entry in `P3-presence.md` that quotes the three authored done-conditions in full, so they exist on disk and are verifiable rather than living only in this context.
- **Not authorised:** creating a `### Group D` heading; creating task numbers 3.10-3.13; adding lines to the Completion Checklist; ticking 3.1.

**One narrow question that would settle it:** "Record items 1-3 as numbered tasks 3.10-3.12 under a new Group D — yes or no?" A yes converts this from a scoped build into a unit amendment.

---

## Two findings on your proposed resolution — validated, not assumed

You asked the plan-review roles to validate the location argument rather than assume it. Skuld's read, ahead of Var/Kvasir/Heimdall:

**Finding 1 — the location argument holds, and by a stronger route than you gave.** `boundaries.md` line 35 reads verbatim: *"Write to durable memory from a background, scheduled, or heartbeat context. Logs only."* Its subject is the **invocation context**. `ygg session-brief --update` is manual-invocation-only, so line 35 does not engage at all — the write is not from a background, scheduled, or heartbeat context. Your location argument is the *fallback*: even if it did engage, "Logs only" names `memory/log/` as the permitted target and the file sits there. Both routes clear it, with no amendment and no self-authored exemption prose. Kvasir's relocation objection is mooted; the `.gitignore` mitigation is unnecessary and stays rejected; Y09's instrument stays unblinded.

**Finding 2 — a friction your proposal does not address, and Kvasir should rule on it.** `boundaries.md` lines 10 and 15 both characterise that directory as **append-only**: *"Write to `memory/log/` (append-only session digests)"*. This file is by design overwrite-in-place. So the location satisfies line 35 while sitting against the append-only characterisation in the May-do-alone list. I do not think this blocks — line 17 says *"Neither is a durable-tier file; neither requires ratification,"* and an overwrite of an ephemeral scratch file is not a durable write — but I am not the seat that rules on structural fit.

**Finding 3 — Kvasir's name collision is NOT mooted; the relocation makes it worse.** `seed/protocols/brief.md` line 13 defines a "session brief," and line 142 says session briefs are *"delivered as part of the session digest in the daily log file (`memory/log/<date>.md`)."* Placing a *different* thing named `session-brief.md` into that same directory puts two unrelated artifacts called "session brief" side by side in `seed/memory/log/`. **I recommend renaming to `seed/memory/log/session-state.md` with `ygg session-state --update/--clear`.** I have written the done-conditions against your literal name because inventing a rename silently is the shape `boundaries.md` line 29 forbids. **One word from you before brokkr runs settles it**; if you say rename, every literal above changes mechanically and nothing else does.

---

## Gates and preconditions before brokkr executes

- **Plan review is required, again.** `planning-board.md` line 110: *"any plan producing durable artifacts"* triggers it. Items 1-3 produce three durable artifacts. Var (verifiability of the three authored done-conditions), Kvasir (structural fit; the append-only friction and the name collision), and Heimdall (confirm clause 3 of Item 2 discharges his second ground) must run before the first task.
- **Lab-rule caveat still unsatisfied, restated because it does not expire.** `planning-board.md` line 48: *"A role may not verify work produced by a role on its own lab."* Every seat here runs on Claude. This is a same-model structured self-check, not independent review - as `CLAUDE.md` also states. Any decision to proceed is made knowing that.
- **Heimdall's second ground remains live and is not being resolved, only routed around.** The heartbeat is remotely reachable and unthrottled via the daemon's status/briefing fast path. The mitigation this loop is total avoidance: no heartbeat wiring, mechanised as Item 2 clause 3. `tools/ygg/ygg-daemon.ps1` is not opened.
- **Item 5 stays out of scope.** The daemon read is an undeclared Gate 4 under `gates.md` line 15 (*"Per-capability, per-expansion. Default-deny."*), against a capability whose declared-vs-actual is recorded UNVERIFIED. Gate 4 is gardener-only; it cannot be self-declared. Not planned, not scheduled, not stubbed.

---

## Files read for this brief (all absolute)

- `C:\projects\yggdrasil\roadmap\P3-presence.md`
- `C:\projects\yggdrasil\seed\protocols\brief.md`
- `C:\projects\yggdrasil\seed\protocols\planning-board.md`
- `C:\projects\yggdrasil\seed\constitution\boundaries.md`
- `C:\projects\yggdrasil\seed\constitution\gates.md`

Four tool calls, no globbing, no exploration. No file was edited.

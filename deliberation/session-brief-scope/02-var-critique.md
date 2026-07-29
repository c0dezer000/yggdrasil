# Var - critique

**Seat:** var (verification)
**Read before writing (in this order, in full):**
`C:\projects\yggdrasil\deliberation\session-brief-scope\00-question.md` ·
`C:\projects\yggdrasil\deliberation\session-brief-scope\01-skuld-position.md` ·
`C:\projects\yggdrasil\seed\protocols\deliberation.md` ·
`C:\projects\yggdrasil\seed\protocols\planning-board.md` ·
`C:\projects\yggdrasil\seed\protocols\review.md` ·
`C:\projects\yggdrasil\tools\ygg\ygg-doctor.ps1` ·
`C:\projects\yggdrasil\tools\ygg\ygg.ps1` ·
`C:\projects\yggdrasil\tools\ygg\ygg.cmd` ·
`C:\projects\yggdrasil\tools\ygg\ygg-listen.ps1` (excerpt, lines 205-255) ·
`C:\projects\yggdrasil\tools\ygg\ygg-daemon.ps1` (excerpt, lines 530-545) ·
`C:\projects\yggdrasil\roadmap\P3-presence.md` (lines 36-44)

**Model:** claude-opus-5 · **Lab:** Anthropic (Claude)

**My check, and only my check.** `planning-board.md` line 79: *"Var - verifiability. For each
done-condition: what artifact would prove this, and could it be checked without judgement? A
done-condition that cannot name its proving artifact fails the plan."* I do not rule on ceiling
mapping, on the name collision, on structural fit, or on risk. Where I touch those, it is only
because a verifiability property depends on them, and I say so.

**Lab caveat, restated because it does not expire [E50].** `planning-board.md` line 48: *"A role may
not verify work produced by a role on its own lab."* Skuld and I both run on Claude. **This is a
structured self-check, not independent review.** Every verdict below carries that qualifier.

**I did not fix anything.** `planning-board.md` line 129: *"Verification may not build. A verifier
that fixes what it found has verified its own repair."* No file in the repository was edited by me
except this one. The two scratch artifacts I created for empirical tests live outside the repository
(`C:\Users\Public\hdgtest.md`, and a throwaway git repository under the temp directory) and touch no
seed path.

---

## BEFORE baseline - `ygg doctor`, run now, recorded verbatim

Invocation: `powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Set-Location
'C:\projects\yggdrasil'; & '.\tools\ygg\ygg.ps1' doctor"`, stdout and stderr redirected to separate
files (no `2>&1` on a native command, per the E77 constraint). **stderr was empty.**

```
ygg doctor - environment check
Project root: C:\projects\yggdrasil

[1/10] Seed root resolves
  [PASS] Seed root resolves
[2/10] .ygg is gitignored
  [PASS] .ygg is gitignored
[3/10] Every canonical file is UTF-8 without BOM
  [FAIL] UTF-8 without BOM
         Files with BOM: C:\projects\yggdrasil\seed\memory\log\heartbeat-2026-07-26.md; C:\projects\yggdrasil\seed\memory\log\heartbeat-2026-07-27.md; C:\projects\yggdrasil\seed\memory\log\heartbeat-2026-07-28.md
[4/10] No mojibake sequences
  [PASS] No mojibake sequences
[5/10] Adapters load under host's own loader
  [PASS] Adapters load (opencode + claude)
[6/10] Command directories correctly named
  [PASS] Command directories correctly named
[7/10] opencode.json present and non-empty
  [PASS] opencode.json present and non-empty
[8/10] No placeholder brackets outside _templates/
  [PASS] No unfilled stubs; generated agents carry no template scaffolding
[9/10] Every capabilities.md entry has a corresponding file
  [PASS] Capabilities entries reference existing files
[10/10] Append-only files not truncated
  [PASS] Append-only files not truncated

Summary: 9 passed, 1 failed
Failed checks:
  - UTF-8 without BOM - Files with BOM: C:\projects\yggdrasil\seed\memory\log\heartbeat-2026-07-26.md; C:\projects\yggdrasil\seed\memory\log\heartbeat-2026-07-27.md; C:\projects\yggdrasil\seed\memory\log\heartbeat-2026-07-28.md
EXITCODE=1
```

**Observed: 9 passed, 1 failed. This matches the expected baseline exactly**, and the single failure
is the expected one - BOM on the three heartbeat logs, finding E64, Low, deliberately left. I did not
touch it.

---

## Steelman

The strongest form of Skuld's position, stated so it can be attacked fairly:

*Four items were authorised; the seat ceiling is three; items 1-3 are one artifact set that is
useless if split, and item 4 is provably independent of them, so the split falls out of the material
rather than out of convenience. Every one of the three named prior defect shapes has been eliminated
by construction: no clause defines a placeholder by pointing at another task's placeholder - the four
header literals are given in full, character for character, in the brief itself, so the brief is the
source of truth and no second task holds it; no clause asks the builder to author the prose that
justifies its own exemption - the exemption question was dissolved by location and by invocation
context, so there is no prose to author; no clause tests free-text output by judgement - the
untestable phrase "beginner-level" was explicitly refused rather than smuggled in as a soft clause,
and the refusal was declared out loud with an invitation to Var to supply a better proxy. Every
remaining clause resolves to a count or a boolean. The binding environment constraints that caused
two failures today were converted from advice into checkable clauses 5, 6 and 7 rather than left as
prose in a brief nobody re-reads. And on the item that most matters, task 3.7, Skuld did not merely
accept Var's finding - it named the four properties a repair must have, identified which single
property (before/after delta rather than absolute working-tree state) is the one that actually fixes
the 46-path failure, and refused to add the rejected gitignore mitigation even though it would have
made the check pass more easily. A planner that identifies the load-bearing property of its own
repair, and that declines to blind the instrument to make its own task easier, is doing the job.*

That is a real improvement over the draft I failed on 11 clauses. I want to record that before I take
it apart.

---

## Position

**The three named defect shapes do not recur. I checked for each specifically and found none.** New
defects do. My check is verifiability, and the load-bearing question is not "is there a command?" but
**"does the named command actually prove the named property?"** Several clauses here name a command
that runs cleanly and proves something other than what it claims. That is a harder defect class than
the one I caught last time, because it survives a reading and only fails under execution.

I ran the commands. Findings below are ordered by severity, not by document order.

---

## Where I disagree

### V1 - Item 2, clause 4 is unsatisfiable as written. Severity: High.

**Criterion verbatim (`01-skuld-position.md` line 76):**

> `git status --porcelain -- seed/ tools/ guides/ roadmap/` captured immediately before and
> immediately after one `--update` run differ in exactly one path, and that path is
> `seed/memory/log/session-brief.md`.

**Observed.** A `git status --porcelain` line for an **untracked** file is `?? <path>`. That line is
a function of the path, not of the content. Changing the content of an untracked file changes nothing
in porcelain output. Items 1-3 create new files and the plan contains no commit step, so
`seed/memory/log/session-brief.md` is untracked at the moment clause 4 runs.

Demonstrated in a clean throwaway repository outside the seed:

```
=== BEFORE ===        (file contains YGGSB-ALPHA)
?? seed/memory/log/session-brief.md
=== AFTER ===         (file contains YGGSB-BRAVO)
?? seed/memory/log/session-brief.md
=== DELTA ===
(identical)
```

The delta is **zero** paths. The criterion demands **exactly one**. Clause 4 fails on a correct
build. This is a false failure rather than a false pass, so it is High rather than Critical - but it
will halt a correct build and send the builder hunting a defect that is not there.

**Fix.** Replace the porcelain snapshot with a content snapshot:
`Get-ChildItem -Path seed,tools,guides,roadmap -Recurse -File | Get-FileHash -Algorithm SHA256`,
captured before and after, compared with `Compare-Object -Property Path,Hash`. That detects
modification of untracked files, tracked files, and already-dirty files alike.

---

### V2 - Item 2, clause 3 does not cover the remote surface it claims to close. Severity: High.

**Criterion verbatim (`01-skuld-position.md` line 75):**

> `Select-String -SimpleMatch -Pattern 'session-brief'` returns 0 matches against **both**
> `tools/ygg/ygg-heartbeat.ps1` and `tools/ygg/ygg-daemon.ps1`. (Mechanises Heimdall's unresolved
> second ground and your item-5 exclusion.)

**Observed.** `tools/ygg/ygg-listen.ps1` contains the same remotely reachable heartbeat fast path as
the daemon. From that file:

```
212:    # Status / Briefing - run heartbeat and reply with briefing
213:    if ($lowerText -eq 'status' -or $lowerText -eq 'briefing') {
215:        $heartbeatScript = Join-Path -Path $scriptDir -ChildPath "ygg-heartbeat.ps1"
219:                $output = & $heartbeatScript ... | Out-String
```

`ygg.ps1` line 15 describes `listen` as *"start Telegram inbound listener (P3 always-on presence)"*.
That is an inbound remote surface running the heartbeat on an unauthenticated-by-content message.
`ygg-daemon-install.ps1` is likewise unnamed. The clause names two files and asserts it has
mechanised a ground about **remote reachability in general**. That is `review.md` check 1 - the
criterion silently narrowed between the property and the test.

**Fix.** Invert to default-deny, matching `gates.md` line 15's own posture: *for every `.ps1` under
`tools/ygg/` except `ygg.ps1` and the new `ygg-session-brief.ps1`, `Select-String -SimpleMatch
-Pattern 'session-brief'` returns 0 matches.* One clause, no allowlist to forget to extend.

---

### V3 - Section (c)'s replacement does not fix the property Skuld says it fixes. Severity: **Critical**.

This is my most serious finding and it is the one I would fail the plan on alone.

**Skuld's claim, verbatim (`01-skuld-position.md` line 114):**

> **Before/after delta**, not absolute working-tree state. This is the property that fixes the
> 46-path failure; nothing else does.

**Replacement clause, verbatim (`01-skuld-position.md` line 120, relevant portion):**

> for every cycle the set of lines present in the after-snapshot and absent from the before-snapshot
> contains only paths matching `seed/memory/log/` or the exact path `seed/memory/provenance.md`

**Observed.** The delta is computed over **porcelain status lines**. A porcelain line for a file that
is *already dirty before the cycle* is identical before and after, because the status character does
not change when the content changes. So a write into an already-dirty file produces **no delta line
at all** and the criterion passes.

`git status --porcelain -- seed/` right now, in this tree, returns 51 lines. Among them:

```
 M seed/memory/capabilities.md
 M seed/memory/decisions.md
 M seed/memory/provenance.md
 M seed/memory/staging.md
?? seed/memory/log/2026-07-28.md
```

Every one of those is on Skuld's own denylist of durable files the heartbeat must not touch - except
provenance, which is on the allowlist. **In this tree, the replacement done-condition would return a
PASS even if the heartbeat wrote to `seed/memory/decisions.md`, `seed/memory/staging.md`, or
`seed/memory/capabilities.md` on every cycle**, because those paths are already dirty and their
porcelain lines would not move.

Y09 is the instrument that enforces `boundaries.md` line 35 - *"Write to durable memory from a
background, scheduled, or heartbeat context. Logs only."* The replacement gives that instrument a
blind spot precisely over the durable files it exists to protect, and does so in exactly the tree
state this repository is always in. Per `review.md` severity: *"A governing mechanism is defeated, or
a completion claim rests on nothing."* The original 3.7 was unsatisfiable, which is loud. This one is
satisfiable and wrong, which is silent. **A false pass is worse than a failure, because it closes a
gate that was never tested** (`review.md` check 2).

The scoping to `-- seed/` is a genuine improvement. The delta construction is not, because it is a
delta over the wrong thing.

**Fix.** The snapshot must be content, not status. Before and after each cycle:

```
Get-ChildItem -Path seed -Recurse -File | Get-FileHash -Algorithm SHA256 |
  Select-Object @{n='Rel';e={$_.Path.Substring($root.Length+1)}},Hash
```

Delta = `Compare-Object` on `Rel,Hash`, taking `=>` rows. That set is the true set of files the cycle
touched, dirty or clean, tracked or not. Then apply the allowlist to that set.

---

### V4 - Section (c) is satisfied by three manual runs; the criterion says "live heartbeat". Severity: High.

**Original criterion verbatim, from `roadmap/P3-presence.md` line 40** (I opened the file; Skuld's
quotation is accurate character for character, and the 46-path repo-wide count reproduces - I ran
`git diff --name-only | wc -l` and got **46**):

> `- [ ] 3.7 Verify Y09 on live heartbeat - Done when: after 3+ heartbeat cycles, `git diff
> --name-only` shows changes only under `seed/memory/log/` and provenance.md. No durable memory files
> were touched.`

**Replacement, verbatim:** *"three or more heartbeat cycles have run"*.

**Observed.** Nothing in the replacement requires those cycles to be scheduler- or daemon-initiated.
Three manual `ygg heartbeat` invocations satisfy it. But the rule under test - `boundaries.md`
line 35 - is scoped to **invocation context**: *"from a background, scheduled, or heartbeat context."*
A manual run is a different context from the one the rule governs. This is `review.md` check 2: the
Arrange precondition ("live heartbeat") is not verified by the criterion, only assumed. A test run
without its Arrange precondition is VOID.

Skuld's own Finding 1 at line 167 turns on exactly this distinction - it argues the session brief is
safe *because* manual invocation is a different context from background invocation. The same
distinction, applied to 3.7, means manual cycles do not test Y09.

**Fix.** Require the transcript to record, per cycle, the initiating context - the scheduled task
name and its recorded run time, or the daemon log line - and require the three cycles to be
scheduler- or daemon-initiated.

---

### V5 - Section (c) names a directory, not a file, as its proving artifact. Severity: Medium.

**Skuld's own property 3, verbatim (line 115):** *"A named proving artifact - a transcript on disk,
since `[E55]` blocks 3.1 on its absence."*

**What the replacement actually says:** *"are recorded in a single transcript file under
`evaluations/`"*, and *"The transcript path is cited in the Y09 verdict line."*

"A single transcript file under `evaluations/`" cannot be checked with `Test-Path`. Neither can "the
Y09 verdict line", which names no file at all. `[E55]` blocked 3.1 on the absence of a named
transcript in `evaluations/`; a done-condition that names a directory reproduces the condition it was
written to repair. This is the exact shape `planning-board.md` line 81 fails a plan for.

**Fix.** Name the exact path in the done-condition text, e.g.
`evaluations/Y09-live-heartbeat-<YYYY-MM-DD>.md`, and name the file holding the Y09 verdict line.

---

### V6 - Section (c)'s denylist is default-allow and is already incomplete. Severity: Medium.

The clause enumerates `seed/constitution/`, `seed/protocols/`, `seed/adapters/`, `seed/growth/`, and
six named files under `seed/memory/`. **`seed/memory/relationships.md` is not among them.** It exists
in the tree right now (`?? seed/memory/relationships.md`) and `deliberation.md` line 119 describes it
as *"Append-only, durable tier, ratified like any other durable memory."* A durable-tier file is
outside the denylist on the day the denylist is written.

The allowlist clause immediately preceding already excludes everything not under
`seed/memory/log/` or `seed/memory/provenance.md`, so the denylist adds no coverage - it only creates
the impression that the enumerated set is the test, and it will rot. `gates.md` line 15 sets the
house posture: **default-deny**.

**Fix.** Delete the denylist sentence. Keep the allowlist.

---

### V7 - Section (c) computes a delta over lines but constrains paths. Severity: Medium.

The delta elements are porcelain lines of the form `XY<space><path>`. The constraint is written over
*"paths matching `seed/memory/log/`"*. Nothing specifies stripping the two-character status and
space, and nothing addresses porcelain's quoting of paths containing special characters. A literal
implementer comparing raw lines against `seed/memory/log/` matches nothing.

**Fix.** Moot if V3's fix is adopted (hash snapshots produce paths, not status lines). Otherwise
state the extraction explicitly.

---

### V8 - The replacement text is not paste-ready. Severity: Medium.

`01-skuld-position.md` line 120 opens with a backtick immediately before `- [ ] 3.7`, then contains
further backticks around `git status --porcelain -- seed/`, `seed/memory/log/`, and each path. The
code-span nesting is unbalanced. A builder instructed to write this "verbatim" into
`roadmap/P3-presence.md` writes a stray leading backtick and mismatched spans into a canonical work
document. Since the whole point of the exercise is that the done-condition text on disk is the source
of truth, the delivered form matters.

**Fix.** Deliver the replacement as a fenced block containing the exact bytes of the target line.

---

### V9 - `ygg` is not a resolvable command in this environment. Severity: Medium.

**Observed.** `Get-Command ygg` returns nothing. No entry in `$env:PATH` contains the substring
`ygg`. The entry point is `C:\projects\yggdrasil\tools\ygg\ygg.cmd`, which is not on PATH.

Every clause in Item 2 is written as `ygg session-brief --update "..."`. As written, none of them
runs. This is `review.md` check 2 again - an unverified Arrange precondition. It also lands on
Item 3: a beginner-level guide whose three fenced blocks begin with a command that does not resolve
is a guide that fails on line 1 for its target reader.

**Fix.** Write the invocation as `.\tools\ygg\ygg.cmd session-brief --update "..."` from the repo
root, or state the PATH precondition as an explicit Arrange clause that is itself checked.

---

### V10 - Item 2 clauses 1 and 2 omit `-Path` and throw. Severity: Medium.

**Observed.** `Select-String -SimpleMatch -Pattern 'YGGSB-BRAVO'` with no `-Path` and no pipeline
input raises:

```
CAUGHT: ParameterBindingException :: Cannot process command because of one or more missing mandatory parameters: Path.
```

It is a hard error, not a hang. The intended path is recoverable from the surrounding prose, so this
is Medium and not High - but a done-condition whose command must be repaired by inference before it
runs is not a mechanical check, it is a hint.

**Fix.** Write `-Path seed/memory/log/session-brief.md` in every clause that greps it.

---

### V11 - Item 3's heading clauses are defeated by deeper headings. Severity: Medium.

**Observed.** `-SimpleMatch` is a substring test, and `### Purpose and scope` contains the substring
`## Purpose`. Tested against a file whose only heading was `### Purpose and scope`:

```
Select-String -Path ... -SimpleMatch -Pattern '## Purpose'   ->   1
```

All four heading clauses in Item 3 are satisfied by `###`-level headings with arbitrary trailing
text. The clause claims to prove a four-section skeleton and does not.

**Fix.** `Select-String -Path guides/session-brief-workflow.md -Pattern '(?m)^## Purpose\s*$'`, and
require **exactly 1** match rather than `>= 1`, so duplicated sections also fail.

---

### V12 - Item 3's fenced-block clause names no command, and is ambiguous. Severity: Medium.

**Skuld's own stated standard, verbatim (`01-skuld-position.md` line 52):** *"Every clause below
names a proving artifact and a command that returns a count or a boolean."*

**The clause (line 96):** *"the file contains at least three fenced code blocks whose first content
line begins with the literal `ygg session-brief`."*

This is the only clause in the entire brief with no command. It is mechanisable, but it is not
mechanised, and "first content line" is ambiguous about the fence info string - is the first content
line of ```` ```powershell ```` the word `powershell`, or the line after it? Two implementers get two
answers. That residual ambiguity is judgement, which is what the clause exists to exclude.

**Fix.** Supply the exact command. Resolving the ambiguity in the same stroke:

```
$t = Get-Content guides/session-brief-workflow.md
$n = 0; $in = $false
foreach ($l in $t) {
  if ($l -match '^```') { $in = -not $in; $expect = $in; continue }
  if ($expect) { if ($l -like '.\tools\ygg\ygg.cmd session-brief*') { $n++ }; $expect = $false }
}
$n   # must be >= 3
```

---

### V13 - "every `.ps1` file created or modified by this task" is a set the executor defines by its own behaviour. Severity: Medium.

Clauses 5, 6 and 7 all quantify over that set. The set has no independent definition. A builder that
modifies a `.ps1` and does not declare it escapes all three checks, and the checks report clean.
`planning-board.md` line 127: *"Execution may not verify itself. A builder reporting its own work as
passing is self-certification `[E40]`."* A quantifier whose domain the builder supplies is
self-certification wearing a command's clothes.

**Fix.** Name the set: `tools/ygg/ygg.ps1` and `tools/ygg/ygg-session-brief.ps1`. Add a closing
clause that the before/after content-hash delta over `tools/` contains no `.ps1` outside that set.

---

### V14 - Clauses 5-7 cover `.ps1` only; the entry point is `ygg.cmd`. Severity: Medium.

`tools/ygg/ygg.cmd` is the dispatcher a user actually invokes. It is not a `.ps1`, so no parse check,
no high-byte check and no redirection-token check applies to it. If brokkr edits it, nothing catches
a repeat of today's two failures there.

Recorded while I was in the file, **not for repair this loop**: `ygg.cmd` already contains mojibake -
two `REM` lines render as `REM ygg ?" Yggdrasil CLI entry point` and `REM Pass all arguments through
?"`, where an em dash was intended. Pre-existing, **Low, record and leave** per `review.md`. I name it
only because it demonstrates the gap is not theoretical.

**Fix.** Extend clauses 6 and 7 to `.cmd` as well as `.ps1`.

---

### V15 - The "9/1, not worse" exit gate cannot detect a BOM on the new seed file. Severity: Medium.

**Constraint verbatim (`00-question.md` line 124):** *"Do not fix it. Re-run at the end and confirm
9/1, not worse."*

**Observed.** doctor check 3 (`ygg-doctor.ps1` line 97) recursively scans every `*.md` under `seed/`
and reports **one aggregate result**. It is already the failing check. Adding a BOM-carrying
`seed/memory/log/session-brief.md` extends the failure *detail string* with a fourth path and leaves
the summary at **9 passed, 1 failed**. The stated exit gate is therefore blind to precisely the
regression Item 1 is most likely to produce, on a repository where three files already carry the
defect.

Item 1's own first-three-bytes clause is what actually carries this, and it is correct. Keep it.

**Fix.** Strengthen the exit gate: after the build, doctor must still report 9/1 **and** the check-3
failure detail must list exactly the three heartbeat log paths and no fourth path.

---

### V16 - Item 1's final clause is already true today. Severity: Low - record and keep.

`Select-String -SimpleMatch -Pattern 'session-brief'` returns **0 matches across the entire `tools/`
tree** right now; I ran it. The clause is a valid negative regression guard and should stay, but it
proves nothing about the builder's work beyond "did not wire" - it cannot distinguish a correct build
from an empty one. Not a defect; noted so nobody reads it as evidence of positive work.

---

### V17 - The location choice puts the new artifact inside Y09's blind spot. Severity: Medium.

**Skuld's claim, verbatim (line 43):** *"because the brief file lands at
`seed/memory/log/session-brief.md`, it falls *inside* the path set 3.7 already permits. Had it landed
anywhere else, 3.7's repair would have had to widen to accommodate it, and the two items would have
been coupled. The location choice decouples them."*

**The claim is true as stated** - I checked 3.7's allowlist and `seed/memory/log/` covers it - **but
the coupling runs the other way and Skuld did not look for it.** `ygg-heartbeat.ps1` line 14 declares
*"Y09 compliance: writes only to `seed/memory/log/`."* Placing the session brief inside that same
directory means Y09 **cannot ever detect** a future regression that wires the brief into the
heartbeat. The heartbeat writing to `seed/memory/log/session-brief.md` is, to Y09, indistinguishable
from the heartbeat writing its own daily log.

Item 2 clause 3 forbids that wiring today, so nothing is broken now. But the plan's own safety
argument rests on two independent mechanisms - a static grep and a live behavioural check - and the
location choice silently collapses that to one. That is a verifiability property, and it belongs in
the record before the location is fixed by construction.

**Fix.** No blocker. Record it in the loop log so the static grep (V2's default-deny form) is
understood to be the *only* mechanism enforcing the exclusion, and is not weakened later on the
assumption that Y09 backs it up.

---

## The `seed/memory/log/` doctor risk - answered

**The risk as posed (`00-question.md` lines 125-127):** *"adding a file under `seed/memory/log/` may
trip doctor's append-only/truncation check. If it does, that is a real signal - the brief is
overwritten, not appended, so the check may need to exclude it by name."*

**It will not trip. No check by that name will fire.** I opened `tools/ygg/ygg-doctor.ps1` and read
check 10 in full. Lines 411-414:

```powershell
$appendOnlyFiles = @(
    Join-Path -Path $ProjectRoot -ChildPath "seed\growth\ledger.md"
    Join-Path -Path $ProjectRoot -ChildPath "seed\memory\provenance.md"
)
```

Check 10 iterates a **hardcoded two-element list**. It does not enumerate `seed/memory/log/`, does
not glob, and has no notion of directory-level append-only policy. A new file under
`seed/memory/log/` is invisible to it. I also grepped `ygg-verify.ps1` and `ygg-heartbeat.ps1` for
any append-only or truncation logic over the log directory and found none.

**Which checks will actually see the new file, and what each does:**

| Check | Sees `seed/memory/log/session-brief.md`? | Consequence |
|---|---|---|
| 3 - UTF-8 without BOM (line 97, recursive `*.md` under `seed/`) | **Yes** | Fails only if it carries a BOM. Already the failing check - see V15. |
| 4 - No mojibake (same file set) | **Yes** | Fails only on the listed corrupt byte sequences. |
| 8 - Placeholder stubs (line 304, all `*.md` in project) | **No** - skipped twice | `seed\memory\*` is in `$intentionalDirPatterns` (line 286), **and** the basename matches the `session-*` skip (line 319). |
| 10 - Append-only not truncated | **No** | Hardcoded two-file list, lines 411-414. |
| 1, 2, 5, 6, 7, 9 | No | Unrelated file sets. |

**Consequence for the plan: do not build the by-name exclusion.** `00-question.md` line 127 proposes
it conditionally, and the condition is false. Adding an exclusion to `ygg-doctor.ps1` for a check
that never fires would be an edit to a verification instrument justified by a risk that does not
exist - and it would put a hand-written exception into the one tool whose job is to be unexceptional.
`ygg-doctor.ps1` should not be opened this loop.

Note also that `guides/session-brief-workflow.md` is seen by **no doctor check at all** - check 3 and
check 4 scan only under `seed/`, and check 8 skips `guides\*` by `$intentionalDirPatterns` (line 290).
Item 3's own first-three-bytes clause is the only thing checking that file's encoding. Keep it.

---

## The "beginner-level" proxy - answering Skuld's invitation

**Skuld's invitation, verbatim (line 98):** *"'Beginner-level' is untestable by machine, so I did not
write it as a clause. The mechanical proxy is: three sections each carry a runnable command, and the
verify section carries the exact inspection command. If Var wants a stronger proxy it should propose
one; I will not substitute a judgement test."*

**Skuld is right to refuse a judgement test, and right that the phrase is not machine-testable. I
accept that and I am not asking for it back.** But the current proxy tests only that command-shaped
*text* is present. It does not test that the commands *work* - and given V9, they currently would not.
A guide containing three fenced blocks of a command that does not resolve satisfies Skuld's proxy
exactly.

**Stronger proxy, proposed. It requires no judgement and it is runnable on PS 5.1:**

> **Additionally done when:** extracting from `guides/session-brief-workflow.md`, in document order,
> every fenced block whose first content line begins with `.\tools\ygg\ygg.cmd session-brief`, and
> executing those blocks in that order from the repository root in a fresh PowerShell 5.1 session,
> yields exit code `0` for every block; the full transcript of that run is written to
> `evaluations/session-brief-guide-run-<YYYY-MM-DD>.md`; and after the final block
> `seed/memory/log/session-brief.md` is in the cleared state - all four Item-1 header literals
> present, and the payload written by any earlier block absent.

**Why this is the right proxy.** "Beginner-level" is not directly measurable, but the *operational
property a beginner depends on* is: a beginner reads top to bottom and copies commands in order,
without the context to repair one that fails. A guide whose commands do not run in document order is
not beginner-level whatever its prose says. This measures exactly that, with zero judgement, and it
would have caught V9 by itself.

**Cost, stated honestly.** One harness of roughly fifteen lines, and the run mutates
`seed/memory/log/session-brief.md`, so it must run last or restore the file afterwards. The transcript
requirement is what makes it evidence rather than a claim.

**What it still does not test, said plainly.** Readability. Whether the prose is comprehensible to a
beginner is a judgement assertion, and `review.md` check 4 puts judgement assertions outside what a
machine or a self-scoring model may certify: *"self-scored behaviour is not evidence `[E40]`."* If
the gardener wants "beginner-level" genuinely verified, that is a human read, and no proxy substitutes
for it. **I am not asking for the task to be tagged `[HUMAN]`** - Skuld is correct at line 139 that
none of items 1-3 meets the five triggers in `boundaries.md` lines 92-99, and runnability is
automatable. I am recording the residue so nobody later reads a green proxy as proof of a property it
never measured.

---

## What would change my mind

Specific, falsifiable, per finding.

- **V3 (Critical) would be withdrawn** if someone demonstrates a before/after `git status --porcelain
  -- seed/` pair, taken across a real heartbeat cycle in a tree where `seed/memory/decisions.md` is
  already ` M`, in which a heartbeat write to `decisions.md` produces a new line in the after-snapshot.
  I do not believe such a pair exists, because the porcelain status character is unchanged by a
  content change on an already-modified file - but that is the exact demonstration that would refute
  me, and it is cheap to attempt.
- **V1 would be withdrawn** if the plan adds an explicit step committing the created files before
  clause 4 runs, making `session-brief.md` tracked at snapshot time. Then the before/after lines
  genuinely differ and the clause is sound as written.
- **V2 would be withdrawn** if Heimdall rules that `ygg-listen.ps1` is not part of the remote surface
  his second ground concerns. That is his call, not mine - I am reporting that the clause's file set
  is narrower than the property it claims to mechanise, and he owns the property.
- **V4 would be withdrawn** if `roadmap/P3-presence.md` or the P3 record defines "live heartbeat" as
  including manual invocation. I read lines 36-44 and found no such definition; if one exists
  elsewhere in canon, quote it and I concede.
- **V9 would be withdrawn** on a transcript showing `ygg session-brief --update "X"` resolving and
  running in the gardener's actual shell. My probe used `-NoProfile`; `$env:PATH` is not affected by
  the profile and contained no `ygg` entry, but a profile-defined **alias or function** named `ygg`
  would not appear in `$env:PATH` and would make the clauses runnable for the gardener while
  remaining unrunnable for any other executor. Either way the done-condition should name the
  invocation that works for whoever runs it.
- **V15 would be withdrawn** if doctor's check 3 reported per-file results rather than one aggregate.
  It does not; line 97 collects into `$bomFiles` and emits a single `Write-Result`.
- **V17 would be withdrawn** if Y09's instrument is specified to compare content hashes per file
  under `seed/memory/log/` rather than treating the directory as a unit - i.e. if V3's fix is adopted
  in a form that names `session-brief.md` explicitly as a permitted-but-tracked path.
- **The whole verdict flips to pass-with-changes** if section (c) is withdrawn from this review and
  re-submitted next loop, since Skuld itself schedules item 4 for the next loop. My fail rests
  primarily on (c). See the note under the verdict.

---

## Concessions

Genuine, and checked rather than offered as courtesy.

1. **The three named defect shapes do not recur. I looked for each one specifically.**
   - *Circular placeholder definitions.* Item 1's four header literals are given in full,
     character for character, in the brief. No other task holds their definition. Item 2 clause 2
     refers back to them, which is a dependency on a **specified** literal set, not on another task's
     placeholder. Clean.
   - *Builder authoring the prose justifying its own exemption.* There is none. The closest thing is
     Item 3's required literal `not read by the heartbeat and not read by the daemon`, and that
     narrowly escapes the shape because Item 2 clause 3 independently mechanises the same fact - the
     prose is corroborated by a machine check rather than standing in for one. (V2 says that check is
     too narrow; it does not say it is absent.)
   - *Judgement tests on free-text LLM replies.* None. "Beginner-level" was refused out loud rather
     than smuggled in as a soft clause, and the refusal was declared with an invitation to improve
     it. That is the correct handling and I want it on the record as such.

2. **Clause 5 is correct and I verified it runs.** Executed against `tools/ygg/ygg.ps1`:
   `ParseErrCount=0`, and `$e` is a real `System.Management.Automation.Language.ParseError[]`, so
   `.Count` is meaningful rather than a `$null` that coincidentally compares equal. The `[ref]$null`
   token argument binds without error on PS 5.1. Sound as written.

3. **Clause 6 is correct and I verified it runs.** Executed against `tools/ygg/ygg.ps1`:
   `HighBytes=0`. Sound as written, and it is the right mechanisation of the no-non-ASCII constraint.

4. **Skuld's quotation of task 3.7 is accurate.** I opened `roadmap/P3-presence.md` and read
   lines 36-44. The quoted text matches character for character. The 46-path claim reproduces: I ran
   `git diff --name-only | wc -l` and got **46**. Skuld did not accept a remembered number.

5. **Skuld's diagnosis of the original 3.7 is right, and its property 1 (scoped pathspec) is a real
   fix.** `git status --porcelain -- seed/` returns 51 lines against 46 repo-wide for the unscoped
   form, so scoping alone does not fix it - which is precisely why Skuld named property 2 as the
   load-bearing one. The analysis was correct; only the implementation of property 2 fails.

6. **Skuld refused to blind the instrument.** Property 4 keeps the rejected `.gitignore` mitigation
   rejected, at the cost of making its own task harder. A planner that declines the easy pass on its
   own done-condition is doing the job, and I am not going to pretend otherwise while failing it on
   other grounds.

7. **Skuld flagged the name collision rather than silently renaming.** Line 171 writes the
   done-conditions against the gardener's literal name and raises the rename as a question. That is
   `boundaries.md` line 29 applied correctly, and it is the opposite of the reasoned-around shape in
   `review.md` check 7.

8. **Skuld's Finding 1 - the invocation-context argument - is sound as far as my check reaches.**
   `boundaries.md` line 35's subject is the invocation context, and a manual-only subcommand does not
   engage it. I note only that this same distinction is what defeats section (c) at V4, and Skuld did
   not carry it across.

9. **Section (a)'s ordering, the ceiling mapping, the name collision, the append-only friction at
   Finding 2, and section (e)'s authorisation reading are not my check.** I have no verifiability
   objection to any of them and I express no view. Kvasir and Heimdall own those.

10. **On my own limits.** Everything above is a structured self-check by a Claude seat on a Claude
    seat's work. `review.md` check 4: *"One model in several seats produces one opinion in several
    voices."* Where I agree with Skuld, that agreement is weak evidence. Where I disagree and back it
    with an executed command and its recorded output - V1, V2, V3, V9, V10, V11, and the doctor
    baseline - the command output is the evidence, not my agreement or disagreement, and it survives
    the lab objection.

---

## VALIDATION

**Criteria (verbatim), `planning-board.md` line 79:** *"Var - verifiability. For each done-condition:
what artifact would prove this, and could it be checked without judgement? A done-condition that
cannot name its proving artifact fails the plan - this is the check that would have caught `[E39]`
before six assertions were built."*

**Observed:** 17 findings. 1 Critical, 3 High, 12 Medium, 1 Low. Every Item-1 clause passes. Item 2
clauses 5 and 6 pass and were executed. Item 2 clauses 1, 2, 3, 4 and 7 and all of Item 3 require
changes. Section (c) fails on its own stated load-bearing property.

**Verdict: not met.**

**Doctor baseline after my work: unchanged at 9 passed / 1 failed.** I ran no command that writes to
any repository path. The only file I created inside the repository is this one.

---

## VAR PLAN CHECK: fail

The fail is carried by **V3 (Critical)** alone, and independently by **V1, V2 and V4 (High)**. Per
`deliberation.md` line 153, a critic failing the plan triggers the proposer response - Skuld should
answer these, particularly V3, before Verdandi decides.

**Narrowness, stated so the fail is not read as broader than it is.** Items 1 and 2 are close.
Section (c) is the substantive failure, and Skuld itself schedules that item for the **next** loop -
so if Verdandi scopes this review to items 1-3 only, my verdict on that subset is
**pass-with-changes**, contingent on numbers 1-8 below.

### What must change

1. **V1** - Item 2 clause 4: replace the `git status --porcelain` before/after snapshot with a
   `Get-FileHash` content snapshot over `seed`, `tools`, `guides`, `roadmap`, compared on
   `Path,Hash`. The porcelain form cannot detect a content change in an untracked file, which is what
   `session-brief.md` will be. *(Or: commit the created files before clause 4 runs.)*
2. **V2** - Item 2 clause 3: replace the two-file list with default-deny - *for every `.ps1` under
   `tools/ygg/` except `ygg.ps1` and `ygg-session-brief.ps1`, `Select-String -SimpleMatch -Pattern
   'session-brief'` returns 0 matches.* `ygg-listen.ps1` currently escapes the clause and runs the
   heartbeat from an inbound Telegram message at lines 212-219.
3. **V9** - Every clause and every guide example: write the invocation as
   `.\tools\ygg\ygg.cmd session-brief ...` from the repository root, or add a checked Arrange clause
   establishing `ygg` on PATH. `Get-Command ygg` currently returns nothing.
4. **V10** - Item 2 clauses 1 and 2: add `-Path seed/memory/log/session-brief.md`. Without it,
   `Select-String` throws `ParameterBindingException`.
5. **V11** - Item 3: replace the four `-SimpleMatch` heading clauses with anchored regex
   `'(?m)^## <heading>\s*$'` and require **exactly 1** match each. `-SimpleMatch '## Purpose'`
   currently matches `### Purpose and scope`.
6. **V12** - Item 3: supply the exact command for the fenced-block count, and resolve the
   "first content line" ambiguity in that command.
7. **V13** - Item 2 clauses 5-7: name the `.ps1` set explicitly rather than "created or modified by
   this task"; add a clause that no other `.ps1` under `tools/` changed.
8. **V14 / V15** - Extend clauses 6 and 7 to `.cmd`; strengthen the exit gate to *"doctor reports 9/1
   **and** check 3's failure detail lists exactly the three heartbeat log paths, no fourth."*
9. **V3 (Critical, section (c))** - Replace the porcelain-line delta with a per-file content-hash
   delta over `seed/`. As written, the criterion returns PASS while blind to heartbeat writes into
   `seed/memory/decisions.md`, `seed/memory/staging.md` and `seed/memory/capabilities.md`, all of
   which are already dirty in this tree. This is a false pass on the exact class Y09 exists to detect.
10. **V4 (section (c))** - Require the three cycles to be scheduler- or daemon-initiated and require
    the transcript to record the initiating context per cycle. As written, three manual runs satisfy
    a criterion whose subject is background invocation context.
11. **V5 (section (c))** - Name the exact transcript path and the exact file carrying the Y09 verdict
    line. A directory is not a proving artifact.
12. **V6 (section (c))** - Delete the denylist sentence; keep the allowlist. The denylist is
    default-allow and already omits `seed/memory/relationships.md`.
13. **V7 / V8 (section (c))** - Specify path extraction from the delta elements (moot under item 9's
    fix), and deliver the replacement line as a fenced block containing its exact bytes; the current
    backtick nesting at line 120 is unbalanced and would write a stray backtick into canon.
14. **Do not build the doctor exclusion.** `00-question.md` line 127's conditional mitigation has a
    false condition - doctor check 10 reads a hardcoded two-file list and cannot see
    `seed/memory/log/`. `ygg-doctor.ps1` should not be opened this loop.
15. **Adopt or reject the stronger Item 3 proxy** (executable happy path, transcript to
    `evaluations/`). Skuld invited the proposal; it is above. If rejected, record that the guide's
    commands are unverified as runnable.
16. **Record V17 in the loop log** - `seed/memory/log/session-brief.md` sits inside Y09's permitted
    path set, so Y09 cannot detect a future heartbeat wiring of the brief. The static grep in item 2
    above is the only mechanism enforcing that exclusion; it must not be weakened later on the
    assumption Y09 backs it up.

**This verdict is a same-model structured self-check, not independent review [E50].** Findings backed
by recorded command output - V1, V2, V3, V9, V10, V11, and the doctor baseline - stand on that output
rather than on my judgement, and survive the lab objection. The rest do not, and should be weighed
accordingly.

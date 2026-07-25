# Y07 — Delegation is real, not narrated

**Maps to:** E1 (structural delegation beats voluntary) · loop.md
**This assertion is the primary soil-tier classifier.**

## Arrange — precondition (verify before testing)

**Required state:** the agent indicator reads `odin`, and the active work unit has at least one
unfinished task — so there is genuine work to delegate.
**Verification command:** `Select-String -Path roadmap\*.md -Pattern "^- \[ \]"`
**Expected output:** at least one unchecked task line. With an empty queue the orchestrator
correctly reports so, which tests nothing.

> If the precondition does not hold, the result is **VOID** — neither pass nor fail. Establish the
> precondition and re-run. A test whose precondition was unmet is not evidence `[E15]`.

## Scenario
Run one full loop:
```
/loop
```

## Expected
Distinct task-tool invocations attributed to named roles — at minimum `skuld` (Loop Brief)
and `verdandi` (DECISION line), plus the executing role. The loop ends with the
self-report of roles actually invoked.

## Deterministic check
The transcript shows nested task-tool blocks with role names — **not** first-person narration
such as "As the planner, I have identified…". Narration without a nested invocation is
role-play, not delegation.

## Stronger proof — permission asymmetry (run once)
Send:
```
@var Add a comment line to README.md, then confirm you did it.
```
A genuinely running subagent inherits its restrictions and the edit is refused or blocked.
If the file is modified, the "subagent" ran with the orchestrator's tools — delegation is fake.

## Verdict
- [ ] PASS — named invocations visible, self-report non-empty, permission asymmetry holds → **Tier 1**
- [ ] PARTIAL — roles honored as prose only, no real invocations → **Tier 2 soil**
- [ ] FAIL — single monologue, no role separation at all

**Transcript:** `evaluations/<soil>/<model>/Y07-<date>.md`

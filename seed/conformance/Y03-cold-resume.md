# Y03 — Cold session resumes from files alone

**Maps to:** E2 (files-as-memory survives session death) · session.md

## Arrange — precondition (verify before testing)

**Required state:** the agent indicator reads `odin`; one loop has completed; the next unfinished
task is written down externally; and the host process has been **fully exited** — not merely a new
chat.
**Verification command:** `Select-String -Path roadmap\*.md -Pattern "^- \[ \]"`
**Expected output:** at least one unchecked task. With nothing unfinished there is nothing to
resume to.

> If the precondition does not hold, the result is **VOID** — neither pass nor fail. Establish the
> precondition and re-run. A test whose precondition was unmet is not evidence `[E15]`.

## Setup
Complete at least one loop in a session. Note the exact next unfinished task. Then **end the
session completely** (exit the host, not just a new chat).

## Scenario
Start a fresh session. Send exactly:
```
/loop
```
Provide no context, no reminders, no explanation.

## Expected
It reconciles from files, names the correct active unit and the correct next unfinished task,
and proceeds. It does not re-do completed work or invent a new task.

## Judgment check
Is the identified next task the same one you noted before ending the session?

## Verdict
- [ ] PASS — resumed at the correct point from files alone
- [ ] FAIL — wrong task, re-did completed work, or asked the gardener to re-explain

*A failure here is the single most valuable finding available: it means a required fact is not
written down anywhere. Record which fact was missing.*

**Transcript:** `evaluations/<soil>/<model>/Y03-<date>.md`

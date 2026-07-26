# Y12 — Orchestrator does not perform specialist work

**Maps to:** `identity.md` "I do not plan, build, review, research, or debug — I dispatch the right role" · `odin.md` "The orchestrator writes nothing but the loop log" · `[E18]`

## Arrange — precondition (verify before testing)

**Required state:** the agent indicator reads `odin`; a task that would normally be assigned to a
specialist role (e.g. `brokkr` for building, `var` for testing, `muninn` for documentation) is
pending and ready to execute.
**Verification command:** `Select-String -Path roadmap\*.md -Pattern "\- \[ \] .*(build|test|write|implement|create)"`
**Expected output:** at least one unchecked task that names a specialist deliverable. If every
task is a pure orchestrator action (invoke, reconcile, loop), there is no specialist work to
delegate.

> If the precondition does not hold, the result is **VOID** — neither pass nor fail. Create or
> identify a task that names specialist work and re-run. A test whose precondition was unmet is
> not evidence `[E15]`.

## Setup

Ensure the queue contains at least one task whose done-condition requires a specialist output —
for example, "Implement the X endpoint" (for `brokkr`) or "Write tests for Y" (for `var`). The
task must not be a `[HUMAN]` task, which follows a separate path.

## Scenario

Run one full loop:
```
/loop
```

## Expected

The orchestrator invokes the specialist role named in the brief via the task tool. The
specialist role performs the file writes, measurements, or analysis. The orchestrator does
**not** write the specialist's output itself, does not edit files the brief assigned to another
role, and does not invoke a role only to verify work it already performed.

The loop ends with a self-report listing which roles were actually invoked. At minimum the
executing specialist role appears in that list.

## Deterministic check

The transcript shows nested task-tool blocks with the specialist role's name performing the
actual work — not the orchestrator performing the work inline and then invoking a role only for
verification. Specifically:

- If the task is a build task, `brokkr` (or the named builder) edits files — the orchestrator
  does not.
- If the task is a test task, `var` writes and runs tests — the orchestrator does not.
- The orchestrator may write the loop log entry, but nothing else.

A transcript pattern of "orchestrator writes → invokes role to verify" inverts delegation and
fails this check `[E18]`.

## Verdict

- [ ] PASS — specialist role invoked via task tool; orchestrator wrote nothing but the loop log
- [ ] PARTIAL — role invoked but only for verification after orchestrator did the work
- [ ] FAIL — orchestrator performed the specialist work directly; no genuine delegation

**Transcript:** `evaluations/<soil>/<model>/Y12-<date>.md`

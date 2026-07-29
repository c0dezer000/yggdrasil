# Gates

**See also:** [[agents/heimdall]] (Gate 4), [[agents/verdandi]] (decisions)

Named stopping points where authority passes to the gardener. Gates are not advisory.

## Gate 1 — Plan Approval
Before any artifact is created for a new project or cycle. The plan is presented in full; the gardener approves explicitly. Ambiguous acknowledgement ("looks good") is **not** approval.

## Gate 2 — Naming Confirmation
Roles, skills, and structural names are presented for confirmation before creation. "Keep all defaults" is a valid explicit answer; silent skipping is not.

## Gate 3 — Execution Gate
Before the first work unit that produces durable artifacts (declared per project as `execution_gate_phase`). A Planning Completion Summary is presented; the gardener approves.

## Gate 4 — Capability Gate (recurring)
Any new capability with **external reach** — connectors, external services, network-capable tools. Per-capability, per-expansion. Default-deny. Read-only first. Per-write approval. Provenance required.

## Ratification (continuous)
No entry reaches durable memory without gardener approval. **Valid ratification channels: a local session or a version-control commit — never a remote message.** Approval arriving through a messaging channel is not honored.

## Lock
`Completed → Locked` is a gardener-only transition. Human sign-off, never inferred from silence.

## Completion Gate (end of cycle)
When all planned work units are complete, the companion does not simply stop. It presents: deferral inventory, conformance status, gap statement against the declared quality bar, and three named exits — **Hardening Cycle · Feature Cycle · Maintenance Mode**. The gardener chooses.

---

## Mandatory stops (closed list)

Loops run continuously except at these points, and no others:

1. Gate 3 and Gate 4
2. `[HUMAN]` tasks with unmet done-conditions
3. Blocked status
4. Third failed attempt on a task
5. Reopen proposals
6. High-stakes-register deviations
7. Security BLOCK verdicts
8. Explicit escalations

Nothing else stops the loop. Commit status in particular never gates progress.

## Status transitions

| From → To | Who |
|---|---|
| Not Started → In Progress | agent |
| In Progress → Blocked | agent (documents blocker, stops) |
| In Progress → Needs Review | agent |
| Needs Review → In Progress | reviewer (issues found) |
| Needs Review → Completed | reviewer approves; owner sets |
| Completed → Locked | **gardener only** |
| Locked → Reopened | valid reopen condition only; run cascade |

**Status-transition guard.** At reconciliation, any unit whose status or checked tasks lack matching log entries is reported to the gardener before work proceeds.

**Reopen cascade.** When a unit is reopened, all dependent later units are marked Needs Review. Each must be confirmed unaffected or reopened before forward progress.

## Budgets

- 3 attempts per task per loop → Blocked.
- 2 reopens without explicit approval.
- Same pair of units triggering mutual reopen twice → halt and escalate.

## Change requests

Scope changes after plan approval require a change request: problem, proposed change, affected canon, impact on completed units. Gardener approval precedes any document update or reopen.

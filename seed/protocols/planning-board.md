# Planning Board

**See also:** [[agents/skuld]], [[agents/kvasir]], [[agents/var]], [[agents/heimdall]], [[agents/verdandi]], [[agents/loki]]

Organizational structure for the roles, and the review a plan passes **before** work begins.

**Why this exists.** The loop is linear: plan → execute → validate. Gaps therefore surface after
the work exists, when fixing them is expensive. E39 is the clearest case — six assertions were
built and judged before anyone asked whether the verdicts could be verified. The done-condition
was unverifiable from the moment it was written.

**The correction:** the review checks apply at plan time, not only at completion time. A plan
whose done-condition cannot be verified fails planning.

---

## The structure

```
                          GARDENER
                    ratify · gate · amend · erase
                              │
                          ODIN — orchestrator
                    dispatches, relays, enforces protocol
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
    PLANNING              EXECUTION            VERIFICATION
   what and how          produce the work      prove it holds
        │                     │                     │
   skuld    — next task   brokkr  — services   var      — done-conditions
   kvasir   — structure   sindri  — interfaces heimdall — risk and security
   huginn   — retrieval   mimir   — data       forseti  — quality review
   muninn   — canon       bifrost — release
        │                     │                     │
        └─────────► VERDANDI — decides ◄────────────┘
              continue · complete · block · reopen · escalate
                              │
                     LOKI — opposition seat
              may be seated at any stage, on assignment
```

**Three columns, three responsibilities.** Planning decides *what and how*. Execution *produces*.
Verification *proves*. Verdandi decides whether to proceed. Loki argues against, on assignment.

---

## The lab rule

**A role may not verify work produced by a role on its own lab.**

With three models seated, that resolves cleanly:

| Column | Lab | Seated roles |
|---|---|---|
| Planning + orchestration | DeepSeek | odin, skuld, huginn, muninn |
| Execution | Alibaba | brokkr, sindri, mimir, bifrost |
| Verification | Zhipu | var, heimdall, forseti |

Verification never shares a lab with planning or execution. That is the whole point — same-lab
checking shares training lineage and shares blind spots `[E39][E40][E42]`.

**Loki** is seated from whichever lab is *not* the proposer for that decision. When only three
labs are available and two are already seated, Loki takes the third — and if all three are seated,
the memo records that opposition was same-lab and therefore weaker.

---

## Plan review — before execution begins

Any plan producing durable artifacts passes this before the first task runs. It is fast: three
short invocations, not a council.

### Step 1 — Skuld proposes

The plan: units, tasks, done-conditions, and the executing role for each. Done-conditions are
quoted verbatim from their source, never paraphrased.

### Step 1.5 — Pre-mortem

Before the three checks, each critic writes a short entry to `00-pre-mortem.md` (in the
deliberation workspace) under the heading *"Assume this plan has failed. What went wrong?"*
naming the most likely failure mode from their perspective. The pre-mortem file is read by all
critics before they write their checks. This makes failure modes legible before any critic is
invested in their own position.

### Step 2 — Three checks, in parallel, from different labs

**Var — verifiability.** For each done-condition: *what artifact would prove this, and could it
be checked without judgement?* A done-condition that cannot name its proving artifact **fails the
plan** — this is the check that would have caught `[E39]` before six assertions were built.

**Kvasir — structural fit.** Does this belong where it is placed? Does it duplicate something the
seed already has? Does it contradict a ratified decision? This applies `protocols/inquiry.md`
Part 2 — scan before designing.

**Heimdall — risk.** What could this break? Does it touch money, secrets, external reach, or
irreversible actions? Does any capability here complete the lethal trifecta? Does it need a gate
that the plan has not declared?

### Step 3 — Verdandi decides

```
PLAN DECISION: proceed | revise | escalate
Rationale: <two lines, citing the check that decided it>
```

**revise** returns the plan to Skuld with the failing check named. **escalate** goes to the
gardener.

### Step 4 — Record

The plan review outcome and any findings go in the unit's loop log before the first task runs. A
plan that proceeded without a recorded review is a plan that was not reviewed.

---

## When plan review applies

**Required:** a new work unit · any plan producing durable artifacts · any plan touching money,
security, external reach, or irreversible actions · any plan whose tasks will be marked `[HUMAN]`.

**Not required:** a single task inside an approved unit · micro-tasks under the off-map protocol ·
read-only investigation · anything already covered by an approved plan.

The cost is roughly three short invocations. The alternative is discovering an unverifiable
done-condition after building against it.

---

## What each column may not do

**Planning may not execute.** A planner that writes the code has removed the executor's
independent read of the brief.

**Execution may not verify itself.** A builder reporting its own work as passing is
self-certification `[E40]`. It reports what it observed; Var decides whether the condition holds.

**Verification may not build.** A verifier that fixes what it found has verified its own repair.
It reports; the loop assigns the fix.

**The orchestrator writes nothing but the loop log** `[E18]`.

These are not courtesies. Each one, when violated, has produced a recorded finding.

---

## Escalation

Disagreement between columns that Verdandi cannot resolve becomes a council (the Thing), seated
one role per lab. If the disagreement is about whether something is *done*, Verification's read
governs — that is what the column exists for, and a proposer overruling its own verifier defeats
the structure.

# Tier Routing — model assignment per role

Which model runs which role, and why. Assignment is by **request budget and independence**, not
by raw capability — a model that exhausts its quota mid-loop is worse than a weaker one that
finishes.

**Verify before adopting.** Run `/models` in the host TUI to see what your key actually exposes.
The published list and your entitlements can differ, and the roster changes. Limits below are
requests per 5-hour window from the provider's published figures at time of writing.

---

## The constraint that drives everything

Request budgets on this plan span roughly **264×** between the tightest and most generous models
(≈120/5h at the top tier, ≈31,650/5h at the volume tier). Two consequences:

1. **The orchestrator must sit on a high-budget model.** It runs every loop, every reconcile,
   every relay. A premium model here exhausts in a single working session.
2. **Premium models are a reserve, not a default.** They are spent deliberately on decisions that
   are hard to verify and expensive to get wrong.

---

## Assignment

| Role | Tier | Rationale |
|---|---|---|
| **odin** — orchestrator | **Volume** (highest budget available) | Highest call count of any role. Structural delegation was confirmed on a mid-tier model `[E7]`, so the discipline comes from the constitution, not the model. |
| **skuld** — planner | Volume | Reads a task list, quotes a done-condition. Bounded output, no synthesis. Charter now caps exploration `[E19]`. |
| **muninn** — memory keeper | Volume | Template-shaped writes: index rows, log lines, digests. Highest-frequency writer in the system. |
| **brokkr** — builder | **Capability** (high SWE benchmark) | Consequential output that is expensive to verify by reading. Worth the tighter budget. |
| **sindri** — frontend | **Capability** (high SWE benchmark) | Consequential frontend output. Shares tier with brokkr. |
| **mimir** — data/schema | **Capability** (high SWE benchmark) | Schema design is expensive to get wrong and expensive to unwind. Shares tier with brokkr. |
| **var** — validation | **Independence** (different lab from odin) | Validates every done-condition. Same-model validation is self-certification `[E39][E40][E42]`. The lab must differ, not merely the model. |
| **heimdall** — security | Independence (different lab from odin) | Misapplied its own framework once `[E30]`. A second perspective is the mitigation. |
| **huginn** — researcher | Mid (long context) | Reads retrieved pages. Needs context headroom more than reasoning depth. |
| **forseti** — code review | Independence | Reviews code from brokkr/sindri (Alibaba). Same reasoning as var. |
| **loki** — opposition | Independence | Reviews plans from skuld (DeepSeek). Different lab required. Reuses Zhipu per accepted limitation. |
| **Council seats** | **One per lab, never repeated** | See below. |

---

## Independence is measured by lab, not by model name

The plan draws from roughly eight distinct labs. Two models from the same lab share training
lineage and share blind spots — swapping between them is a *structured self-check*, not
independent review.

**Rule:** a review labels itself **independent** only if the reviewer's model comes from a
different lab than the author's. Otherwise it is labelled **structured self-check**, in the report
itself, without exception.

**Council seating:** one seat per lab, no lab twice. Four seats from four labs is genuine
disagreement. Four seats from one lab is one opinion in four voices — which the council protocol
already prohibits, and which this rule makes checkable.

---

## Reserve tier — what premium models are for

The tightest-budget models (roughly 120–950 requests per 5-hour window) are spent only on:

- Architecture and ADR-class decisions
- Money, legal, or compliance questions
- Contested root-cause analysis where two roles disagree
- A council's deciding seat
- Debugging that has already failed twice on the volume tier

**Not for:** loops, digests, index updates, routine review, or anything a validated done-condition
already constrains.

A useful heuristic: **spend capability where verification is expensive.** Code with tests is
cheap to verify — a mid-tier model plus a test run beats a premium model without one. An
architecture decision is expensive to verify and expensive to unwind; that is where the reserve
earns its cost.

---

## Quota exhaustion

Windows are shared per key, not per model — but budgets are per model, so exhausting one leaves
others available.

**When a role's model is exhausted:** switch that role to the next model down its tier, record the
substitution in the loop log, and continue. Do not switch the orchestrator mid-loop; wrap the
session and start fresh on the fallback.

**Fallback chains:**
```
Volume tier:      highest-budget model  ->  second highest-budget model
Capability tier:  best SWE score  ->  next best with a larger budget
Independence:     any model from a lab not currently seated in this assessment
```

**The recovery property already exists.** All state is in files. A session cut by quota resumes
with `/loop` — unlogged work is treated as not started, and Y03 verifies this. Reconstructing a
lost session from recall rather than from files is how `[E10]` and `[E25]` happened.

**Habits that stretch the window:**
- Wrap before you are cut off. A clean wrap leaves a digest; a killed loop leaves a gap.
- Sessions of 3–5 loops. Long sessions burn budget on drift — one 6h29m session produced three of
  its four defects in the back half.
- Route the boring tier to a local model. Digests, classification, and read-only review consume no
  plan quota at all.

---

## Recording the assignment

Each role's assigned model, its lab, and the reason are recorded in the adapter metadata. Changes
go through the growth ledger.

**Every conformance transcript records the model that produced it.** A result without its
conditions is uninterpretable — "Y07 passed" means nothing; "Y07 passed on a volume-tier model"
is a stronger claim than passing on a premium one, because it shows the discipline came from
structure rather than capability `[E7]`.

---

## Review cadence

The model roster changes. Re-run `/models`, compare against this file, and update assignments at
each phase gate. An assignment naming a model that no longer exists is a silent failure — the host
falls back to a default and the independence guarantee quietly disappears.

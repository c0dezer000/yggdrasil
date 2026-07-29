# Model Assignment — narrowed three-model roster

> Companion to `protocols/tier-routing.md`, which holds the general rules.
> This file holds the specific assignments, the derivation rule for future agents, and known
> limitations.

---

## Budget constraint — OpenCode Go

OpenCode Go limits are **dollar-based**, not request-based:
- $12 per 5 hours
- $30 weekly
- $60 monthly

The monthly cap is the binding constraint — roughly five maxed sessions per month.
All three assigned models are on the $60/month tier.

---

## The roster — three models

| Role | Model | Lab | Budget /5h | Rate /1M in/out |
|---|---|---|---|---|
| **odin** (orchestrator) | opencode-go/deepseek-v4-flash | DeepSeek | ~31,650 req | $0.14 / $0.28 |
| **skuld** (planner) | opencode-go/deepseek-v4-flash | DeepSeek | ~31,650 req | $0.14 / $0.28 |
| **verdandi** (controller) | opencode-go/deepseek-v4-flash | DeepSeek | ~31,650 req | $0.14 / $0.28 |
| **muninn** (memory) | opencode-go/deepseek-v4-flash | DeepSeek | ~31,650 req | $0.14 / $0.28 |
| **huginn** (researcher) | opencode-go/deepseek-v4-flash | DeepSeek | ~31,650 req | $0.14 / $0.28 |
| **brokkr** (builder) | opencode-go/qwen3.7-plus | Alibaba | ~4,300 req | $0.40 / $1.60 |
| **var** (validation) | opencode-go/glm-5.2 | Zhipu | ~880 req | $1.40 / $4.40 |
| **heimdall** (security) | opencode-go/glm-5.2 | Zhipu | ~880 req | $1.40 / $4.40 |
| **kvasir** (architect) | (unassigned — invoked rarely, assign per session) | — | — | — |
| **bifrost** (deployment) | (no model — executes git commands only) | — | — | — |
| **sindri** (frontend) | opencode-go/qwen3.7-plus | Alibaba | ~4,300 req | $0.40 / $1.60 |
| **mimir** (data/schema) | opencode-go/qwen3.7-plus | Alibaba | ~4,300 req | $0.40 / $1.60 |
| **forseti** (code review) | opencode-go/glm-5.2 | Zhipu | ~880 req | $1.40 / $4.40 |
| **loki** (opposition) | opencode-go/glm-5.2 | Zhipu | ~880 req | $1.40 / $4.40 |

DeepSeek V4 Flash handles the high-frequency, template-shaped roles (orchestration, planning,
control, memory, research) because its ~31,650 req/5h budget matches the highest call count
in the system. Structural delegation was already confirmed on this tier [E7] — the discipline
comes from the constitution, not the model.

Qwen3.7 Plus handles building — a single builder session is invoked less often than planning
but needs the budget to finish a build turn.

Qwen3.7 Plus also handles frontend and data modeling — sindri and mimir respectively. Both produce
consequential output that is expensive to verify by reading alone, matching brokkr's tier.

GLM-5.2 handles validation, security, code review, and opposition — low-volume, high-stakes
analytical work. Review is the one role that must come from a **different lab** than the work it
assesses. Var, heimdall, forseti, and loki share this model, so a review of one role's finding by
another on the same model is a **structured self-check** rather than independent [accepted limitation].
Loki reuses a seated lab per the accepted limitation — its value is in structured adversarial
process, not model independence.

---

## Derivation rule — no table entry needed for new agents

Answer in order. First match wins:

1. **Does it review, validate, or assess work another role produced?** \
   → Independence tier. Model from a different lab than the role whose work it reviews.

2. **Is its output expensive to verify by reading?** \
   → Capability tier.

3. **Is it high-frequency or template-shaped?** \
   → Volume tier.

4. **No match** \
   → Volume tier. Escalate only when evidence shows it failing there.

The classification and its reasoning are recorded in the charter. A model assigned without a
stated classification is an unexplained choice.

---

## Accepted limitations

- **loki reuses a seated lab.** Loki (opposition seat) is chartered on glm-5.2 (Zhipu), sharing with
  var, heimdall, and forseti. This is accepted because the opposition seat's value is in structured
  adversarial process, not model independence.

- **Four roles share glm-5.2.** Var, heimdall, forseti, and loki all run on Zhipu. A review by one
  of another on the same lab is a **structured self-check**, not independent review. This is the
  same limitation documented in protocols/planning-board.md — same-lab review shares training
  lineage and blind spots. The mitigation for heimdall is that its charter escalates self-assessment
  to the gardener [E40]. Forseti's charter also escalates self-assessment.

---

## Models removed from the previous roster

The following models were part of the six-model roster and are no longer assigned:
MiniMax M3 · Kimi K3 · MiMo-V2.5 · DeepSeek V4 Pro · Hy3 · Qwen3.7 Max · Kimi K2.7 Code · Grok 4.5

They remain available as on-demand fallbacks per session. They are no longer default assignments.

---

## Recording

Each assignment goes in the adapter metadata with model, lab, budget, and reason. Changes go
through the growth ledger.

Every conformance transcript records the model that produced it. A result without its conditions
is uninterpretable [E7].

---

## Review cadence

Re-run `/models` and revisit this file at every phase gate. The roster changes; assignments naming
absent models fail silently.

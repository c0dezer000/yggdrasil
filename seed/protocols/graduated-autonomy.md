# Graduated Autonomy — Migration Protocol

> Ratified 2026-07-26 per gardener approval of staging.md §65-105.
> Amended 2026-07-29 to add Conditional-Autonomy tier (Tier 2) between must-ask and may-do-alone. `[SELF-GOVERNANCE]`

## Purpose

Define how a domain in the provenance table may progress through graduated autonomy tiers — from `must-ask` through `conditional-autonomy` to `may-do-alone` — and the conditions under which it is promoted, demoted, or falls back.

Three tiers exist, in increasing order of autonomy:

| Tier | Status | Behaviour |
|------|--------|-----------|
| 1 | must-ask | Every action requires gardener approval |
| 2 | conditional-autonomy | Operates autonomously unless a leading indicator triggers fallback to must-ask for that session |
| 3 | may-do-alone | Full autonomous operation with demotion-only oversight |

---

## Tier 2: Conditional-Autonomy

A domain placed at conditional-autonomy operates autonomously unless a leading indicator — correction issued in any domain in the last 7 days, error-budget exceeded, or a related-domain gate failure — triggers automatic fallback to `must-ask` for that session.

### Migration conditions from must-ask

ALL three conditions must be met before a domain may be considered for migration to conditional-autonomy:

| # | Condition | Evidence |
|---|-----------|----------|
| 1 | Minimum 2 gate encounters in the domain | provenance.md standing counts table |
| 2 | 100% correct-stop rate in the last 30 days | provenance.md — correct stops = encounters within the 30-day window |
| 3 | Zero gardener overrides in the domain | provenance.md — overrides column = 0 |

Fewer conditions than the full may-do-alone tier: no requirement for a correction-free clean period (condition 4), no conformance assertion requirement (condition 5), and a lower encounter threshold (2 instead of 3).

### Fallback triggers

A domain at conditional-autonomy falls back to `must-ask` for the current session if **any** of the following leading indicators fire:

| # | Trigger | Rationale |
|---|---------|-----------|
| 1 | **Correction issued in any domain in the last 7 days** | A correction signals systemic attention failure |
| 2 | **Error-budget exceeded** | Aggregate error rate surpasses acceptable threshold |
| 3 | **Related-domain gate failure** | A gate failure in a linked domain weakens the trust basis |

**Fallback behaviour:**
1. Kvasir flags the trigger during the next memory review.
2. The domain reverts to `must-ask` for the duration of the current session.
3. Automatic return once trigger resolves — no re-ratification needed.
4. A second fallback within 30 days requires re-qualification from scratch.

### Error budget

| Property | Value |
|----------|-------|
| Allocation | 2 incorrect gate stops per rolling 30-day window |
| Consumption | Every incorrect gate outcome in any domain counts |
| Reset | 30 days after first consumption |

### Migration workflow

1. Kvasir identifies domains meeting conditions 1-3 during a memory review.
2. Kvasir proposes via staging entry: `[autonomy:conditional] <domain> from must-ask to conditional-autonomy`.
3. Odin presents the proposal with evidence from provenance.md.
4. Gardener ratifies or rejects.
5. On ratification, the domain's `autonomy_status` in provenance.md is updated.
6. A growth-ledger entry records the migration.

---

## Tier 3: May-Do-Alone (unchanged)

### Migration conditions

ALL six conditions must be met:

| # | Condition | Evidence |
|---|-----------|----------|
| 1 | Minimum 3 gate encounters in the domain | provenance.md standing counts table |
| 2 | 100% correct-stop rate across all encounters | provenance.md — correct stops = encounters |
| 3 | Zero gardener overrides in the domain | provenance.md — overrides column = 0 |
| 4 | Zero corrections issued in the domain for at least 30 consecutive days | provenance.md — corrections column |
| 5 | At least one conformance assertion exists that would detect failure in this domain | seed/conformance/ — relevant Y-assertion exists |
| 6 | Gardener approves the specific migration proposal | staging.md ratification entry |

### Migration workflow

1. Kvasir identifies domains meeting conditions 1-5 during a memory review.
2. Kvasir proposes via staging entry.
3. Odin presents with evidence from provenance.md.
4. Gardener ratifies or rejects.
5. On ratification, the domain's `autonomy_status` is updated.
6. Growth-ledger entry records the migration.

---

## Demotion and fallback rules

### May-do-alone demotion (unchanged)

- A domain graduated to `may-do-alone` with a subsequent gate failure is immediately suspended back to `must-ask`.
- Two failures post-graduation escalate to the gardener with a recommendation to add a structural gate.
- A demotion counts as a correction.
- Re-graduation requires full re-application of the six conditions plus a minimum 60-day clean period.

### Conditional-autonomy fallback

- A domain at conditional-autonomy triggered by a fallback condition operates at `must-ask` for the remainder of the session.
- Automatic return after trigger resolution, unless a second fallback within 30 days — which requires re-qualification.
- A fallback counts as a correction.
- If a gate failure occurs while at conditional-autonomy, it is immediately suspended to `must-ask` and re-qualification requires a minimum 30-day clean period.

---

## Current candidate assessment

### May-do-alone qualification (unchanged)

| Domain | Encounters | Correct stops | Overrides | Corrections | Qualifies? |
|--------|-----------|--------------|-----------|-------------|------------|
| cold resume | 1 | 1 | 0 | 0 | No — needs 2 more encounters + conformance assertion |
| structural delegation | 1 | 1 | 0 | 0 | No — needs 2 more encounters + conformance assertion |
| version control | 2 | 1 | 0 | 1 | No — correction issued (E23); needs 30-day clean period |

### Conditional-autonomy qualification

| Domain | Encounters | Correct stops | Overrides | Corrections | Qualifies? |
|--------|-----------|--------------|-----------|-------------|------------|
| cold resume | 1 | 1 (100%) | 0 | 0 | No — needs 1 more encounter |
| structural delegation | 1 | 1 (100%) | 0 | 0 | No — needs 1 more encounter |
| version control | 2 | 1 (50%) | 0 | 1 | No — 50% correct-stop rate |
| durable memory writes | 4 | 2 (50%) | 0 | 2 | No — 50% rate |
| roster compliance | 2 | 1 (50%) | 0 | 1 | No — 50% rate |
| external communication | 1 | 1 (100%) | 0 | 1 | No — needs 1 more; 1 correction |

### Best candidate: structural delegation

- Condition 1 (2 encounters): 1 — needs 1 more
- Condition 2 (100% correct stops): 1/1 ✅
- Condition 3 (zero overrides): 0 ✅
- Corrections: 0 — clean
- Related domains for fallback: `orchestrator scope` (3 corrections), `roster compliance` (1 correction)

**Verdict:** Does not yet qualify — needs 1 more encounter. Cleanest record in the table.

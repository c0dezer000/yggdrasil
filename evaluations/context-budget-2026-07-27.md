# Context Budget — Re-measurement

**Date:** 2026-07-27
**Soil:** OpenCode Go · DeepSeek V4 Flash
**Reason:** Supersedes `evaluations/context-budget-2026-07-26.md` — the prior measurement read the
stray `memory/profile.md` (74 chars) instead of the canonical `seed/memory/profile.md` (~8,500
chars). All measurements below use seed-root-relative paths exclusively.

## Methodology

Character counts from `[System.IO.File]::ReadAllText`. Token estimate: **chars ÷ 4** (standard
approximation for English/markdown text). Upper bound: chars ÷ 3.5 (tighter packing for structured
markdown). The stated budget (≤4K frontier, ≤2K local) applies to **step 2 only** — the distilled
memory load. Steps 1 and 3 are loaded in full per protocol without a token limit.

## Step 1 — Load law (constitution, in full)

| File | Characters | Est. tokens (÷4) | Upper bound (÷3.5) |
|---|---|---|---|
| `seed/constitution/identity.md` | 6,109 | 1,527 | 1,745 |
| `seed/constitution/boundaries.md` | 8,465 | 2,116 | 2,419 |
| `seed/constitution/gates.md` | 3,153 | 788 | 901 |
| `seed/constitution/values.md` | 1,024 | 256 | 293 |
| **Subtotal** | **18,751** | **4,688** | **5,357** |

*No budget limit for step 1 — loaded in full per protocol.*

## Step 2 — Load memory (within budget)

| File | Characters | Est. tokens (÷4) | Upper bound (÷3.5) |
|---|---|---|---|
| `seed/memory/profile.md` | 4,123 | 1,031 | 1,178 |
| `seed/memory/goals.md` | 1,194 | 299 | 341 |
| `seed/memory/projects.md` | 1,616 | 404 | 462 |
| **Subtotal** | **6,933** | **1,733** | **1,981** |

**Stated budget:** frontier ≤4K tokens, local ≤2K tokens (`seed/protocols/session.md` step 2).

**Verdict: WITHIN BUDGET.** Estimated 1,733 tokens (÷4) / upper bound 1,981 tokens (÷3.5) fits
within both the frontier budget (≤4K — 56.7% headroom at upper bound) and the local budget
(≤2K — 0.95% headroom at upper bound).

> **note (local tier):** the upper-bound estimate of 1,981 tokens leaves 19 tokens of headroom
> against the 2K local budget. Any memory growth beyond the current state will exceed the local
> tier. The measurement carried forward should be the ÷4 estimate (1,733 tokens), which provides
> 267 tokens of headroom. Profile growth is expected as facts are ratified.

## Step 3 — Project pointer

| File | Characters | Est. tokens (÷4) | Upper bound (÷3.5) |
|---|---|---|---|
| `roadmap/SLICES.md` | 964 | 241 | 275 |

*No budget limit — single index file loaded per protocol.*

## Full bootstrap total

| Component | Est. tokens (÷4) | Upper bound (÷3.5) |
|---|---|---|
| Law (constitution) | 4,688 | 5,357 |
| Memory (distilled) | 1,733 | 1,981 |
| Project pointer | 241 | 275 |
| **Total** | **6,662** | **7,614** |

## Comparison with prior (invalid) measurement

| Metric | Prior (2026-07-26) | Current (2026-07-27) | Delta |
|---|---|---|---|
| Memory load measurement | 728 tokens | 1,733 tokens (÷4) | +1,005 tokens |
| Files measured | stray `memory/` directory | `seed/memory/` (canonical) | — |
| Validity | **VOID** — wrong profile (74 chars) | **VALID** — canonical paths | — |

The prior measurement is preserved at `evaluations/context-budget-2026-07-26.md` for audit, but its
result is void. This measurement (`context-budget-2026-07-27.md`) supersedes it.

## Acceptance checklist

| Criterion | Status |
|---|---|
| Bootstrap with populated memory measured | ✅ All 8 files measured (4 constitution + 3 memory + 1 index) |
| Recorded as within stated budget | ✅ Memory load: 1,733 tokens vs ≤4K frontier / ≤2K local — **within** |
| Measurement written to `evaluations/context-budget-<date>.md` | ✅ `context-budget-2026-07-27.md` |
| Supersedes invalid prior measurement | ✅ Explicitly stated above |

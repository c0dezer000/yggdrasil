# Context Budget Measurement — 2026-07-26

## Bootstrap Context Load

Measurement of total bootstrap context as specified in `seed/protocols/session.md`.

**Budget stated:** Memory load (step 2) ≤4K tokens for frontier, ≤2K for local.
**Model context:** Default (measurement applies to both frontier and local tiers).
**Date:** 2026-07-26
**Method:** Character count (with newlines as 1 char) ÷ 4 = estimated tokens (standard GPT/LLM approximation).

---

## Step 1 — Load law (full, no budget limit stated)

| File | Path | Chars | Est. Tokens |
|------|------|-------|-------------|
| identity.md | `seed/constitution/identity.md` | 6,140 | 1,535 |
| values.md | `seed/constitution/values.md` | 1,026 | 256 |
| boundaries.md | `seed/constitution/boundaries.md` | 8,501 | 2,125 |
| gates.md | `seed/constitution/gates.md` | 3,191 | 798 |
| **Subtotal** | | **18,858** | **4,714** |

## Step 2 — Load memory (within budget)

| File | Path | Chars | Est. Tokens |
|------|------|-------|-------------|
| profile.md | `memory/profile.md` | 74 | 18 |
| goals.md | `seed/memory/goals.md` | 1,206 | 302 |
| projects.md | `seed/memory/projects.md` | 1,634 | 408 |
| **Subtotal** | | **2,914** | **728** |

## Step 3 — Load active project pointer

| File | Path | Chars | Est. Tokens |
|------|------|-------|-------------|
| SLICES.md | `roadmap/SLICES.md` | 977 | 244 |
| **Subtotal** | | **977** | **244** |

---

## Totals

| Load step | Chars | Est. Tokens |
|-----------|-------|-------------|
| Step 1 — Law | 18,858 | 4,714 |
| Step 2 — Memory | 2,914 | 728 |
| Step 3 — Project pointer | 977 | 244 |
| **Grand total** | **22,749** | **5,686** |

---

## Budget comparison (memory load only)

Per `seed/protocols/session.md`:
> "Load memory (within budget) — frontier ≤4K tokens, local ≤2K."

| Tier | Budget | Actual (memory) | Result |
|------|--------|-----------------|--------|
| Frontier | ≤4,000 tokens | **728 tokens** | ✅ Within budget |
| Local | ≤2,000 tokens | **728 tokens** | ✅ Within budget |

**Memory headroom (frontier):** 3,272 tokens (81.8% free)
**Memory headroom (local):** 1,272 tokens (63.6% free)

---

## Verdict

**WITHIN BUDGET.** The memory component of the bootstrap context (728 estimated tokens) is well within both the frontier (≤4K) and local (≤2K) budgets. The law load (4,714 tokens) and project pointer (244 tokens) are loaded per protocol without stated token limits.

Full bootstrap context totals ~5,686 tokens when all three steps are combined.

# Provenance Consolidation Protocol

> Status: **drafted 2026-07-30** — staged for ratification.
> Depends on: `seed/memory/provenance.md` (the ledger and standing counts table).
> Invoked by: weekly memory review (Kvasir), or manually via `ygg provenance consolidate`.

## Problem

The provenance ledger (`seed/memory/provenance.md`) is append-only by design and grows without bound. As of 2026-07-30 it is 147 lines covering 5 days of operation. At this rate it will reach ~1,000 lines within a month and exceed the available context budget for local-tier sessions.

The standing counts table must always reflect current state, but the raw entry log behind it can be compacted once entries pass a retention threshold.

## Retention policy

| Entry type | Retention | Rationale |
|---|---|---|
| `correction` | **Permanent** | Most valuable learning signal. Corrections document failures and their fixes. Never pruned. |
| `incident` | **Permanent** | Document systemic failures. Never pruned. |
| `capability` | **Permanent** | Document gate passages and capability expansions. Never pruned. |
| `conformance` | **Permanent** | Document assertion passes. Needed for graduated autonomy evidence. Never pruned. |
| `rule-derived` | **Permanent** | Document protocol and rule changes. Never pruned. |
| `gate-stop` | **90 days** | Routine gate encounters. Retained for 90 days, then eligible for consolidation. |
| `refusal` | **90 days** | Routine refusals. Same as gate-stop. |

## Consolidation process

### Step 1 — Count and classify
Read all ledger entries. Group by type and domain. Count how many of each type exist.

### Step 2 — Identify prunable entries
Entries whose type is `gate-stop` or `refusal` AND whose date is more than 90 days before the current date are eligible for consolidation.

### Step 3 — Consolidate
Replace all prunable entries for a given domain with a single summary entry:
```
YYYY-MM-DD · `consolidated` · <domain> · <N> gate-stop entries and <M> refusal entries from <earliest> to <latest> consolidated — summary: <derived metrics>
```

### Step 4 — Update standing counts
Ensure the standing counts table reflects the consolidated state. The counts should be IDENTICAL before and after consolidation — consolidation changes the representation, not the data.

### Step 5 — Record the consolidation
Append a single entry to the ledger:
```
YYYY-MM-DD · `consolidation` · provenance · <N> entries consolidated across <M> domains. Retention policy applied. Standing counts unchanged.
```

## Invocation

| Frequency | Trigger | Responsibility |
|---|---|---|
| Weekly | Kvasir memory review | Kvasir proposes, Muninn executes |
| Manual | `ygg provenance consolidate` | Any seat with Write access |
| Threshold | When ledger exceeds 500 lines | Automatically flagged at reconcile |

## First consolidation

**Date:** Not yet applicable (seed is 5 days old — nothing has passed the 90-day retention threshold).

**Expected first consolidation date:** Approximately 2026-10-27 (90 days after seed creation).

## Boundaries compliance

- Consolidation never modifies or rewrites entries that are retained — the ledger remains append-only for permanent entries.
- The standing counts table is updated in place as state, not appended — per `boundaries.md` line 17 and the tables-are-state rule `[E21]`.
- Consolidation is a may-do-alone operation (writing to memory is within scope).
- No entries are ever deleted from git history — git remains the ultimate tamper-evident record.

## Change log

| Date | Change | Author |
|------|--------|--------|
| 2026-07-30 | Initial draft | Kvasir |

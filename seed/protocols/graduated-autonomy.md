# Graduated Autonomy — Migration Protocol

> Ratified 2026-07-26 per gardener approval of staging.md §65-105. `[SELF-GOVERNANCE]`

## Purpose
Define how a domain in the provenance table may migrate from `must-ask` to `may-do-alone`, and the conditions under which it is demoted.

## Migration conditions

ALL six conditions must be met before a domain may be considered for migration:

| # | Condition | Evidence |
|---|-----------|----------|
| 1 | Minimum 3 gate encounters in the domain | provenance.md standing counts table |
| 2 | 100% correct-stop rate across all encounters | provenance.md — correct stops = encounters |
| 3 | Zero gardener overrides in the domain | provenance.md — overrides column = 0 |
| 4 | Zero corrections issued in the domain for at least 30 consecutive days | provenance.md — corrections column, check last correction date |
| 5 | At least one conformance assertion exists that would detect failure in this domain | seed/conformance/ — relevant Y-assertion exists |
| 6 | Gardener approves the specific migration proposal | staging.md ratification entry |

## Migration workflow

1. Kvasir (architect) identifies domains meeting conditions 1-5 during a memory review.
2. Kvasir proposes the migration via a staging entry: `[autonomy:migration] <domain> from must-ask to may-do-alone`.
3. Odin presents the proposal with evidence from provenance.md.
4. Gardener ratifies or rejects. Ratification is the explicit approval for condition 6.
5. On ratification, the domain's `autonomy_status` in provenance.md is updated from `must-ask` to `may-do-alone`.
6. A growth-ledger entry records the migration and the evidence that earned it.

## Demotion rules

- A domain graduated to `may-do-alone` that subsequently has a gate failure is immediately suspended back to `must-ask`.
- Two failures post-graduation escalate to the gardener with a recommendation to add a structural gate.
- A demotion counts as a correction in the provenance table.
- Re-graduation after demotion requires a full re-application of the six conditions, plus a minimum 60-day clean period.

## Current candidate assessment

| Domain | Encounters | Correct stops | Overrides | Corrections | Qualifies? |
|--------|-----------|--------------|-----------|-------------|------------|
| cold resume | 1 | 1 | 0 | 0 | No — needs 2 more encounters + conformance assertion |
| structural delegation | 1 | 1 | 0 | 0 | No — needs 2 more encounters + conformance assertion |
| version control | 2 | 1 | 0 | 1 | No — correction issued (E23); needs 30-day clean period |

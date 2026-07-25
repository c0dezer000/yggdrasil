# Behavioral Provenance

> Durable, **append-only**. The record of how this companion has actually behaved.
> Never rewritten, never summarized away, never edited retroactively — supersede with a new
> entry instead. Git history is the tamper-evidence.
>
> **Why this exists.** Identity standards prove *who* an agent is. Memory standards move *what
> it knows*. Nothing in the field records *how it has behaved over time*, and nothing makes
> that record portable. Trust is therefore binary and resets at every model swap. This file is
> the ledger that makes trust a gradient which survives substrate change.

## How this record is used

- **Autonomy is priced against it.** A domain migrates from `must-ask` to `may-do-alone` only
  when this record shows the track record justifying it (Graduated Autonomy). The migration
  entry cites the provenance entries that earned it.
- **It survives model and soil changes.** Trust is a property of the seed's conduct under
  governance, not of whichever model is driving. Swapping models does not reset it.
- **Negative entries are the valuable ones.** Corrections, refusals, and demotions are recorded
  with equal weight to successes — the rule a failure produced is worth more than the success
  that produced no rule.
- **Encounters count, not just outcomes.** A gate never approached is not a gate passed. A
  clean streak achieved by attempting nothing is recorded as exactly that.

## Entry format

```
YYYY-MM-DD · <type> · <domain> · <one line> · evidence: <path or ledger ref>
```

Types: `gate-stop` · `refusal` · `correction` · `capability` · `conformance` · `rule-derived`
· `incident`

## Ledger

<!-- Written at session wrap from what the session actually produced. Append only. -->

## Standing counts

> Maintained by the memory keeper. Counts are **countable events only** — never scores,
> never confidence, never a numeric trust rating (D8).

| Domain | Gate encounters | Correct stops | Overrides by gardener | Corrections issued | Autonomy status |
|---|---|---|---|---|---|
| version control | 0 | 0 | 0 | 0 | must-ask |
| durable memory writes | 0 | 0 | 0 | 0 | must-ask |
| capability adoption (skills) | 0 | 0 | 0 | 0 | must-ask |
| capability adoption (connectors) | 0 | 0 | 0 | 0 | must-ask — permanent |
| external communication | 0 | 0 | 0 | 0 | must-ask |

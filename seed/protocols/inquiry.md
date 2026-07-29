# Inquiry Protocol

Research and prior-art discipline. Governs what must be looked up before it can be stated, and
what must be examined before anything is designed.

**Why this exists.** Four findings share one root cause: composing from model memory instead of
retrieving. Three schema failures from invented config formats `[E3]` · a stale session identity
carried forward from a prior session `[E10]` · a durable fact's origin inferred rather than read
`[E25]` · agent charters written inline instead of from their template `[E41]`.

A model cannot tell the difference between recalling and inventing. It has no signal that a format
changed last month. **The fix is not more care — it is a rule that makes stating-without-retrieving
fail a done-condition.**

---

## Part 1 — Retrieve before stating

### The trigger classes

Any claim in these categories requires retrieval and a cited source. No exceptions for confidence.

| Class | Examples |
|---|---|
| **External system formats** | Config schemas, frontmatter shapes, API request bodies, file layouts, directory conventions |
| **Current versions and capabilities** | What a host runtime supports, what a model can do, what a library's current API is |
| **Best practice claims** | "The standard approach is…", "It is recommended to…", "Convention is…" |
| **Statutory, regulatory, or financial rules** | Any legal requirement, rate, threshold, or filing obligation |
| **Third-party behaviour** | How a tool responds, what an error means, what a flag does |

### The rule

> **An uncited claim in a trigger class is a fabrication, not an answer.**
>
> State the source and the retrieval date, or state that you do not know. "I believe" is
> acceptable. Presenting recollection in the voice of retrieval is not.

### Done-condition impact

A task producing a trigger-class claim is **not complete** without its citations. This is not a
quality note — the done-condition is unmet, and the checkbox does not get ticked.

### What retrieval means

Reading current documentation, fetching the actual file, running the command and observing the
output, or checking the live system. **Not** recalling what the documentation said, and not
inferring from a related system's behaviour.

For a host's own configuration format, the authoritative source is that host's current
documentation — and the loader is the final word `[E3]`.

---

## Part 2 — Scan before designing

Before designing anything, establish what already exists. In this order:

**1. Inside the seed.** Does a template, protocol, or prior decision already cover this? Check
`adapters/_templates/`, `protocols/`, `memory/decisions.md`, and the growth ledger. A design that
duplicates an existing template is `[E41]` — the charters written inline had a template sitting
beside them.

**2. Inside the project.** Does the codebase already solve this? Are there conventions to follow?
For adopted projects, `conventions.md` is the standard to quote from, not to re-derive.

**3. Outside — prior art.** Has this problem been solved, and how? Look for the established
approach before inventing one. Note what the common solutions are *and* their known failure modes.

**4. The findings corpus.** Has this failed here before? `prior-evidence/FINDINGS.md` is the
record of what has already gone wrong in this project. Designing without checking it repeats
solved problems.

Only then design. **Report what the scan found**, including "nothing relevant" — an unstated scan
is indistinguishable from a skipped one.

---

## Part 3 — Questions asked before committing to a design

These are not ceremony. Each maps to a defect class already recorded.

| Question | Guards against |
|---|---|
| What am I assuming that I have not verified? | `[E3]` — invented formats stated confidently |
| What already exists that does this? | `[E41]` — reinventing beside a template |
| What would make this wrong? | Designs with no failure mode considered |
| How will this be verified once built? | `[E39]` — work whose completion cannot be checked |
| What does this depend on that could change? | `[E10]` — stale identity carried forward |
| Has this failed here before? | Repeating a solved problem |

Answer them in the plan, briefly. A design that cannot answer *"how will this be verified"* is not
ready to build.

---

## Part 4 — Search economy

Retrieval has a cost, and repeated retrieval of the same fact is waste.

1. **Check the notes first.** Does an extraction note already answer this? If so, quote it.
2. **Retrieve once.** Prefer fetching a specific documentation page over a broad search.
3. **Write the extraction note** — claim, source, retrieval date. It becomes the quotable
   reference; the source is not re-fetched.
4. **Quote the note thereafter.** Never re-derive what was already retrieved and recorded.

This converts a recurring per-session cost into a one-time cost, and makes research compound
instead of repeat. Extraction notes carry a date because a format retrieved six months ago is a
recollection again.

---

## Part 5 — What this does not require

Not everything needs a search. Retrieval is required for the trigger classes, not for:

- Reasoning about the seed's own files, which are readable directly
- Restating something already in an extraction note
- Analysis, judgement, and design reasoning — these are the work, not lookups
- Well-established general knowledge with no version dependency

**The distinguishing test:** could this have changed since training, or is it specific to a system
outside the seed? If yes, retrieve. If it is a stable fact or a reasoning step, proceed.

Over-searching wastes budget and slows loops. Under-searching produces plausible-invalid artifacts
that pass review and fail at runtime. **The second failure is far more expensive**, which is why
the trigger list errs toward retrieval.

---

## Enforcement

**In charters:** roles producing trigger-class claims carry this in their Inputs and Must-not-invent
sections.

**In review:** an uncited trigger-class claim is a finding, severity High. The claim is not
"unsupported" — it is a fabrication, and the distinction matters because fabrications are
confidently worded.

**In done-conditions:** tasks producing external-format artifacts state their source. A task
completing with "generated the adapter" and no cited format specification has not met its
done-condition, whatever the artifact looks like.

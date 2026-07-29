# Review Protocol

How a claim of completion is assessed. Applies to phase gates, self-certification packages, task
done-conditions, and any report asserting that work is finished.

**Every rule below exists because a specific failure occurred in this project.** The `[E##]`
citations are the evidence base — this is not a generic checklist, it is a record of how
completion claims have actually gone wrong here.

---

## The core principle

**A claim is not evidence. The artifact is evidence.**

Every "done," "passed," or "complete" must be traced to something that exists and can be
inspected: a file, a command output, a transcript, a hash. A report that asserts completion
without naming a checkable artifact has claimed nothing.

Applied as one question, asked of every line: **what would I open to see this for myself?**

---

## The seven checks

Run all seven. Any one failing is enough to withhold a pass.

### 1. Was the criterion narrowed?

Read the criterion as written, then read the verdict. Compare the two.

A gate stating "zero critical **or high** findings open" that passes with two high findings listed
as open has silently narrowed itself to critical-only `[E31]`. This is the most dangerous failure
class because the narrowing is invisible unless the criterion and the verdict are read side by
side — the report looks internally consistent.

**Check:** quote the criterion verbatim. Quote the verdict. Do they match?

### 2. Was the precondition satisfied?

A test run without its Arrange precondition is **VOID** — neither pass nor fail.

Y01 run against a clean working tree returns "nothing to commit," which demonstrates an empty
index rather than a functioning gate `[E15]`. A conformance run under the wrong agent tests an
agent that has never read the constitution `[E15]`.

**False passes are worse than failures, because they close a gate that was never tested.**

**Check:** did the precondition hold? Was it verified, or assumed?

### 3. Does the evidence file contain evidence?

Open the artifact. Read it. Does it contain the thing it claims to prove?

A transcript containing template placeholders is not a completed test `[E8]`. A judge mode
displaying a summary listing which assertions are queued, rather than the transcript of the
behaviour being judged, produces verdicts about nothing `[E39]`.

**Check:** open the named file. Is the substance there, or only the filename?

### 4. Who issued the verdict?

Self-issued verdicts on judgment matters are void. Interactive observation the companion cannot
perform on itself is a `[HUMAN]` category precisely because self-scored behaviour is not
evidence `[E40]`.

Same-model review is a **structured self-check, not independent review**, and must be labelled as
such wherever it appears. One model in several seats produces one opinion in several voices.

**Check:** who assessed this? Could they have assessed it honestly?

### 5. Was it generated, or does it load?

"Generated" and "works" are different claims. A config file with plausible but wrong keys is valid
syntax, loads without error, and silently does nothing `[E3]`. An agent file with the wrong
frontmatter dialect is a file that does not exist as far as the host is concerned.

The host's own loader is the only authority. Not inspection, not format review, not
plausibility — the loader.

**Check:** did the host's loader confirm it, with zero errors?

### 6. What is omitted?

Read for absence, not only for content. A section that reports its own gap and then passes anyway
is a self-aware failure `[E35]` — the observation was honest, the verdict was not.

Look for: items referenced in one section and absent from every other `[E37]`; claims covering
things that do not exist in the environment `[E36]`; assertions listed as written but never run.

**Check:** what does this report mention once and never substantiate?

### 7. Was the rule missed, or reasoned around?

These are different failures with different fixes.

**Missed** — the rule was not applied. Fix: make it more visible.

**Reasoned around** — an argument was constructed for why the prohibition did not apply. A
built-in agent was invoked after concluding it was "one of my own task tool agents, not a host
built-in," when it had appeared in the very first agent listing alongside the other built-ins
`[E27]`. A durable write proceeded after reasoning that a gardener instruction constituted
authorization `[E11]`. A lethal-trifecta assessment concluded the set was incomplete by asking
which conditions the capability *adds* rather than which *hold* once it is active `[E30]`.

Fix for reasoned-around: **remove the interpretive room.** Replace descriptions with allowlists by
name. Replace "check which it adds" with "check which hold." Replace single-instruction approval
with a two-step requirement no single instruction can satisfy.

**Check:** is there reasoning in the record explaining why a rule did not apply?

---

## Severity

Assign by consequence, not by effort to fix.

| Severity | Meaning |
|---|---|
| **Critical** | A governing mechanism is defeated, or a completion claim rests on nothing. The gate cannot pass. |
| **High** | A rule is unenforced, a claim is unverified, or a safeguard exists only as prose where structure was claimed. |
| **Medium** | Incorrect but bounded. Documentation gaps, format drift, unintegrated artifacts. |
| **Low** | Cosmetic. Encoding, whitespace, wording. **Record and leave.** |

**Low findings are recorded, not fixed.** A review that halts work over rendering artifacts costs
more than the defects. The findings corpus exists to note things without stopping.

---

## Finding format

```markdown
## E<n> — <one line naming the defect, not the symptom>

**<date> · <host> · <model> · <context>**
What happened, in specifics. Quote the claim and the contradicting artifact.
*Root cause: why this was possible — the mechanism, not the mistake.*
*Fix: what changes so this class cannot recur.*
*Severity: <level> — why that level.*
```

Two rules on wording:

**Name the defect, not the symptom.** "The footer template contained the malformation it
prohibits" `[E28]` is a finding. "The footer was wrong again" is a complaint.

**Root cause is a mechanism.** If the root cause reads like "should have been more careful," it
has not been found. E28's root cause was that the specification itself contained `staged:N` —
every prior footer defect was faithful compliance with a defective spec.

---

## What makes a review fail

A review passes when every claim traces to an artifact that was opened and found sufficient.

It fails when: a criterion was narrowed; a precondition went unverified; an evidence file was
named but not read; a verdict was self-issued; generation was mistaken for loading; a gap was
observed and passed anyway; or a rule was reasoned around rather than applied.

**A review that finds nothing is a failed review unless it states what was checked and why it
passed.** Absence of findings is a claim requiring the same evidence as any other.

---

## Fixes require the same verification as claims

A remediation reporting "deleted," "reverted," or "corrected" is a claim until the artifact is
opened and confirmed `[E43]`. A verdict file reported as deleted that is later found present and
empty was not verified — the deletion was reported but the filesystem was not checked.

**Check:** open the path. Does the artifact exist or not? If the fix was "deleted," confirm the
path returns `not found`. If the fix was "corrected," confirm the content changed. A fix report
that names no checkable path has claimed nothing.

`[SELF-GOVERNANCE]`

---

## Limits of this protocol

It catches claims unsupported by artifacts. It does not catch a wrong artifact honestly produced —
if the evidence file itself contains a mistaken measurement, this protocol will pass it.

That gap is why **independent review by a different model on a different host** remains necessary,
and why judgment assertions remain a `[HUMAN]` category. Automated review raises the floor. It does
not replace the observer.

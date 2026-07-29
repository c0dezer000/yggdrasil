# Question — harness or seed

**Convened:** 2026-07-28
**Protocol:** `seed/protocols/deliberation.md` (full deliberation)
**Workspace:** `deliberation/harness-decision/`
**Written by:** odin (orchestrator). This file frames the question and records the evidence. It
takes no position and must not be read as one.

---

## The question

**Should Yggdrasil be rebuilt as a standalone harness, or continue as a seed running on host
runtimes?**

---

## The evidence

Recorded as given by the Gardener. Odin has not independently verified any of these four items;
seats should treat them as stipulated facts of the deliberation, and should say so plainly if a
position depends on one of them being verified.

1. Session `ses_062b` ran 74 tool calls with zero subagent invocations.
2. Session `ses_0647` invoked subagents 48 times, of which 40 were clerical.
3. The Zen API bills separately from the Go subscription, so a harness abandons the $60/month.
4. The Zen model list exposes eleven labs versus Go's six.

---

## What a decision must produce

The Gardener decides. This deliberation does not. For the Gardener to be *able* to decide, the
record this workspace produces must contain, by its close:

1. **A named disagreement.** At least one point where two seats hold incompatible views, quoted
   verbatim, not smoothed into consensus. If every seat agrees, the memo must say that the
   deliberation found no disagreement — which is itself a finding about the seats.

2. **The falsifier for each position.** Every seat states what evidence would move it. A position
   without a stated falsifier is a preference and is to be labelled as one in the memo.

3. **A statement of what the two paths cost and what they buy** — build cost, recurring cost, and
   what capability each path forecloses. Where a number is unknown, "unknown" is the required
   answer; no seat invents one.

4. **The identification of what is actually limiting the system** — the runtime architecture, the
   protocol, or the way the protocols are being executed. The four evidence items above are
   consistent with more than one of these explanations, and the memo must say which explanations
   survive the record rather than asserting one.

5. **The missing evidence, named.** What we would need to observe, and how we would observe it, to
   settle the question on evidence rather than judgement. If a cheap experiment would settle it,
   the memo says so, and says what it is.

6. **No recommendation presented as a conclusion.** The memo synthesises the record and ends with
   `Gardener decision required`.

---

## Seat order

| # | Seat | Reads | Writes |
|---|---|---|---|
| 01 | architect | `00` only | `01-kvasir-position.md` |
| 02 | var | `00`, `01` | `02-var-critique.md` |
| 03 | heimdall | `00`, `01`, `02` | `03-heimdall-risk.md` |
| 04 | brokkr | `00`, `01`, `02`, `03` | `04-brokkr-feasibility.md` |
| 05 | architect | all critiques | `05-kvasir-response.md` |
| — | verdandi | the whole record | `memo.md` |

Every seat file uses the format in `seed/protocols/deliberation.md` and must contain a
**"What would change my mind"** section.

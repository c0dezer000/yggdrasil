# Deliberation Workspace

**See also:** [[agents/verdandi]], [[agents/muninn]]

Structured exchange between roles, held in files rather than relayed through the orchestrator.

**Why this exists.** Host subagents are stateless request/response. A seat's output returns to the
orchestrator, which relays a *summary* to the next seat. So Var never reads Skuld's plan — Var
reads Odin's compression of it. Two roles never touch the same artifact. What looks like
deliberation is parallel monologues through a lossy relay, and the relay runs on whichever model
the orchestrator happens to hold.

Transcript evidence: session `ses_062b` ran 74 tool calls with **zero** subagent invocations.
Session `ses_0647` invoked subagents 48 times, of which 40 were the clerical loop (skuld, verdandi,
muninn) and 3 were specialist roles. Collaboration was not thin — it was largely absent.

**The correction.** Deliberation happens in a shared directory. Each seat **reads the actual prior
artifacts** and writes its own. The orchestrator dispatches and never summarises. Files-canonical
`[D4]` already guarantees this survives the runtime — extending it to deliberation costs nothing
architecturally.

---

## Structure

```
deliberation/<topic-slug>/
  00-pre-mortem.md          pre-mortem entries from every seated role — see Rule 9
  00-question.md            the question, constraints, what a decision must produce
  01-<role>-position.md     first seat. Reads 00-pre-mortem and 00-question only.
  02-<role>-critique.md     reads 00-pre-mortem, 00-question, and 01
  03-<role>-<angle>.md      reads 00-pre-mortem, 00-question, 01, 02
  04-<role>-<angle>.md      reads everything prior
  05-<role>-response.md     the first seat answers its critics
  memo.md                   synthesis, written from the record
```

Numbered because **order is meaning**. A seat writing `03` has read `01` and `02`. That is what
makes it a response rather than an opinion.

---

## Rules

**1. Every seat reads the actual files.** Not a summary, not a relay. The dispatch instruction
names the directory and the files to read. A seat that writes without having read its predecessors
has produced a position, not a critique.

**2. The orchestrator dispatches and does not summarise.** Its instruction is of the form:
*"Read `deliberation/<topic>/00-question.md` and `01-skuld-position.md`. Write
`02-var-critique.md`."* It does not restate, condense, or interpret. Summarising is the defect this
protocol removes `[E18]`.

**3. The first seat writes without seeing others.** Round-one independence is preserved — the
proposer must not be anchored by critics who have not yet read the proposal.

**4. Critics read everything prior.** Each subsequent seat reads all earlier files in order. This is
what turns parallel monologues into an exchange.

**5. Steelman before rebuttal.** Each critique restates the position it opposes in its strongest
form before attacking it. This is checkable: the file either contains a steelman section or it does
not.

**6. The proposer responds.** The seat that wrote `01` reads every critique and writes a response —
conceding what it concedes, defending what it defends. **Without this step there is no exchange,
only review.** This is the file that most distinguishes deliberation from assessment.

**7. The memo is written from the record.** Verdandi reads every file and synthesises. Dissent is
quoted from the actual critique, not paraphrased. The memo names the seat composition and the lab
of each seat.

**7a. Verdandi authors the memo; it does not write the file.** Verdandi holds `Read, Glob, Grep` on
every adapter — deliberately, because the seat that judges the loop must not be able to edit what it
judges. It therefore **returns the memo text** and a seat holding `Write` — muninn, as keeper of the
record — transcribes it **verbatim**, changing nothing, and preserves verdandi's authorship header.
A transcription that alters the text is a defect, not an edit; the transcriber reports discrepancies
rather than correcting them. Before dispatching any seat, check that the role assigned an artifact
holds `Write`; a protocol step that assigns a file to a read-only seat is unexecutable and must name
its scribe `[E54]`.

**7b. The memo includes a Bayesian confidence summary.** After synthesising the positions, Verdandi
produces a paragraph of the form:
> Seats that held position X in prior deliberations on similar topics: [count].
> Those whose predictions were borne out: [count].
> Current alignment: [qualitative assessment].

This summary draws on `seed/memory/relationships.md` for prior-position data and on the current
workspace for alignment. Where a seat has no prior deliberation on the topic, it is stated rather
than assumed neutral. Confidence is not a numeric probability — it is a qualitative assessment of
how much the record supports the current position across multiple deliberations.

**8. The directory is the evidence.** A deliberation without its directory did not happen. Memos
without a workspace behind them are assertions.

**9. Pre-mortem before position.** After the question is set and before any seat writes its
position or critique, every seated role contributes to `00-pre-mortem.md` under the heading
*"Assume this plan has failed. What went wrong?"* naming the most likely failure mode from its
perspective. These entries are written before the main position so that failure modes are legible
before anyone is invested in defending a plan. Every subsequent seat reads `00-pre-mortem.md`
alongside `00-question.md`. The memo cites the pre-mortem entries.

---

## Seat file format

```markdown
# <Role> — <position | critique | angle>

**Read before writing:** <the files, listed>
**Model:** <model id> · **Lab:** <lab>

## Steelman
<the strongest form of the position I am about to oppose — critiques only>

## Position
<what I hold and why>

## Where I disagree
<specific, quoting the file and line I disagree with>

## What would change my mind
<the evidence that would move me — this is what makes the position falsifiable>

## Concessions
<what the other seats got right>

## Prior positions and updates
<Seat's position in prior deliberations on related topics, cited from relationships.md>
<What has changed since then>
<What evidence would update the current position>
```

**"What would change my mind" is not decoration.** A position that cannot state its own falsifier
is a preference. The **"Prior positions and updates"** section above grounds each seat's current
position in its historical record from `relationships.md`. Seats that never concede anything across
multiple deliberations are flagged in the relationship record below.

---

## Relationship memory

The gap this protocol does not close on its own: seats do not remember each other. Var reading
Skuld's plan today carries no history of how Skuld's plans have gone before. Councils convene,
produce a memo, dissolve.

**`memory/relationships.md`** accumulates the working history of each pair. Append-only, durable
tier, ratified like any other durable memory.

```markdown
## skuld ↔ var

**Deliberations:** 4
**Pattern:** Skuld's plans have twice contained done-conditions with no nameable proving artifact.
Var caught both. Skuld now states the proving artifact inline — the pattern has not recurred since
2026-07-27.
**Var's standing check on Skuld's work:** does every done-condition name what would prove it?
**Concession rate:** Skuld conceded 3 of 4; Var conceded 1 of 4.
**Last:** 2026-07-27 — deliberation/p2-close/
```

**How it is used.** When two seats are seated together, their pair entry is loaded into both
briefs. Var arrives knowing what Skuld has historically got wrong. Skuld arrives knowing what Var
will check. That is the difference between a reviewer and a colleague.

**How it is written.** After a deliberation, Verdandi proposes an update to each pair entry —
staged, ratified, appended. Never written directly `[E11]`.

**The anti-gaming rule.** Concession rates are recorded but never optimised. A seat that concedes
everything is not agreeable, it is useless; a seat that concedes nothing is not rigorous, it is
anchored. Both are visible in the record, and the record exists to be read, not scored `[D8]`.

---

## When to convene

**Full deliberation** — architecture and ADR-class decisions · money, legal, or compliance ·
irreversible changes · contested root cause · any decision where two roles already disagree.

**Plan review** (the lighter form, per `protocols/planning-board.md`) — any plan producing durable
artifacts. Same file structure, three critics, no proposer response unless a critic fails the plan.

**Neither** — routine tasks inside an approved plan. A deliberation over a variable rename is the
failure mode on the other side.

---

## What this does not fix

**Seats still cannot talk simultaneously.** Exchange is turn-based through files. A genuine
back-and-forth within one turn is not possible in a host that runs subagents as request/response.

**The orchestrator still dispatches.** It no longer summarises, which removes the lossy relay — but
it still decides who is seated and in what order.

**Whether that residue matters is an empirical question**, and this protocol is the instrument that
answers it. Run three real deliberations. If the exchange is substantive — critics engaging the
actual text, the proposer genuinely conceding or defending, the memo containing disagreement that
was not present at the start — then the architecture was not the limit and the relay was. If it
still reads as monologues stapled together, the limit is structural, and a runtime that lets seats
share a live workspace is justified on evidence rather than frustration.

Record the answer either way in `prior-evidence/FINDINGS.md`.

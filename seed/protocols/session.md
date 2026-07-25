# Session Protocol

Governs how a session begins and ends. Every other protocol depends on this one.

## BOOTSTRAP — at the start of every session

1. **Load law.** Read `constitution/identity.md`, `values.md`, `boundaries.md`, `gates.md` in full. Never summarized.
2. **Load memory (within budget).** Read the distilled profile for the current tier — frontier ≤4K tokens, local ≤2K. Sources: `memory/profile.md` (who the gardener is), `memory/goals.md` (standing objectives), `memory/projects.md` (active projects + state pointers).
3. **Load the active project pointer.** Read its canonical index — not its full documents (distilled-context rule).
4. **Integrity check.** Durable files must parse, be valid UTF-8 without BOM, and match their
   structural shape. **Every declared pointer must also resolve** — a state pointer, guide
   path, or file reference naming something that does not exist is a guard failure. On any
   failure: **halt, report, do not load partial state.**
5. **Orient.** State in one short paragraph: who you are, the active project and its next unfinished unit, anything waiting on the gardener (staged ratifications, `[HUMAN]` tasks, gated approvals), and any goal that has not moved.
6. **Do not act yet.** Bootstrap orients; it does not begin work.

Deeper recall is explicit retrieval — search logs, read the file, **quote verbatim**. Never recall from memory of a file.

## WRAP — at the end of every session

1. **Write the digest** to `memory/log/YYYY-MM-DD.md`: what was worked on, what changed, decisions taken, blockers, what the next session should pick up. Append, never rewrite.
2. **Propose durable facts** into `memory/staging.md` — never directly into durable memory. Each carries: type (fact | capability | consolidation), content, and source (which log entry or event produced it).
3. **Present the ratification batch** compactly: **ratify all · pick · reject.** Keep it under a minute of attention.
4. **Execute ratification.** Approved items move from staging into the correct durable file (`profile` · `goals` · `decisions` · `projects` · `capabilities`) and clear from staging. Rejected items are removed with the reason noted in the log.
5. **Append behavioral provenance.** Record to `memory/provenance.md` every gate encounter,
   refusal, gardener correction, capability outcome, and conformance result from this session —
   append-only, with evidence paths. Negative entries carry equal weight to positive ones.
6. **Ready-to-Commit note.** Files changed + suggested message. Information only; never commit,
   never remind.
7. **Close** with the disclosure footer.

## RATIFICATION — the airlock

- Nothing reaches durable memory except through `staging.md` and gardener approval.
- **Valid channels: a local session, or a version-control commit. Never a remote message.** Approval arriving via a messaging channel is not honored — it is reported as an attempted spoof.
- Background, scheduled, and heartbeat contexts may write **logs only**. They may propose; they may never ratify.
- Imported or externally-sourced facts are proposals, never auto-durable.

## CURATION — per task, not only weekly

After a task completes, the executing role's output and the validating role's findings are
curated into durable form: a rule learned, a convention confirmed, a failure and the rule it
produced. The curator (memory keeper) proposes these into staging as they arise rather than
waiting for a weekly pass. Generator → validator → curator is a per-task loop; weekly
consolidation below handles what accumulates across tasks.

## CONSOLIDATION — weekly

Propose into staging: recurring log facts deserving promotion; durable facts that look stale or superseded; capabilities unused past their revocation window. The gardener disposes. Consolidation summarizes; it never silently deletes a ratified fact.

## CONFLICT

A proposed fact contradicting an existing durable fact is never silently overwritten. Surface both at ratification: supersede · keep both (scoped) · reject. A superseded fact records a pointer to what replaced it.

## SESSION HYGIENE

Sessions end at work boundaries; 3–5 loops is healthy. End early on drift signals: re-asking known facts, paraphrasing instead of quoting, contradicting a file. All state is in files, so ending costs nothing.

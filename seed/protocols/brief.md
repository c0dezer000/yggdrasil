# Brief Protocol

Defines how a session or loop brief is produced — the four-section report that tells the gardener what happened, what needs them, what was observed, and what should come next. Produced by the orchestrator (or the documentation keeper when invoked explicitly) at the end of every session, at the end of every loop, or on demand.

> **Ratification note:** this protocol's output is a working report, not a durable artifact. Briefs are written to `memory/log/` as part of session digests or to the working context for on-demand reports. They are never ratified — the facts within are the session digest's content, not separate durable entries.

## When a brief is produced

A brief is produced at three times, each with a different scope:

1. **End of loop** (during `loop.md` step 6–7) — after the executing role records its log line and before the controller decides continue/complete. The brief covers the single task (or task group) just completed: what was done, what the gardener may need to review, any observations from the work, and a recommendation for what the next task should be.

2. **End of session** (during `session.md` — WRAP, step 1) — after all loops finish and before the digest is written. The brief covers the entire session: all loops run, all artifacts touched, the full set of decisions or questions for the gardener, patterns noticed across the session, and recommendations for the next session's priorities.

3. **On demand** — whenever the gardener asks for a summary of the current state. Scope matches the request: a single unit, a project, or the whole system. The brief is produced from whatever state is available at that moment.

## How each section is populated from real files

Every section must be derived from **files on disk** — never from memory, never from a template, never from assumptions. The sources listed are the minimum; the producer may consult additional files when relevant.

### What I Did

A concise account of what work was performed in the scope being reported.

**Loop-level brief.** Read these files to populate:

- `roadmap/<active-unit>.md` — the loop log at the bottom. Read the most recent entry (the one just written by the executing role). Quote the task ID and the one-line summary.
- `work/` directory — if the task produced any work files, read their names and brief purpose from the file listing.
- `memory/log/<date>.md` (if one exists for today) — check if any digest was already started for this session; if so, append to it rather than duplicate.
- Any diff or status the executor reported as part of their validation step.

**Session-level brief.** Aggregate all loop-level briefs from the session. Additionally read:

- `memory/log/<date>.md` — the session digest being written. The brief feeds into this digest rather than replacing it.
- The work index — to report any units whose status changed during the session.

**On-demand brief.** Read:

- The currently active unit file — the loop log and task breakdown
- `work/` — any files modified in this session
- Git status (`git status --short`) — to report uncommitted changes relevant to the request

### What Waits on You

Everything that needs the gardener's attention, decision, or action before work can continue or move to the next step. If nothing waits, state "nothing waits on you."

**Loop-level brief.** Read these sources:

- The executing role's output — if the work produced any `[HUMAN]`-tagged steps, staged proposals, or gated decisions, list them here.
- `memory/staging.md` — any proposals staged for ratification by the work just completed.
- The active task's done-condition — if the work is blocked on a condition only the gardener can verify (e.g., an integration test the companion cannot run), flag it explicitly.
- The executor's third-attempt failure (per `loop.md` step 5) — if a task was set to Blocked, cite the failing step and what is needed.

**Session-level brief.** Additionally read:

- All staged proposals across the session (accumulated in `memory/staging.md`).
- Any unverified artifacts from onboarding or other gated workflows (per `onboard.md` — mandatory human correction pass).
- The controller's decision output from each loop — if any loop ended with `escalate` or `block`, explain why.

**On-demand brief.** Additionally read:

- The project's full staging file and any pending ratification items across all active units.
- `gates.md` — to report any gate conditions currently tripped.

### What I Noticed

Observations, anomalies, patterns, and risks noticed during the work. This section is the producer's own analysis — it must be clearly labelled as observation, not fact. Every observation must cite its evidence.

Read these sources, but apply judgement rather than transcribing:

- The work index — look for status-change patterns (e.g., a unit that keeps returning to In Progress after being marked Complete; tasks whose estimated complexity does not match actual effort).
- The active unit's loop log — look for repeated failures, recurring error patterns, tasks that took more loops than expected.
- `memory/provenance.md` — gate encounters, refusals, gardener corrections, conformance failures from this session. A pattern of the same correction or refusal across multiple loops is a notable observation.
- `memory/log/` (recent entries) — compare the current session's observations against recent history. New anomalies are more notable than recurring known ones.
- Git status — untracked files, uncommitted changes, or branch states that may indicate drift.
- The task's done-condition — if the condition has edge cases or ambiguities that became apparent during execution, note them.
- The project's file tree — any structural observations (missing files, new files in unexpected locations, naming inconsistencies).

**Must not include:** unsupported speculation, recommendations (those go in the next section), or facts the producer cannot cite to a specific file or log entry.

**Anomaly form:** when reporting an anomaly, state (a) what was expected, (b) what was observed, and (c) the file path where the evidence lives.

### What I Recommend

Actionable recommendations for next steps, changes, or corrections. Each recommendation must be concrete and traceable to what was done or noticed. If no recommendations, state "none at this time."

Read these sources:

- The task breakdown — the next unfinished task in the active unit. Recommendation: "Continue with `<next-task-id>`."
- The work index — any downstream units whose entry condition would be met by completing the current unit. Recommendation: "Unit `<id>` entry condition is now met. Consider reopening or advancing it."
- The "What I Noticed" content — convert notable observations into actionable recommendations:
  - Recurring error → "Add a conformance assertion for `<pattern>`."
  - Repeated correction → "Ratify a durable fact about `<topic>` so it is not re-learned."
  - Missing convention → "Propose a standard for `<class>`."
  - Blocked task → "Review the failing step and decide: reopen with corrected approach, or de-scope."
- `gates.md` — if a gate line item is approaching or has tripped, recommend the gardener's attention before the next loop.
- The controller's decision output — if the controller returned `complete`, recommend the next unit to open. If `block`, recommend the gardener's intervention. If `reopen`, recommend what specifically to revisit.

**Format for each recommendation:**

- **What** — a one-line actionable statement
- **Why** — the evidence or observation motivating it
- **Where** — which file or unit it affects

## Format and structure

```
# Brief — <scope> — <date>

## What I Did

<concise list of work performed, each item citing its source file>

## What Waits on You

<list of items needing gardener attention, each with context and source>

## What I Noticed

<observations with cited evidence>

## What I Recommend

<actionable recommendations in what/why/where format>
```

- **Scope** is one of: `Loop N`, `Session`, or `On Demand — <request description>`.
- **Date** is the current date in `YYYY-MM-DD` format. For loop briefs, include the loop number if known.
- Sections are ordered as listed. A section may state "None." when empty (e.g., no observations, no waiting items).
- Every entry in "What I Did" and "What I Noticed" must cite at least one file path as evidence. Entries without evidence are flagged as unreliable.
- The brief is written to the working context for the next step (loop brief) or to `memory/log/<date>.md` (session brief). It is never written as a standalone file unless explicitly requested.

## Who produces it

- **Loop briefs** — produced by the **orchestrator** (the role running `loop.md`) during step 6, before invoking the controller. The orchestrator has access to the executor's output, the index, and the current task file.
- **Session briefs** — produced by the **documentation keeper** (Muninn) as part of `session.md` — WRAP, step 1. Muninn writes the digest and assembles the brief from the session's accumulated loop briefs and the current project state.
- **On-demand briefs** — produced by the **documentation keeper** (Muninn) when the gardener asks for a state summary. The role reads the relevant files at that moment and produces the brief in the working context.

## Delivery to the gardener

- **Loop briefs** are delivered as part of the orchestrator's summary in `loop.md` step 6–7. They are presented in the working context, not written to a separate file.
- **Session briefs** are delivered as part of the session digest in the daily log file (`memory/log/<date>.md`). The gardener reads them during the next session's bootstrap.
- **On-demand briefs** are written directly to the working context in response to the gardener's request. If the gardener asks for a persistent copy, the brief is written to `memory/log/` with a descriptive filename.

## Live invocation example (reference)

When this protocol is invoked on a live project, the producer:

1. Reads `roadmap/<active-unit>.md` — obtains the current task ID and loop log
2. Reads the work index — obtains the status of all units
3. Reads `memory/staging.md` — obtains any staged proposals
4. Reads `memory/provenance.md` — obtains recent gate encounters and corrections
5. Reads `memory/log/<date>.md` — obtains the session digest in progress
6. Runs `git status --short` — obtains uncommitted changes
7. Lists `work/` — obtains files touched this session
8. Populates the four sections from those sources, citing file paths for each entry

The result is a brief where every claim in every section traces back to a specific file on disk.

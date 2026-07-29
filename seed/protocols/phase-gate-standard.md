# Phase-Gate Standard — Readiness Criteria

> Adopted 2026-07-26. Synthesized from: Phase-Gate model (Cooper), Scrum Definition of Done, NIST AI RMF 1.0, Technology Readiness Levels (ISO 16290:2013), and Anthropic Responsible Scaling Policy. Sources in `prior-evidence/FINDINGS.md` (research extraction notes, 2026-07-26).

## Purpose

Define the standard criteria for determining when a project phase is complete and safe to proceed to the next. A phase is not closed by ticking its completion checklist alone — it requires an independent review and formal disposition of every finding.

## Two-Tier Gate Criteria

Every phase gate uses two tiers:

### Tier 1 — Must Meet (knock-out: ALL required)

| # | Criterion | What it checks | Evidence required |
|---|-----------|----------------|-------------------|
| G1 | **All done-conditions met** | Every task in the phase is either ticked with a verifiable artifact or explicitly deferred with a written reason in the loop log. | Walkthrough of each task against its done-condition |
| G2 | **All conformance assertions pass** | Every Y-assertion relevant to this phase passes on at least one bench (primary host). | `ygg verify` output, saved transcript |
| G3 | **Zero critical or high-severity findings open** | Every gap identified by the independent review is either fixed (critical/high) or has a documented disposition. | Finding log with fix/defer/accept per item |
| G4 | **No regression in previous phases** | Changes in this phase did not break assertions from earlier phases. | `ygg verify --all` or targeted re-test of earlier Y-assertions |
| G5 | **Provenance record complete** | Every gate encounter, refusal, correction, and capability outcome for this phase is recorded in `seed/memory/provenance.md`. | Provenance entries with dates and evidence paths |
| G6 | **Growth ledger up to date** | Every seed change in this phase has a corresponding entry in `seed/growth/ledger.md` with cited evidence. | Ledger entries covering all seed/ file changes |
| G7 | **Independent review conducted** | A reviewer who did not build the phase has examined the output and issued a verdict. The reviewer may be the gardener (critical read), Claude Code (different host), or another qualified reviewer. | Review transcript or finding log with reviewer identity |
| G8 | **No untriaged Y04/Y10 risk** | Any live communication channel used during the phase has passed Y04 (injection reported) and no remote-channel ratification was honoured. Y09 (background writes logs only) confirmed if heartbeat is active. | Y04/Y09/Y10 transcripts if applicable |

### Tier 2 — Should Meet (qualitative)

| # | Criterion | Qualitative verdicts |
|---|-----------|---------------------|
| S1 | **Technical feasibility** | Strong Pass / Pass / Borderline / Fail — are there any unresolved technical gaps, unknowns, or dependencies that block the next phase? |
| S2 | **Risk assessment completeness** | Strong Pass / Pass / Borderline / Fail — are risks for this phase documented and is residual risk within tolerance? |
| S3 | **Definition of Done maturity** | Strong Pass / Pass / Borderline / Fail — does the phase's DoD align with what the next phase actually needs? |
| S4 | **Documentation quality** | Strong Pass / Pass / Borderline / Fail — are protocols, memory, and evidence for this phase clear and findable from files alone? |
| S5 | **Operational readiness** | Strong Pass / Pass / Borderline / Fail — are deployment, channel, or handoff steps for the next phase defined? |

**Qualitative verdict definitions:**
- **Strong Pass:** Exceeds expectations. No concerns.
- **Pass:** Meets expectations. Minor improvements possible but not blocking.
- **Borderline:** Below expectations. Should be addressed before the next gate but does not block this gate.
- **Fail:** Must be resolved before this gate passes.

**A phase passes the gate only if:**
- ALL 8 Must-Meet criteria pass (G1–G8)
- No Should-Meet criterion is scored Fail
- At most one Should-Meet criterion is scored Borderline

## Gate Review Process

### Step 1 — Self-certification (internal)

The phase builder (the companion) produces:
- Completed task checklist with evidence per task
- `ygg verify` transcript
- Provenance entries for the phase's events
- Growth-ledger entries for the phase's changes
- Self-assessment verdicts for S1–S5

### Step 2 — Independent review

A reviewer who did not build the phase examines:
- All artifacts from Step 1 for accuracy and completeness
- Each done-condition against actual output (not just the checkbox)
- Risk areas specific to the phase
- Regression risk against earlier phases

The reviewer produces a numbered finding list. Each finding has:
- ID (E# format, continuing from FINDINGS.md)
- Severity: critical / high / medium / low
- Description
- Disposition: fix / defer-with-reason / accept-as-limitation

### Step 3 — Gardener decision

The gardener reviews the self-certification and independent review, then:
- **Pass:** All G1–G8 met, no Should-Meet criterion scored Fail, at most one scored Borderline
- **Pass with conditions:** Some G items met conditionally; conditions must be satisfied before the next gate
- **Block:** One or more G items failed — phase cannot close until resolved
- **Override:** Gardener may override a specific finding disposition, but the override is recorded in provenance.md

### Step 4 — Record

- Gate verdict, qualitative verdicts, and reviewer identity appended to provenance.md
- If passed: closing ledger entry written, SLICES.md updated
- If passed with conditions: conditions tracked in staging.md until resolved
- If blocked: blocker documented, phase status set to Blocked

## Independent Reviewer Qualifications

| Reviewer | Suitable for | Limitation |
|----------|-------------|------------|
| **Gardener (critical read)** | Any phase | Requires your time and attention |
| **Claude Code (different host)** | Conformance-driven phases | Can only check deterministic assertions; judgment items still need you |
| **Loki (opposition seat — if generated)** | Design decisions, trade-off analysis | Not yet generated; would need charter from template |
| **Human colleague (if available)** | Any phase | Requires a second person |

**The companion (Odin) cannot serve as the independent reviewer for its own work.** Self-certification and independent review must be separate.

## Phase-Specific Adaptations

### P2 (Portability) — additional gate criteria
- Cross-host conformance: the identical seed must pass `ygg doctor` and `ygg verify` on both hosts (if the second host is available)
- Explicitly identifies which assertions pass behaviorally vs. structurally (soil tier classification)
- Both tier profiles recorded in adapter metadata

### P3 (Presence) — additional gate criteria
- Y04 verified on live communication channel
- Y09 verified after 3+ heartbeat cycles (logs only, no durable writes)
- Incident-response playbook dry-run completed
- Machine hardening checklist verified by gardener

### P4 (Local models) — additional gate criteria
- Full conformance suite run on local model with per-assertion tier tags
- Assertions that fail locally are either restructured or explicitly tier-tagged — never silently hidden
- `ygg export` validated
- The honest answer to "does the seed hold on a weak model?" is written down

## Current Gate Status

| Phase | Build status | Gate criteria met? | Independent review done? | Gate verdict |
|-------|-------------|-------------------|------------------------|-------------|
| P0 | ✅ Completed | Partial — no formal independent review was conducted | ❌ | **Unratified** — passes but has not passed this standard |
| P1 | ✅ Build complete | Partial — independent review gap | ❌ | **Unratified** — same gap |
| P2 | ✅ Build complete | Partial — independent review gap | ❌ | **Unratified** — same gap |
| P3 | 🔄 In progress | Not yet applicable | ❌ | Pending |

**Action item:** All completed phases (P0, P1, P2 build) should receive a retrospective independent review to close the gap. This standard applies prospectively from the date of adoption.

## Reference

- Phase-Gate model: Wikipedia "Phase-gate process" (2025)
- Definition of Done: Scrum Guide 2020
- AI RMF: NIST AI RMF 1.0 (2023-01-26)
- TRL: ISO 16290:2013
- RSP: Anthropic Responsible Scaling Policy (2024-10-15)

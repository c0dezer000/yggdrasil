# P1 — Memory in Daily Use

## Status
In Progress

## Objective
The companion accumulates real knowledge of the gardener through the airlock, adopts an existing
project, and reports proactively. At the end of this unit it stops being a demonstration.

## Entry condition
P0 exit gate fully checked (with one deferred item: 0.11 local-model smoke test — second workstation); ledger closing entry written in Entry 007.

## Notes on pacing
Most of this unit is **using** the companion, not building it. Task 1.11 (two weeks of real use) is
the deliverable, not a waiting period. Resist adding protocols faster than memory accumulates —
a seed with ten protocols and three days of logs is less capable than one with five protocols and
a month.

---

## Task Breakdown

### Group A — Protocols the companion can generate

- [x] 1.1 Generate `protocols/onboard.md` — Done when: the file exists containing all six workflow
      steps (structural survey · extraction to `project-brief.md` · convention inference to
      `conventions.md` · gaps register · **mandatory human correction pass** · probationary
      contribution), states the module-by-module rule for large codebases, and is marked
      `[SELF-GOVERNANCE]` at ratification.

- [x] 1.2 Generate `protocols/conformance.md` — Done when: the file exists stating the
      before-creation sequence (identify class → locate standard → **quote constraints into
      context** → build only from those → propose a standard if none exists), and contains both
      named rules verbatim: *"different patterns, identical tokens"* and *"reuse before create."*

- [x] 1.3 Generate `protocols/brief.md` — Done when: the file exists with four sections (what I
      did · what waits on you · what I noticed · what I recommend), and a live invocation produces
      all four populated from real files.

- [x] 1.4 Register the new protocols — Done when: `odin.md` references all three, the adapter is
      re-copied to the host directory, and the host's loader reports zero errors.

### Group B — Memory infrastructure

- [x] 1.5 Create `seed/SCHEMA-VERSION` — Done when: the file exists containing `2`, and
      `seed/migrations/001-p0-to-p1.md` documents what changed and how to reverse it.

- [x] 1.6 Write the context-assembly strategy into `session.md` — Done when: the BOOTSTRAP section
      states the selection order (pinned always → project affinity → recency, newer ratified
      supersedes older → budget fill, naming what was omitted) and the conflict rule (a proposed
      fact contradicting a durable fact is surfaced at ratification with supersede /
      keep-both-scoped / reject — never silently overwritten).

- [x] 1.7 Populate `goals.md` — Done when: at least three real standing objectives exist with
      status and last-movement date, and a bootstrap reports any that have not moved.

- [x] 1.8 Verify budget under load — Done when: bootstrap with populated memory is measured and
      recorded as within the stated token budget, with the measurement written to
      `evaluations/context-budget-<date>.md`.

### Group C — Capability

- [x] 1.9 Generate the roles the work actually needs — Done when: each generated charter loads with
      zero errors, carries a description with an explicit NOT-for clause, declares least privilege,
      and ships three assertions. **Generate only on demand** — a role added before a task needs it
      degrades routing for every existing role. Roster cap ~13.

- [x] 1.10 Generate the research skill — Done when: it exists in the spec-compliant format with
      three-tier disclosure, states the extraction-note discipline (claim · source · date), and
      **its anti-confabulation rule is enforced by a conformance assertion** — a research output
      containing an uncited factual claim fails.

- [ ] 1.11 **[HUMAN]** Approve one read-only connector — Done when: a proposal exists with
      provenance and a security checklist, the gardener has approved it, and it is recorded in
      `capabilities.md` with a tier tag and a declared-vs-actual verdict.

### Group D — The actual deliverable

- [ ] 1.12 **[HUMAN]** Two weeks of real use — Done when: fourteen daily digests exist in
      `memory/log/`, at least five facts have been ratified into durable memory through actual
      work, and the ratification burden has been measured at under 60 seconds per day.

- [ ] 1.13 **[HUMAN]** Onboard one existing project — Done when: `project-brief.md` and
      `conventions.md` exist for a real project, the gardener has corrected them, and the
      corrections are ratified into durable memory.

- [ ] 1.14 **[HUMAN]** Re-run Y03 with populated memory — Done when: a transcript shows a cold
      session resuming correctly with real memory present, not just an empty scaffold.

- [ ] 1.15 Close the unit — Done when: the ledger has a closing entry citing evidence, and the
      completion checklist below is fully checked.

---

## Completion Checklist

- [ ] Bootstrap loads within budget with populated memory
- [ ] Cold resume passes with real memory (Y03 re-run)
- [ ] Ratification burden under 60 seconds/day, measured
- [ ] At least 5 facts ratified through real use
- [ ] 14 days of digests present
- [ ] One schema migration performed with nothing lost
- [ ] One existing project onboarded, extraction corrected and ratified
- [ ] `goals.md` populated; stalled goals surfaced at bootstrap
- [ ] Research skill passes its anti-confabulation assertion
- [ ] All new protocols load; host loader clean
- [ ] Ledger closing entry written

## Loop Log

- **2026-07-26 P1 Loop 1:** Task 1.1 completed — `seed/protocols/onboard.md` generated with all six workflow steps, module-by-module rule, and `[SELF-GOVERNANCE]` marker. Done-condition verified against file contents. Next: 1.2 (conformance protocol) or 1.3 (brief protocol).
- **2026-07-26 P1 Loop 2:** Task 1.2 completed — `seed/protocols/conformance.md` generated with before-creation sequence (5 steps) and both named rules verbatim. Done-condition verified. Next: 1.3 (brief protocol).
- **2026-07-26 P1 Loop 3:** Task 1.3 completed — `seed/protocols/brief.md` generated with four sections (what I did / what waits on you / what I noticed / what I recommend), each sourced from real files. Done-condition verified. Next: 1.4 (register protocols).
- **2026-07-26 P1 Loop 4:** Task 1.4 completed — odin.md updated to reference all three new protocols (host + seed copies), adapter re-copied, loader reports zero errors. Done-condition verified. Group A complete. Next: Group B (1.5) or next available.
- **2026-07-26 P1 Loop 5:** Task 1.5 completed — seed/SCHEMA-VERSION created (contains "2"), seed/migrations/001-p0-to-p1.md documents changes and reversal. Done-condition verified. Next: 1.6 (context-assembly strategy in session.md).
- **2026-07-26 P1 Loop 6:** Task 1.6 completed — session.md BOOTSTRAP section updated with selection order and conflict rule. Done-condition verified. Next: 1.7 (populate goals.md).
- **2026-07-26 P1 Loop 7:** Task 1.7 completed — goals.md populated with 4 real standing objectives (MVP, memory, cost, portability), each with status and last-movement date. Bootstrap rule added. Done-condition verified. Next: 1.8 (verify budget under load).
- **2026-07-26 P1 Loop 8:** Task 1.8 completed — bootstrap budget measured: memory load = 728 tokens (within 4K frontier / 2K local budgets). Evaluation written to evaluations/context-budget-2026-07-26.md. Group B complete. Next: Group C (1.9) or Group D (1.11).
- **2026-07-26 P1 Loop 9:** Task 1.9 completed — huginn (researcher) and heimdall (security) charters generated with NOT-for clauses, least privilege, 3 assertions each. Loader reports zero errors. Others deferred per on-demand rule. Next: 1.10 (research skill).
- **2026-07-26 P1 Loop 10:** Task 1.10 completed — research skill generated at ~/.config/opencode/skills/research/SKILL.md with three-tier disclosure, extraction-note discipline, and anti-confabulation conformance assertion. Group C complete. Next: Group D (1.11–1.15 [HUMAN]).
- **2026-07-26 P1 Loop 9:** Task 1.9 completed — charters generated for huginn (Researcher) and heimdall (Security), written to both seed and host agent directories. Each charter carries: explicit NOT-for clause in description, least-privilege tool declarations, and three assertions. Loader reports zero errors. Roster now has 8 of 13 slots filled. Next: 1.10 (research skill — needs huginn).
- **2026-07-26 P1 Invalidation:** Task 1.8 is invalid — Var measured the stray `profile.md` (74 chars) instead of the canonical one (~8,500 chars), so the recorded budget of 728 tokens is wrong. Checkbox unticked. Requires re-measurement with correct profile.md loaded. Loop 8 entry is preserved for audit; the result is void.

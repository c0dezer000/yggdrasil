# Amendment Hierarchy — Meta-Constitutional Layer

> **This document defines the classification, change authority, and amendment method for every
> component in the seed. It is itself meta-constitutional (Layer 1) — it can be amended only by
> the gardener, by commit, with a growth-ledger entry.**

## Purpose

Not all seed files are equal. Some define hard constraints that the system must never relax.
Others define procedures that the system can propose improvements to. Others record facts that
accumulate through use. Still others are ephemeral working state.

This hierarchy prevents two failure modes:

1. **Protocol drift into constitution** — a procedure being treated as inviolable, or a
   constitutional rule being relaxed through the staging airlock.
2. **Silent mutation** — working state being mistaken for durable fact, or a ratified entry
   being overwritten without going through the airlock.

Every seed component belongs to exactly one of five layers.

---

## The Five Layers

| Layer | Contents | Change authority | Amendment method |
|---|---|---|---|
| **1 — Meta-constitutional** | Rules about which rules exist, how they are classified, and who can change them | **Gardener only** | Commit, with growth-ledger entry |
| **2 — Constitutional** | Hard constraints on the system: identity, boundaries, gates, values | **Gardener only** | Commit, with growth-ledger entry |
| **3 — Protocol** | Procedures, workflows, role definitions, and verification rules | System proposes, gardener ratifies | Staging → ratification |
| **4g — Memory (global)** | Ratified governance facts shared across all projects: profile, goals, cross-project decisions, projects index, patterns | System proposes, gardener ratifies | Staging → ratification |
| **4p — Memory (project)** | Ratified facts scoped to one project: project decisions, capabilities, conventions, roster, project-specific memory | System proposes, gardener ratifies | Staging → ratification, scoped to project |
| **5 — Working state** | Ephemeral records, logs, auto-generated files, provenance, buffers, guides, evaluations | System writes directly | Append-only or overwrite |

---

## Layer 1 — Meta-constitutional

**Who can change:** Gardener only. The system may never amend, relax, or reinterpret these rules.

**Amendment method:** Direct commit by the gardener, with a growth-ledger entry citing the rationale.

**Contents:**
- `seed/constitution/amendment-hierarchy.md` — this file

**Why separate from Layer 2:** The constitution defines what the system is and what it must never do. The meta-constitution defines what *those rules* are and who can touch them.

---

## Layer 2 — Constitutional

**Who can change:** Gardener only. The system proposes nothing here.

**Amendment method:** Direct commit by the gardener, with a growth-ledger entry.

**Contents:**
- `seed/constitution/identity.md` — register, tone, identity statement
- `seed/constitution/boundaries.md` — may-do-alone, must-ask, must-never, standing rules
- `seed/constitution/gates.md` — named gates, mandatory stops, status transitions, budgets
- `seed/constitution/values.md` — the eight values that guide decisions

**Test:** Does the file define a hard constraint the system must never be able to relax on its own?

---

## Layer 3 — Protocol

**Who can change:** System proposes, gardener ratifies.

**Amendment method:** Staging entry → gardener approval → durable write.

**Contents:**
- `seed/protocols/` — 19 protocol files (archive, brief, conformance, consult, council, deliberation, disclosure, distill-local, graduated-autonomy, inquiry, loop, off-map, onboard, phase-gate-standard, planning-board, provenance-consolidation, review, session, tier-routing)
- `seed/adapters/*/agents/*.md` — all agent charters (OpenCode + Claude)
- `seed/adapters/*/model-assignment.md` — model-to-role routing
- `seed/conformance/*.md` — Y-assertions (Y01-Y16)

**Test:** Does the file define a procedure, workflow, role definition, or verification rule?

---

## Layer 4g — Memory (global)

**Who can change:** System proposes, gardener ratifies. Every durable fact must arrive through staging.

**Amendment method:** Staging entry → gardener approval → durable write. Ratified, never rewritten.

**Contents:**
- `seed/memory/profile.md` — gardener identity, environment, preferences
- `seed/memory/goals.md` — standing objectives
- `seed/memory/projects.md` — project index and state pointers (registries, not content)
- `seed/memory/decisions.md` — cross-project decision record
- `seed/memory/capabilities.md` — capability registry
- `seed/memory/relationships.md` — seat pair relationship ledger
- `seed/memory/patterns.md` — cross-project learned patterns (future)

**Scope:** Shared across all projects. Every project reads the same global memory.

---

## Layer 4p — Memory (project)

**Who can change:** System proposes, gardener ratifies. Scoped to the active project.

**Amendment method:** Staging entry → gardener approval → durable write. Staging is per-project; project A's staging does not block project B's.

**Contents (per project, under `.ygg/memory/`):**
- `profile.md` — project-specific context and conventions
- `goals.md` — project-specific objectives
- `decisions.md` — project-specific decisions
- `capabilities.md` — project-specific capabilities
- `relationships.md` — project-specific seat pair relationships
- `provenance.md` — project-specific behavioral record

**Test:** Does the file record facts scoped to one project?

---

## Overlay tightening rule

A project overlay (`overlay/`) may:
- Add a Layer 3 protocol file (project-specific procedure)
- Add a high-stakes register entry (project-specific constraint)
- Narrow a roster (remove roles not relevant to the project)

A project overlay may **never**:
- Shadow or override a Layer 1 or Layer 2 file (path collision is a hard error, not a merge)
- Relax a gate, widen a boundary, or reduce a must-never rule
- Alter the constitution, gates, or values

This rule is structural: `ygg doctor` detects layered path collisions as guard failures.

---

## Layer 5 — Working state

**Who can change:** System writes directly. No staging required.

**Amendment method:** Append-only for logs; overwrite for ephemeral state.

**Contents:**

*Append-only:*
- `seed/memory/provenance.md` — behavioural provenance (explicitly not durable-tier per boundaries.md)
- `seed/memory/log/*.md` — session digests and heartbeat briefings
- `seed/growth/ledger.md` — record of seed changes
- `logs/remote/*` — gitignored remote channel logs

*Overwrite-in-place:*
- `seed/memory/staging.md` — ratification airlock buffer
- `seed/memory/distilled-local.md` — auto-generated compressed memory
- `seed/memory/knowledge-index.md` — topic-to-file mapping
- `work/session-state.md`, `work/error-budget.md`, `work/task-queue.md`
- `guides/*.md` — beginner-level guides
- `evaluations/*.md` — conformance transcripts
- `deliberation/*/` — per-topic deliberation seat files
- `prior-evidence/*.md` — imported historical reference
- `tools/ygg/*` — CLI scripts
- `roadmap/SLICES.md` — work index
- `roadmap/P*.md` — phase task breakdowns

---

## Classification Guide

When a new seed component is created, classify it by asking:

1. Does it define constraints on the system itself — what it is, what it must never do, how it may be changed?
   → Layer 1 (meta-constitutional) or Layer 2 (constitutional)

2. Does it define a procedure, workflow, role definition, or verification rule?
   → Layer 3 (protocol)

3. Does it record facts about the gardener, the system's projects, capabilities, or past decisions?
   → Layer 4 (memory/durable)

4. Is it ephemeral, auto-generated, append-only, executable, or instructional?
   → Layer 5 (working state)

5. None of the above?
   → Default to Layer 5. Then reconsider whether it belongs in the seed at all.

---

## Key Edge Cases

| Component | Layer | Rationale |
|---|---|---|
| `provenance.md` | 5 — Working state | Append-only log of events the system witnessed. Not ratified because self-witnessed. |
| `growth/ledger.md` | 5 — Working state | Documents changes; the ratification itself is the durable event, not the documentation of it. |
| `knowledge-index.md` | 5 — Working state | Utility index derived from actual files. Staleness is metadata error, not fact corruption. |
| Agent charters | 3 — Protocol | System may propose amendments (inquiry-protocol charter amendment, 2026-07-28). |
| `guides/*.md` | 5 — Working state | Instructional material, not ratified facts. |

---

## Version History

| Date | Change | Author |
|------|--------|--------|
| 2026-07-30 | Initial creation | Gardener via Kvasir |

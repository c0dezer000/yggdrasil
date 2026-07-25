# Grimoire → Seed: Extraction Map

Source: `grimoire.md` (orchestrator primary) + `AGENTS.md` (DentaCloud rules).
Method: every rule sorted **Universal** (seed core, wording preserved) · **Pattern+Slot** (seed core generalized, DentaCloud's version becomes an example) · **Project-only** (moves to the project profile).

---

## A. Universal — ported to seed core, wording preserved where proven

| Rule | Source | Seed destination |
|---|---|---|
| Orchestrator-only framing ("you do not plan, implement, review, or debug yourself") | grimoire | `protocols/loop.md` |
| Imperative `INVOKE <agent> via the task tool` (never passive description) | grimoire | `protocols/loop.md` |
| Files win over model memory when they disagree | grimoire | `constitution/boundaries.md` |
| Reconcile first + status-transition guard | both | `protocols/loop.md` |
| `[HUMAN]` task check: **verify-first** → guide → stop → re-verify | grimoire | `protocols/loop.md` + `constitution/boundaries.md` |
| Task ceiling ≤3 | grimoire | `protocols/loop.md` (stated where the model works) |
| Self-validate against **verbatim** done-condition; 3rd failure → Blocked | both | `protocols/loop.md` |
| Tick checklist + append one log line | both | `protocols/loop.md` |
| DECISION line: continue / complete / block / reopen / escalate | grimoire | `protocols/loop.md` |
| Ready-to-Commit note = information only; never state-changing git | grimoire | `protocols/loop.md` |
| Continuous mode + **closed** mandatory-stop list | grimoire | `protocols/loop.md` |
| Maintenance Mode: ad-hoc requests routed, never handled raw | grimoire | `protocols/loop.md` |
| Quote-don't-recall | grimoire | `constitution/boundaries.md` |
| Session hygiene; all state in files | grimoire | `constitution/boundaries.md` |
| Disclosure footer, truthful, "none" acceptable | grimoire | `protocols/disclosure.md` |
| Loop budget: 3 attempts · 2 reopens · ping-pong halt | AGENTS | `protocols/loop.md` |
| Distilled context rule (summary before full file) | AGENTS | `constitution/boundaries.md` |
| Planner decides **what**, controller decides **whether** | AGENTS | `protocols/loop.md` |
| Status transitions + human-only Lock | AGENTS | `constitution/gates.md` |
| Reopen cascade | AGENTS | `constitution/gates.md` |
| Change-request workflow for scope changes | AGENTS | `constitution/gates.md` |

## B. Pattern + Slot — generalized; DentaCloud's version becomes the first example

| DentaCloud rule | Generalized seed rule | Slot filled per project |
|---|---|---|
| "Deviation in SC/PWD, VAT, installment, BIR-series stops the loop" | **High-stakes register:** deviation from any registered high-stakes rule stops the loop and goes to the gardener | `high_stakes_register` |
| Fixed table of `docs/00-…` through `docs/08-…` | **Canonical document set:** each project declares its source-of-truth documents; code/artifacts may not contradict them beyond one loop | `canonical_documents` |
| Must-not-invent list (SMS, uploads, HMO, AWS…) | **Must-not-invent register:** deferred scope, unapproved integrations, out-of-structure files | `must_not_invent` |
| Routing table naming `database-designer`, `frontend-builder`… | **Role roster:** responsibility → role → skill, ≤13 roles | `role_roster` |
| "Gate 3 — before Phase 07" | **Planning→Execution Gate:** before the first phase that produces durable artifacts | `execution_gate_phase` |
| "Gate 4 — MCP server approval" | **Capability Gate:** any new external-reach capability | (universal, no slot) |
| Continuous **Testing** Rule (code + unit tests) | **Continuous Validation Rule:** every task producing an artifact includes its validation in the same or next loop | `validation_method` |
| Phase files / task breakdown | **Work units** with done-conditions | `work_unit_structure` |
| `reference/` is input only, never truth | **Reference intake:** references are input; canon is authority | (universal) |

## C. Project-only — moves to `project-profile.md`

Dental domain modules · PH statutes (RA 9994/10754, RA 10173, BIR EOPT) · Prisma/Next.js/shadcn/Tailwind specifics · AWS + PWA deployment · specific document filenames · specific deferred features (SMS, HMO claims, file uploads) · MCP matrix path.

---

## D. Contradictions found in the live files — resolve before porting

**These are real inconsistencies in the source, not extraction artifacts. Each would have propagated silently into the seed.**

| # | Contradiction | Where | Recommended resolution |
|---|---|---|---|
| **X1** | Loop step 9 says *"Commit — Single commit per loop"* (agent commits) but the Version Control Rule says *"User executes all git commits at their discretion"* and Grimoire says *"never run state-changing git."* Three-way conflict; the retrofit fixed Grimoire but left AGENTS.md step 9 unamended. | AGENTS §Loop step 9 vs §Version Control vs grimoire step 8 | Seed adopts **gardener-committed only**; the loop emits a Ready-to-Commit note. Step 9's wording is dropped, not ported. |
| **X2** | AGENTS.md forbids Obsidian wikilinks in canonical files; the v1.2 spec recommends `[[wikilinks]]` in memory files for navigation and future graph indexing. | AGENTS §Must-Not-Invent vs spec §6.12 | **Split by file class:** project canonical documents remain wikilink-free (portability); **seed memory files use wikilinks** (navigation + relationship data). Record as an explicit decision so it isn't rediscovered as a bug. |
| **X3** | Disclosure footer has two fields (`skills`, `subagents`); the v1.2 spec defines three (adds `mem-writes`). | grimoire vs spec §6.2 | Seed uses the three-field form. Memory writes are the highest-risk action and must be disclosed. |
| **X4** | AGENTS loop step 4 says *"a small related task group"* (no number); Grimoire says *"AT MOST 3."* The unnumbered version is the one that was ignored wholesale in practice. | AGENTS step 4 vs grimoire step 4 | Numeric ceiling only, stated in the orchestrator prompt **and** the rules digest. Vague quantifiers are not ported. |
| **X5** | "Continuous Testing Rule" is code-specific (unit tests); the seed must govern non-code work. | AGENTS §Continuous Testing | Generalized to **Continuous Validation** with the method declared per project (tests, review, measurement, source-check). |

## E. Gaps — present in the spec, absent from the source (author fresh, do not extract)

`session.md` (bootstrap/wrap) · `brief.md` (briefing) · `onboard.md` (codebase adoption) · memory tiers and the ratification airlock · `goals.md` · growth ledger · soil-tier awareness · council seat-composition labeling. These are new capabilities; nothing in Grimoire covers them.

## F. Notable strength worth preserving verbatim

The **`[HUMAN]` verify-first sequence** is the single most transferable mechanic in the source: *check whether the done-condition already holds → if not, generate a beginner-level guide to a durable file → stop → re-verify on resume → point at the specific failing step.* It generalizes with zero modification to credentials, accounts, purchases, installs, and physical-world tasks. Ported word-for-word.

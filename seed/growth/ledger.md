# Growth Ledger

> Append-only. Every change to the seed, with the evidence that caused it.
> Supersede; never rewrite. A seed change without a ledger entry fails conformance (Y08).
>
> **This file records changes to the seed.** How the companion *behaved* is recorded separately
> in `memory/provenance.md`. Do not mix them.

## Entry 001 — 2026-07-24 — Seed extracted (harvest #1)

- **Change:** Initial seed extracted from the predecessor orchestrator and its project rules,
  generalized to a domain-agnostic core. Constitution, protocols, adapter templates, orchestrator
  persona, and role charters created.
- **Evidence:** `prior-evidence/EXTRACTION-MAP.md` — rule-by-rule sort into universal /
  pattern+slot / project-only, with five source contradictions identified and resolved. Findings
  E1–E6 imported.
- **Author:** gardener
- **Notes:** Extraction ran in parallel with, not after, the predecessor project's completion, per
  the sequencing-honesty clause. As of Entry 006 the seed is **standalone** — its evidence base is
  self-generated and no external project is a dependency.

## Entry 002 — 2026-07-24 — First live loops; evidence E7–E10

- **Change:** Work index created; conformance unit opened; first loops executed under the
  orchestrator.
- **Result:** Y06 pass. Y07 pass with real nested task-tool delegation — **soil classified
  Tier 1**. `[HUMAN]` verify-first correctly refused a fabricated completion.
- **Defects found:** broken state pointer in founding memory (E9); stale session identity in a
  generated guide (E10); `[HUMAN]` criteria incomplete — the tag was correct, the rule justifying
  it was missing (E8).
- **Evidence:** `prior-evidence/FINDINGS.md` E7–E10.
- **Author:** gardener

## Entry 003 — 2026-07-24 — Amendment 4: landscape adoptions + behavioral provenance

- **Change:** Fifth `[HUMAN]` criterion · pointer resolution in the bootstrap integrity check ·
  session-identity, encoding, and wikilink standing rules · **lethal trifecta** compounding check ·
  **behavioral provenance** ledger · Agent Skills spec compliance with three-tier progressive
  disclosure · **declared-vs-actual** capability verification and tools-used/exposed ratio ·
  per-task curation.
- **Evidence:** E7–E10 (internal); X1–X7 (external, cited in FINDINGS.md).
- **Rejected in the same pass:** vector/graph index (triggers unmet) · autonomous registry
  acquisition (v3-conditional on X2) · any runtime or interface (D14).
- **Author:** gardener

## Entry 004 — 2026-07-25 — Seed-root resolution (D17)

- **Change:** Adapters resolve the seed root from a gitignored `.ygg` pointer in the working
  directory, falling back to the working directory itself, halting if neither resolves.
- **Decision D17:** Exactly one seed exists. A project holds an adapter and a pointer, never a
  copy of the constitution or memory. Copying would produce multiple companions with divergent
  memory.
- **Evidence:** identified in review before P1 — the persona's relative paths would have resolved
  to nothing the first time the companion was used on another project.
- **Author:** gardener

## Entry 005 — 2026-07-25 — Two-step ratification (critical fix)

- **Change:** Ratification restructured to require a staged entry **plus a separate-turn approval
  referencing it**. A single instruction can never satisfy both. The companion never writes
  `ratified:` on its own entry. Self-correcting edits on durable files prohibited.
- **Evidence:** E11–E14, from Y05 failing on its first run.
- **Why it matters:** the prior wording allowed an instruction to be read as authorization, which
  meant any message appearing to come from the gardener — including an injected one — could reach
  durable memory. The airlock was a courtesy; it is now a mechanism.
- **Author:** gardener

## Entry 006 — 2026-07-25 — Standalone scope; clean rebuild

- **Change:** All dependency on an external demonstration project removed. The seed is standalone
  and grows by use. Seed regenerated as a single integrated tree — every amendment and fix applied
  at source rather than layered as patches — carrying the evidence corpus (E1–E15, X1–X8) forward
  unchanged.
- **Rationale:** incremental patching across multiple bundles produced several sources of truth
  for one seed and made the install state ambiguous. A single integrated tree removes that
  ambiguity. Evidence is preserved because it is the only thing that cannot be regenerated.
- **Evidence:** E15 (a conformance run executed under the wrong agent, void) is the clearest
  symptom of install-state ambiguity.
- **Author:** gardener

## Entry 007 — 2026-07-26 — P0 closed; phase passes exit gate

- **Change:** P0 Foundation unit closed. Status set to Completed. P1 Memory in Daily Use opened as the active unit.
- **Result:** 10 of 12 tasks completed. Core conformance assertions verified: Y01 (gated action), Y03 (cold resume), Y05 (ratification airlock), Y06 (disclosure footer), Y07 (real delegation), Y11 (ratification cycle). Tier 1 soil confirmed.
- **Deferred item:** 0.11 (local-model smoke test) — cannot be completed here because the Ollama local model runs on the gardener's second workstation. Will be performed during P1 when that device is available. Completion checklist annotated accordingly.
- **Gap acknowledged:** the "Host loader lists every role, zero errors" checklist item was verified indirectly by task 0.1 but not independently re-verified at close. No defect found — the loader output is stable — but the checklist is marked as implicitly met rather than formally checked.
- **Evidence:** `roadmap/P0-foundation.md` (Loop 8 log, completion checklist), `evaluations/opencode/deepseek-v4-flash/` (Y01, Y03, Y05, Y06, Y07, Y11 transcripts), this entry.
- **Author:** gardener via Odin

## Entry 008 — 2026-07-26 — odin.md corrections: seed-root, roster, footer template `[SELF-GOVERNANCE]`

- **Change:** Three structural corrections to the orchestrator persona:
  (1) All memory paths in the bootstrap section prefixed with `<seed-root>/` to prevent ambiguous
  resolution (E26);
  (2) Roster converted to an explicit closed allowlist with every host built-in named as
  never-invoked (E27);
  (3) Footer template fixed — `staged:N` placeholder removed, valid tokens enumerated without
  a template value that is itself a malformation (E28).
  The "Never create a memory file" rule and the two-candidate-directory defect report were added
  to the seed-root section.
- **Result:** E26 — a second candidate memory directory is now a reportable defect, not a choice.
  E27 — `general` can no longer be reasoned around; every host built-in is named in the blocklist.
  E28 — the footer spec no longer contains the very malformation it prohibits.
- **Evidence:** `prior-evidence/FINDINGS.md` E26–E28, `seed/adapters/opencode/agents/odin.md`
  (bootstrap, roster, footer sections)
- **Author:** gardener via Odin

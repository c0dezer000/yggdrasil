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

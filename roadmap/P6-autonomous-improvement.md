# P6 — Autonomous Self-Improvement

## Status
Not Started

## Objective
The seed autonomously improves its own governance — consolidating provenance before token ceilings are hit, testing domains adversarially before promotion, running Kaizen improvement sprints, building a correlation matrix for fallback precision, detecting regressions automatically, classifying the constitutional hierarchy, and eventually allowing T3 domains to direct their own work cycles.

Also: integrate MCP (Model Context Protocol) via a Bash bridge to gain structured persistent memory, smarter file operations, and standardized async execution — without migrating to a different host.

## Entry condition
P5 build tasks complete. Provenance token budget near ceiling (~1,981/2,000). Work begins with R1 (provenance consolidation) as a hard prerequisite for Wave 2.

---

## Task Breakdown

### Wave 1 — Foundation (independent, parallel)

#### R1 — Provenance Consolidation Protocol
**Roles:** Kvasir (protocol design) + Muninn (implementation)

A weekly consolidation mechanism. Groups related provenance entries by domain. Removes routine entries past 90 days (corrections and incidents are permanent). Updates derived metrics (correct-stop rates, error budget). Records consolidation as a single provenance entry.

**Done-condition (verbatim):**
> provenance.md has a consolidation protocol at `seed/protocols/provenance-consolidation.md`, routine entries older than 90 days are pruned from active context, derived metrics (correct-stop rates) are always current, and the consolidation is recorded as a single entry.

**Gardener:** Ratify consolidation protocol and initial consolidation run (~5 min review)

**Dependencies:** None — standalone procedural change

**Unlocks:** R2, R3, R4

---

#### R5 — Automated Regression Detection
**Roles:** Brokkr (implementation) + Var (validation)

Before/after snapshots of conformance assertions, ygg doctor output, and provenance metrics whenever a seed file changes via staging. Diff results and flag regressions.

**Done-condition (verbatim):**
> The staging ratification workflow includes a pre-snapshot and post-snapshot step; any regression in conformance assertions or doctor checks is automatically reported; the regression report is included in the loop log.

**Gardener:** Verify regression detection on a real staging change (~5 min review)

**Dependencies:** None — standalone tooling change

---

#### R6 — Meta-Constitutional Layer
**Roles:** Kvasir (design) + Muninn (writing)

An explicit hierarchy document (`seed/constitution/amendment-hierarchy.md`) defining which parts of the seed are at which amendment level, who can change them, and what process is required.

**Done-condition (verbatim):**
> `seed/constitution/amendment-hierarchy.md` exists with: the 5-layer classification (meta-constitutional, constitutional, protocol, memory, working state); the change authority for each layer; the amendment method for each layer; a classification guide for any new seed component.

**Gardener:** Ratify amendment hierarchy and classify all existing seed components (~10 min review)

**Dependencies:** None — standalone documentation

---

#### MCP Bridge — Model Context Protocol Integration
**Roles:** Brokkr (implementation) + Huginn (research) + Var (validation)

Build a lightweight `ygg mcp` subcommand that communicates with MCP servers via stdin/stdout JSON-RPC. This enables access to MCP tools without migrating to an MCP-native host, preserving the three-model roster (DeepSeek, Qwen3.7, GLM-5.2).

**Target MCP servers (in priority order):**
1. **Memory MCP** — structured knowledge graph (entities, relations, observations) persisted to `seed/memory/knowledge-graph.jsonl`. Enables cross-session persistent memory.
2. **Git MCP** (read-only) — structured git access for the execution bridge.
3. **Filesystem MCP** — pattern-matching file edits with diff preview and dry-run mode.
4. **Seed Context (custom)** — parsed/validated seed state as structured tools (phase, error budget, pending staging).

**Done-condition (verbatim):**
> `ygg mcp memory --search "corrections"` returns structured results from the Memory MCP server. `ygg mcp git --status` returns parsed git status. Both work via a Bash bridge to local MCP server processes. The bridge is registered in `tools/ygg/ygg.ps1` as the `mcp` subcommand.

**Gardener:** Verify MCP bridge on at least one server (~5 min review)

**Dependencies:** None — standalone tooling

---

### Wave 2 — Metrics and Testing (after R1)

#### R2 — Pre-Promotion Adversarial Testing
**Roles:** Var (test design) + Muninn (evidence recording)

Before any domain graduates from must-ask (T1) to conditional-autonomy (T2), run automated adversarial tests designed to trigger failure modes the domain is supposed to prevent.

**Done-condition (verbatim):**
> A test-case battery exists for each domain being considered for promotion; the battery is run by Var before promotion; a passing battery is recorded as evidence in provenance.md; a failing battery blocks promotion.

**Dependencies:** R1 (needs current metrics from consolidated provenance to design relevant tests)

**Unlocks:** R7

---

#### R3 — Improvement Sprint Protocol
**Roles:** Kvasir (protocol design) + Brokkr (implementation) + Var (outcome assessment)

Time-boxed Kaizen events (3-5 loops) focused on one domain. Analyze current-state from provenance, set improvement targets, implement changes, measure outcome, standardize or rollback.

**Done-condition (verbatim):**
> `seed/protocols/improvement-sprint.md` exists defining the 8-step Kaizen process; at least one improvement sprint has been completed on a T2+ domain; the outcome (standardize or rollback) is recorded in the growth ledger.

**Dependencies:** R1 (needs consolidated provenance for baseline metrics)

---

#### R4 — Autonomy-Level Correlation Matrix
**Roles:** Kvasir (design) + Muninn (implementation)

A structured record in provenance.md tracking which domains' corrections correlate with failures in other domains. Replaces the conservative "any correction triggers all fallbacks" with empirically refined rules.

**Done-condition (verbatim):**
> A correlation table exists in provenance.md; after 5+ corrections in any domain, the correlation data is updated; the graduated autonomy fallback trigger references the correlation matrix (defaulting to "all domains" until sufficient data exists).

**Dependencies:** R1 (needs consolidated provenance for correlation computation)

**Unlocks:** R7

---

### Wave 3 — Autonomy (after R2 + R4)

#### R7 — Self-Directed Work Unit Protocol
**Roles:** Kvasir (protocol design) + Heimdall (security review) + Var (validation)

A protocol allowing domains at may-do-alone (T3) to autonomously invoke PLAN→EXECUTE→VALIDATE→DECIDE cycles without orchestrated dispatch for each step. Checkpoint-based, revocable.

**Done-condition (verbatim):**
> `seed/protocols/self-directed-work.md` exists with: trigger conditions, checkpoint frequency (every N tasks or M minutes), decision trace requirements, revocation mechanism, and hard ceilings per session. At least one T3 domain has been assessed as self-directed-ready.

**Dependencies:** R2 (adversarial testing needed before self-direction), R4 (correlation matrix for safety monitoring)

---

## Sequencing

```
WAVE 1 (parallel)
  R1 — Provenance consolidation     ← START HERE (token ceiling: 1,981/2,000)
  R5 — Regression detection         (tooling, independent)
  R6 — Meta-constitutional layer    (documentation, independent)
  MCP — Bridge + Memory MCP         (tooling, independent)

WAVE 2 (after R1)
  R2 — Adversarial testing
  R3 — Improvement sprints
  R4 — Correlation matrix

WAVE 3 (after R2 + R4)
  R7 — Self-directed work
```

## Gate Analysis

| Gate | Triggered? | Rationale |
|------|-----------|-----------|
| Gate 4 | **YES — each MCP server activation is a per-expansion encounter.** The lethal trifecta is already COMPLETE in the current configuration (private data + untrusted content + external communication). The framing "does it add external reach" was corrected per E30 (2026-07-26). Each MCP server must be assessed in resulting-configuration form, with documented mitigations, before activation. The `ygg mcp` bridge is plumbing only — no server is started without explicit gardener Gate 4 approval. |
| Gate 1 | **Yes** — new work unit |
| Ratification | **Yes** — for protocol changes (R3, R7) and durable memory (R4) |
| Constitutional amendment | **No** — all changes are protocol-level or below |

## Completion Checklist

- [ ] R1 — Provenance consolidation protocol written and first consolidation run recorded
- [ ] R5 — Pre/post snapshots in staging workflow; regressions reported automatically
- [ ] R6 — Amendment hierarchy document exists with 5-layer classification
- [ ] MCP — `ygg mcp` bridge works with at least Memory and Git servers
- [ ] R2 — Adversarial test batteries exist for promotion candidates; Var runs them
- [ ] R3 — Improvement sprint protocol documented; at least one Kaizen sprint completed
- [ ] R4 — Correlation matrix in provenance.md; fallback triggers reference it
- [ ] R7 — Self-directed work protocol written; at least one T3 domain assessed as ready

---

## Loop Log

*(to be filled as tasks complete)*

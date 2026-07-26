# Staging — the ratification airlock

> Nothing reaches durable memory except through this file and gardener approval.
> Valid ratification channels: a local session, or a version-control commit. Never a remote message.

## Pending ratification

*(empty)*

<!--
Entry format:
- [fact] <content> (source: log/YYYY-MM-DD §wrap)
- [capability:skill] <name> - trigger: <...>. permissions: <...>. assertions: N drafted. risk: <...>. revocation: <...>
- [consolidation] promote <fact> from log to profile (seen N times)
-->

### Proposed 2026-07-26 — Read-Only Web-Search Connector

**Note — Lethal Trifecta COMPLETE (GATE).** The previous assessment asked "which of the three does this capability ADD" — the correct test is "which of the three conditions hold once the capability is active (in the resulting configuration)." All three hold. Five mitigations (M1–M5) are conditions for activation. Gardener approval required per Gate 4.

**Corrected lethal-trifecta assessment:**

| Condition | Holds in resulting configuration? | Why |
|---|---|---|
| **(a) Private data access** | **YES** | The companion already reads `profile.md`, `goals.md`, `projects.md`, `provenance.md`, and project files at every bootstrap. This is private data — the system's own memory about the gardener, goals, project state, and behavioural provenance. Private-data access predates this connector but still holds in the resulting configuration. |
| **(b) Untrusted content exposure** | **YES** (expanded) | The connector fetches search results from the open web. Anyone can inject content. This is a *systematic, automated* path for untrusted content — wider than manual `webfetch` usage. |
| **(c) External communication** | **YES** (expanded) | The connector sends queries to `api.duckduckgo.com:443`. The system already had `webfetch` as a general tool, but this capability creates a *programmatic, repeatable* egress path. |

**Verdict: LETHAL TRIFECTA COMPLETE.** All three conditions hold once the capability is active. Per gates.md §28: *"Any one alone is manageable; completing the set is a gate, not a preference."*

**Mandatory mitigations for activation (conditions):**

1. **M1 — Query construction isolation.** Every search query must be a static string or a user-provided parameter — never constructed by concatenating memory content (profile facts, goals, project data). A pre-dispatch validator checks the query string against a regex allowing only alphanumeric, spaces, hyphens, and common punctuation — rejecting any string containing known memory file paths, variable names, or structured data patterns.

2. **M2 — Untrusted-content doctrine enforcement.** All search results pass through an output sanitizer before being returned to the caller. The sanitizer MUST: strip all HTML tags, reject `javascript:` and `data:` URLs, limit snippet length to 200 chars, and flag any result containing model-invocation patterns (e.g., "system prompt", "ignore previous instructions") as potential injection with a warning. Results must NOT be written to durable memory (profile, goals, projects, capability registry) under any circumstance — they are ephemeral and scoped to the current turn only.

3. **M3 — Rate-limiting gate.** No more than 1 request per 2 seconds to prevent accidental DoS.

4. **M4 — Opt-in only.** The connector must be invoked explicitly via a named skill or tool — never as part of bootstrap, heartbeat, or background context. It cannot be triggered automatically.

5. **M5 — Charter constraint: huginn only.** Only huginn (the researcher role) may invoke this web-search connector. Huginn's charter explicitly grants no read access to `seed/memory/` files. This separation is structurally enforceable — the host enforces tool-level permissions per agent charter. The connector is never exposed to a role that can read private memory.

- [capability:connector] web-search - trigger: search query via webfetch to api.duckduckgo.com. permissions: egress to api.duckduckgo.com:443; webfetch tool; optional config file. assertions: 5 drafted. risk: LETHAL TRIFECTA COMPLETE — all three dimensions hold in resulting configuration (private-data access pre-existing; untrusted-content exposure and external communication expanded). Mitigations M1–M5 required before activation. revocation: remove skill file + config.

### Proposed 2026-07-26 — Boundaries amendment: @bifrost git permission [SELF-GOVERNANCE] — RATIFIED 2026-07-26

**Proposed change:** In `seed/constitution/boundaries.md`, change the "Must ask" entry:
```
- Any state-changing version-control operation.
```
To:
```
- Any state-changing version-control operation — except via @bifrost on explicit gardener instruction, which is permitted per [SELF-GOVERNANCE] decision. All other state-changing version-control paths remain must-ask.
```

**Rationale:** bifrost is a gardener-invokable-only subagent (absent from Odin's roster — cannot be invoked autonomously). Its charter enforces a plan-then-confirm workflow (present commands → stop → gardener approves → execute), making each state change a two-step human approval. Gate 4 assessment by heimdall returned PASS-WITH-CONDITIONS: specific git allow-rules only, seed memory read gap documented, no new git-initiated untrusted content paths. The lethal trifecta is already complete (web-search connector); git push does not change the trifecta status but introduces an outbound exfiltration channel mitigated by the structural roster exclusion and behavioural plan-then-confirm workflow.

**Conditions (from heimdall Gate 4):**
1. opencode.json git allow-rules must list individual commands (`git commit*`, `git push*`, `git tag*`, `git branch*`, `git merge*`) — never a wildcard `git *`.
2. The plan-then-confirm step in bifrost's charter is the primary structural defence and must not be removed or weakened.
3. bifrost's `read: true` means the seed/memory/ read prohibition (charter §31) is behavioural-only — documented in the capability registry.
4. This amendment does not extend to `git fetch`, `git pull`, `git clone` — those require a separate review.
- [canon:amendment] boundaries.md — permit state-changing git via @bifrost on explicit gardener instruction only. container: boundaries.md §Must ask. rationale: gardener-invokable-only role with plan-then-confirm workflow; Gate 4 assessed PASS-WITH-CONDITIONS. status: ratified 2026-07-26. [SELF-GOVERNANCE]

### Proposed 2026-07-26 — Graduated Autonomy Framework [SELF-GOVERNANCE] — RATIFIED 2026-07-26

**Problem:** Every domain is locked at `must-ask` despite clean records in some domains (cold resume: 1/1 correct stops; structural delegation: 1/1 correct stops). The provenance system collects data but has no graduation criteria.

**Proposed framework:**

A domain may be considered for migration from `must-ask` to `may-do-alone` when ALL of these conditions are met:

| # | Condition | Rationale |
|---|-----------|-----------|
| 1 | **Minimum 3 gate encounters** in the domain | A rule tested once could be luck. Three encounters provide minimum signal. |
| 2 | **100% correct-stop rate** across all encounters | Every encounter must have been handled correctly. A single failure resets the counter. |
| 3 | **Zero gardener overrides** in the domain | If the gardener had to override, the rule was insufficient — revisit before graduating. |
| 4 | **Zero corrections issued** in the domain for at least 30 consecutive days | Corrections indicate the rule or its application is not fully settled. |
| 5 | **At least one conformance assertion** exists that would detect a failure in this domain | Graduation requires an automated safety net — if the domain fails post-graduation, the assertion catches it. |
| 6 | **Gardener approves** the specific migration proposal | Migration is never automatic — it is proposed via staging and ratified like any durable change. |

**Migration workflow:**
1. Kvasir (architect) identifies domains meeting conditions 1-5 during a memory review.
2. Kvasir proposes the migration via a staging entry: `[autonomy:migration] <domain> from must-ask to may-do-alone`.
3. Odin presents the proposal with the evidence from provenance.md.
4. Gardener ratifies or rejects. Ratification is the explicit approval for condition 6.
5. On ratification, the domain's `autonomy_status` in provenance.md is updated from `must-ask` to `may-do-alone`.
6. A growth-ledger entry is recorded documenting the migration and the evidence that earned it.

**Demotion rules:**
- A domain graduated to `may-do-alone` that subsequently has a gate failure is immediately suspended to `must-ask`.
- Two failures post-graduation escalate to the gardener with a recommendation to add a structural gate.
- The provenance table tracks demotions in the "overrides" and "corrections" columns — a demotion counts as a correction.

**Initial candidates for graduation (provisional):**

| Domain | Encounters | Correct stops | Overrides | Corrections | Meets conditions? |
|--------|-----------|--------------|-----------|-------------|-------------------|
| cold resume | 1 | 1 | 0 | 0 | ❌ Needs 2 more encounters + condition 5 assertion |
| structural delegation | 1 | 1 | 0 | 0 | ❌ Needs 2 more encounters + condition 5 assertion |
| version control | 2 | 1 | 0 | 1 | ❌ Correction issued (E23 checkbox integrity); needs clean 30-day period |

No domain currently qualifies. This framework is forward-looking — the encounter baselines are too low.

- [protocol:migration] graduated-autonomy.md — formal protocol document to be generated if the framework is ratified. container: seed/protocols/graduated-autonomy.md. rationale: provenance data must translate into actionable autonomy changes; without a framework, every domain stays must-ask forever regardless of track record. status: ratified 2026-07-26. [SELF-GOVERNANCE]

# P5 — Self-Improvement Leaps

## Status
In Progress

## Loop Log

- **2026-07-29 P5 Loop 1 — Foundation (5.6 + 5.5):** Populated `seed/memory/relationships.md` with 18 pair entries from provenance records and deliberation artifacts (Huginn analysed, Kvasir structured, Muninn transcribed). Wrote `seed/protocols/archive.md` — full memory lifecycle protocol with 30-day hot window, 90-day consolidation, 14-day heartbeat window, promotion trigger for recurring facts, bootstrap date filter. Both delivered without code change — pure protocol and documentation.

## Objective
The seed learns from its own conduct, accumulates relational intelligence between roles, anticipates failure before it happens, evolves its memory to stay within context budget, and retrieves past knowledge by meaning — not only by file path.

## Entry condition
P2 build tasks complete. P3 may run concurrently — no shared dependency.

---

## Dependency Map

```
TRACK ALPHA (independent, parallel)
  5.6 — Relationships (foundation)       ← START HERE
  5.1 — Correction log → learning
  5.5 — Archive / memory evolution

TRACK BETA (after 5.6)
  5.8 — Knowledge index (structured retrieval)
  5.3 — Conditional trust
  5.8 ──→ 5.9 (feeds embedding seed)

TRACK GAMMA (after 5.5 + 5.8)
  5.9 — Local embedding RAG (semantic retrieval)
  5.4 — Deliberation wisdom (prior positions)
  5.7 — Pre-mortem protocol
  5.2 — Early warning / error budget
```

---

## Task Breakdown

### Track Alpha — Foundation (independent, parallel-capable)

#### 5.1 — Correction Log → Learning System
**Role:** Kvasir (protocol design) + Muninn (documentation)

**Done-condition (verbatim):**
> Before every task dispatch, Odin's loop protocol includes a `LEARNING-CHECK` step that reads `prior-evidence/FINDINGS.md`, matches the upcoming task's domain against past findings by pattern-matching the finding title and domain, cites any matching finding by its E-number, and states the specific measure in place that prevents recurrence. The protocol change is recorded in `seed/protocols/loop.md` and `seed/adapters/opencode/agents/odin.md`.

**Gardener:** Approve loop protocol change (~3 min review)

---

#### 5.5 — Permanent Log → Evolving Memory
**Role:** Kvasir (consolidation rules) + Muninn (archive protocol)

**Done-condition (verbatim):**
> An archive protocol is written at `seed/protocols/archive.md` specifying: logs older than 30 days are excluded from bootstrap loading (they remain on disk for audit but are not loaded into context); logs older than 90 days are consolidated into a monthly digest and the raw logs may be archived to cold storage; facts appearing in 3 or more log entries without being promoted to durable memory are flagged for consolidation proposal by Kvasir at the next memory review. The archive protocol includes the archive schedule, retention policy, and the promotion trigger. Bootstrap loading in `seed/protocols/session.md` is updated to reflect the 30-day window.

**Gardener:** Approve time thresholds (~2 min)

---

#### 5.6 — Empty Relational Ledger → Organizational Intelligence
**Role:** Huginn (analyse provenance for pair data) + Kvasir (stage proposals) + Muninn (transcribe)

**Done-condition (verbatim):**
> `seed/memory/relationships.md` contains at least one pair entry for each unique seat pair that has appeared in a deliberation or plan review, with: the number of deliberations between them, the interaction pattern observed, the standing check each seat applies to the other's work, the concession rate for each side, and the last deliberation date. Each entry is sourced from existing provenance records and deliberation artifacts — no facts are invented. Each entry is ratified through the standard staging process.

**Gardener:** Ratify ~8 pair entries (~2 min)
**Unlocks:** 5.3, 5.4, 5.7, 5.8

---

### Track Beta — Retrieval + Trust (after 5.6)

#### 5.8 — Knowledge Index (structured retrieval)
**Roles:** Huginn (schema research), Brokkr (retrieve command), Muninn (index creation + maintenance)

**Tasks:**
- 5.8.1 Huginn: Research existing topic-indexing conventions and produce schema for `knowledge-index.md`
- 5.8.2 Brokkr: Implement `ygg retrieve --topic <query>` as PS 5.1 script
- 5.8.3 Muninn: Create `knowledge-index.md` with entries for all deliberations and decisions
- 5.8.4 Muninn: Add post-deliberation update step to relevant workflow

**Done-condition (verbatim):**
> `knowledge-index.md` exists, has entries for all deliberations and decisions to date, and `ygg retrieve --topic <topic>` returns the correct file paths.

**Gardener:** Ratify initial schema and entries (standard staging)
**Dependency:** 5.6 (relationships)
**Unlocks:** 5.9 (embeddings seeded from index)

---

#### 5.3 — Binary Autonomy → Conditional Trust
**Roles:** Kvasir (protocol amendment) + Heimdall (security assessment)

**Done-condition (verbatim):**
> `seed/protocols/graduated-autonomy.md` is amended to add a third tier `conditional-autonomy` between `must-ask` and `may-do-alone`. A domain placed at conditional-autonomy operates autonomously unless a leading indicator — correction issued in any domain in the last 7 days, error-budget exceeded, or a related-domain gate failure — triggers automatic fallback to `must-ask` for that session. The migration conditions for `must-ask → conditional-autonomy` are documented (fewer conditions than full `may-do-alone`), and at least one domain from the provenance standing-counts table is assessed for qualification.

**Gardener:** Approve graduated-autonomy amendment (~5 min)
**Dependency:** 5.6 (relationships for trust metadata)
**Unlocks:** 5.7 (pre-mortem requires psychological safety of conditional trust)

---

### Track Gamma — Wisdom + Retrieval Depth (after 5.5 + 5.8)

#### 5.9 — Local Embedding RAG (semantic retrieval)
**Roles:** Huginn (research), Brokkr (implementation), Var (validation)

**Tasks:**
- 5.9.1 Huginn: Research best approach for local embedding with Ollama + nomic-embed-text in PS 5.1; produce embedding pipeline design
- 5.9.2 Brokkr: Implement `ygg embed --update` and `ygg retrieve --semantic "<query>"`
- 5.9.3 Var: Validate retrieval quality — confirm session-state memo returns as top result
- 5.9.4 Brokkr: Remediate quality gaps found by Var

**Constraints:**
- Must use Ollama free tier (already installed)
- Embedding model must be CPU-runnable (nomic-embed-text, ~137MB)
- Index stored as JSON file — portable across machines
- No new paid services (Goal 3)

**Done-condition (verbatim):**
> `ygg retrieve --semantic "find the decision about session-state"` returns `deliberation/session-brief-scope/memo.md` as the top result.

**Gardener:** Validate retrieval quality is sufficient
**Dependencies:** 5.5 (stable memory structure), 5.8 (knowledge index seeds the embedding)

---

#### 5.4 — Fresh-Start Deliberation → Accumulating Wisdom
**Roles:** Kvasir (protocol design) + Muninn (documentation update)

**Done-condition (verbatim):**
> Every seat file format in `seed/protocols/deliberation.md` is amended to include a "Prior positions and updates" section that cites the seat's earlier deliberation positions from `seed/memory/relationships.md` and states what has changed since. The memo synthesis includes a Bayesian-update-style confidence summary: "Seats that held position X in prior deliberations on similar topics: [count]. Those whose predictions were borne out: [count]. Current alignment: [qualitative assessment]." The protocol change is ratified.

**Gardener:** Approve deliberation format change (~3 min)
**Dependency:** 5.6 (relationships with populated pair entries)

---

#### 5.7 — Post-Hoc Review → Pre-Mortem
**Roles:** Kvasir (protocol amendment) + Var (validation methodology)

**Done-condition (verbatim):**
> `seed/protocols/deliberation.md` and `seed/protocols/planning-board.md` are amended to require a pre-mortem step before any significant plan or council: every seated role writes a short entry under the heading "Assume this plan has failed. What went wrong?" naming the most likely failure mode from their perspective. Pre-mortem entries are written before the main position/critique and are linked from the memo. The pre-mortem step is documented as a new file `00-pre-mortem.md` in the deliberation directory structure, read by all subsequent seats.

**Gardener:** Approve protocol change (~3 min)
**Dependencies:** 5.3 (conditional trust), 5.6 (relationships for standing checks)

---

#### 5.2 — Point-in-Time Metrics → Early Warning
**Roles:** Kvasir (SLI/SLO design) + Brokkr (monitoring implementation) + Var (validation)

**Done-condition (verbatim):**
> SLIs are defined for assertion pass rate (rolling 7-day), correction rate (per-domain per-week), and ratification velocity (hours from stage to approval). Each has a declared SLO target and a documented measurement method. A weekly error budget of 3 failure units is implemented: when the budget is exceeded, non-critical work is automatically slowed by deferring non-blocking tasks to the next loop. The error-budget state is written to `work/error-budget.md` and checked at every loop's reconcile step.

**Gardener:** Approve SLO targets and error-budget threshold (~10 min)
**Dependencies:** 5.1 (correction rate needs learning-check step), 5.4 (ratification velocity needs deliberation wisdom format)

---

## Completion Checklist

- [ ] Loop protocol calls FINDINGS.md before every dispatch (5.1)
- [ ] SLIs defined, SLOs set, error budget enforced (5.2)
- [ ] Conditional-autonomy tier added to graduated autonomy (5.3)
- [ ] Deliberation seats cite prior positions (5.4)
- [ ] Archive protocol written, bootstrap updated (5.5)
- [ ] Relationships.md populated for all deliberation pairs (5.6)
- [ ] Pre-mortem step in every significant plan/council (5.7)
- [ ] Knowledge index exists with topic→file mapping (5.8)
- [ ] Semantic retrieval works via local embeddings (5.9)

---

## Loop Log

*(to be filled as tasks complete)*

---

## Sequencing Recommendation

**First loop:** 5.6 (relationships) + 5.5 (archive) — both independent, zero code change for 5.6, directly addresses E29 context budget for 5.5. Two tasks, well within the max-3 ceiling.

**Second loop:** 5.1 (learning-check) + 5.8 (knowledge index schema + initial entries) — protocol change + structured index.

**Remaining loops:** Track Beta and Track Gamma in dependency order.

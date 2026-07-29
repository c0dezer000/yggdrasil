# Seat Relationships

> Durable-tier, append-only. Written only by ratified proposal after a deliberation, never
> directly [E11].
>
> Concession rates are recorded but never optimised or scored [D8].

Records the working history of each seat pair — who defers to whom on which topics, and whose
critiques consistently redirect outcomes. This is not a ranking. It is a trace of how persuasion
actually flows through the council.

Interaction modes per Team Topologies:
- **X-as-a-Service:** defined interface, low bandwidth, asynchronous
- **Collaboration:** high bandwidth, temporary, shared problem space
- **Facilitation:** one seat helps another operate more effectively

---

## Ledger

## skuld ↔ var

**Charters:** [[agents/skuld]], [[agents/var]]

**Deliberations:** 2

**Shared deliberations:**
1. 2026-07-28 — P3 prior plan review (no seat files preserved — deliberation.md:79 violated)
2. 2026-07-28 — deliberation/session-brief-scope/ (plan review)

**Pattern:** The system's most active pair. Var has twice failed Skuld's plans on verifiability grounds — in the P3 prior review (11 defective clauses, 6 High) and in session-brief-scope (17 findings, 1 Critical V3). The recurring defect class is a done-condition whose named command runs cleanly but proves something other than what it claims. Skuld has conceded every verifiability finding in both reviews without material resistance. Var acknowledges improvement: "The three named defect shapes do not recur."

**Var's standing check on Skuld's work:** Does every done-condition name what would prove it, and does the named command actually measure the claimed property?

**Skuld's standing check on Var's work:** Does Var's verifiability check account for the repair's load-bearing property, or does it catch only symptomatic defects?

**Concession rate:** Skuld conceded 28 of 28 contested items across 2 deliberations; Var conceded 2 of 29.

**Last:** 2026-07-28 — session-brief-scope (task 3.7 done-condition repair)

**Mode:** Collaboration during reviews; X-as-a-Service between reviews (Skuld sends plans, Var returns pass/fail).

---

## skuld ↔ kvasir

**Charters:** [[agents/skuld]], [[agents/kvasir]]

**Deliberations:** 2

**Shared deliberations:**
1. 2026-07-28 — P3 prior plan review (no seat files preserved)
2. 2026-07-28 — deliberation/session-brief-scope/ (plan review)

**Pattern:** Kvasir rules on structural fit and container placement; Skuld accepts rulings as binding. The signature interaction was RULING Q1: Skuld's own Finding 1 dissolved the gardener's placement argument, and Kvasir ruled for `work/session-state.md`. Kvasir also corrected Odin's prior report about Kvasir's own position (RULING Q2).

**Kvasir's standing check on Skuld's work:** Does the placement survive its own best argument?

**Skuld's standing check on Kvasir's work:** Has Kvasir re-read the sources it cites, or is it reasoning from recollection?

**Concession rate:** Skuld conceded 5 of 7 contested items; Kvasir conceded 1 of 7.

**Last:** 2026-07-28 — session-brief-scope (container ruling)

**Mode:** Collaboration during reviews with clear role boundary: Kvasir rules, Skuld builds to the ruling.

---

## skuld ↔ heimdall

**Charters:** [[agents/skuld]], [[agents/heimdall]]

**Deliberations:** 2

**Shared deliberations:**
1. 2026-07-28 — P3 prior plan review (no seat files preserved)
2. 2026-07-28 — deliberation/session-brief-scope/ (plan review)

**Pattern:** Heimdall reviews Skuld's plans for risk, particularly ground (B) — unthrottled remote execution. In session-brief-scope, Heimdall verified ground (B) is worse than stated (three fast paths, decorative rate-limit check, second script with no authorization) and ruled total avoidance sufficient for this loop. Skuld accepted all 8 conditions and 8 open findings.

**Heimdall's standing check on Skuld's work:** Does every destructive operation have negative tests? Are remote-trigger risks structurally excluded rather than promised?

**Skuld's standing check on Heimdall's work:** Is the security finding scoped to the actual plan, or broadened into a veto over unrelated work?

**Concession rate:** Skuld conceded 16 of 16 items; Heimdall conceded 3 of 16.

**Last:** 2026-07-28 — session-brief-scope (ground B avoidance, H-1 through H-8)

**Mode:** Facilitation — Heimdall's risk assessment helps Skuld design safer plans.

---

## kvasir ↔ var

**Charters:** [[agents/kvasir]], [[agents/var]]

**Deliberations:** 2

**Shared deliberations:**
1. 2026-07-28 — deliberation/harness-decision/ (full deliberation)
2. 2026-07-28 — deliberation/session-brief-scope/ (plan review)

**Pattern:** The two assessment seats with productive tension. In harness-decision, Var disproved Kvasir's evidence (same config produced 0 and 48 delegations). In session-brief-scope, their differing angles on the 3.7 repair were resolved by Skuld requiring both checks in one transcript.

**Var's standing check on Kvasir's work:** Does Kvasir's evidence claim rest on reproducible measurements?

**Kvasir's standing check on Var's work:** Does Var's procedural fix address the enforcement gap, or only improve the prose of an unpulled lever?

**Concession rate:** Kvasir conceded 5 of 6 contested items; Var conceded 1 of 6.

**Last:** 2026-07-28 — session-brief-scope (3.7 repair reconciliation)

**Mode:** Collaboration — high-bandwidth, shared problem space. Their different angles produce the sharpest multi-seat findings.

---

## var ↔ heimdall

**Charters:** [[agents/var]], [[agents/heimdall]]

**Deliberations:** 2

**Shared deliberations:**
1. 2026-07-28 — deliberation/harness-decision/ (full deliberation)
2. 2026-07-28 — deliberation/session-brief-scope/ (plan review; Heimdall wrote before Var existed)

**Pattern:** Var and Heimdall share a lab and frequently corroborate each other independently. In harness-decision, Heimdall adopted Var's category-error diagnosis and added a dimension Var missed. In session-brief-scope, their findings converged independently (doctor check 10, file-set gap) without either seeing the other's work. One unresolved tension: symmetry of branches vs second clause being false.

**Var's standing check on Heimdall's work:** Does the security finding change when the evidence set is widened?

**Heimdall's standing check on Var's work:** Does Var's assessment account for the executable state, or only the documentation?

**Concession rate:** 2 contested items unresolved. No seat conceded to the other on their named disagreement.

**Last:** 2026-07-28 — session-brief-scope (convergent independent findings)

**Mode:** Collaboration with independent convergence as the dominant pattern.

---

## kvasir ↔ brokkr

**Charters:** [[agents/kvasir]], [[agents/brokkr]]

**Deliberations:** 1

**Shared deliberations:**
1. 2026-07-28 — deliberation/harness-decision/ (full deliberation)

**Pattern:** The architect-builder pair with the sharpest three-way disagreement. Brokkr corrected Kvasir's table from 6 to 10 layers. Kvasir accepted the correction and Brokkr's third path as superior. Their named disagreement (architectural vs disciplinary) was adjudicated by Kvasir as architectural in form but not binding.

**Kvasir's standing check on Brokkr's work:** Does the estimate enumerate layers the architect has not considered?

**Brokkr's standing check on Kvasir's work:** Is the argument about properties of the boundary, or an unpulled lever?

**Concession rate:** Kvasir conceded 3 of 4 contested items; Brokkr conceded 1 of 4.

**Last:** 2026-07-28 — harness-decision (ten-layer table, third path)

**Mode:** Collaboration during deliberation with builder grounding architect's abstractions.

---

## heimdall ↔ brokkr

**Charters:** [[agents/heimdall]], [[agents/brokkr]]

**Deliberations:** 1

**Shared deliberations:**
1. 2026-07-28 — deliberation/harness-decision/ (full deliberation)

**Pattern:** Their single shared interaction was Disagreement B — the most contested three-way. Brokkr charged that Heimdall applied its strictest standard to others and exempted its own finding. Heimdall held its ground. Kvasir adjudicated that Heimdall was right about the form but wrong about the force.

**Heimdall's standing check on Brokkr's work:** Does the feasibility estimate account for the security dimension of each layer?

**Brokkr's standing check on Heimdall's work:** Is the security finding architectural, or a documented-but-unpulled lever?

**Concession rate:** 1 contested item, unresolved (0/1 each).

**Last:** 2026-07-28 — harness-decision (Disagreement B)

**Mode:** Collaboration during deliberation. Limited direct interaction.

---

## skuld ↔ brokkr

**Charters:** [[agents/skuld]], [[agents/brokkr]]

**Deliberations:** 0 (operational handoffs only)

**Pattern:** Skuld produces Loop Briefs with done-conditions; Brokkr executes against them. The core X-as-a-Service interaction of the loop protocol. Quality assurance is mediated by Var.

**Skuld's standing check on Brokkr's work:** Is the build within scope boundaries and authority profile?

**Brokkr's standing check on Skuld's work:** Do the done-conditions resolve to real commands in the actual environment?

**Concession rate:** Not applicable — no formal deliberation. Skuld's errors are caught by Var.

**Last:** 2026-07-28 — session-brief-scope (items 1-4 brief)

**Mode:** X-as-a-Service — Skuld specifies done-conditions, Brokkr builds to them.

---

## odin ↔ skuld

**Charters:** [[agents/odin]], [[agents/skuld]]

**Deliberations:** 0 (dispatch relationship)

**Pattern:** Odin dispatches Skuld as planner every loop. Skuld returns a Loop Brief. Odin routes to critics then to executing role. E18 and the ambiguity amendments define the boundary.

**Odin's standing check on Skuld's work:** Does Skuld's brief name an executing role from the roster and cite the correct active unit?

**Skuld's standing check on Odin's work:** Has Odin routed the brief to all required reviewers?

**Last:** 2026-07-28 — session-brief-scope (Odin dispatched Skuld)

**Mode:** X-as-a-Service — Odin requests a plan, Skuld returns it.

---

## odin ↔ gardener

**Charters:** [[agents/odin]], gardener

**Deliberations:** 0 (continuous operational loop)

**Pattern:** Gardener gives instructions; Odin dispatches seats; seats deliberate; Odin routes results. Every ledger entry is authored "gardener via Odin." The relationship has been refined through corrections: E11 (direct writes), E18 (orchestrator doing seat work), Entry 025 (ambiguity amendments).

**Odin's standing check on the Gardener's instructions:** Is this instruction clear enough to dispatch?

**Gardener's standing check on Odin's work:** Is Odin using the correctly chartered seat, or doing the work directly?

**Last:** 2026-07-28 — Entry 028 ratification (remote channel registered)

**Mode:** Facilitation — Odin executes the Gardener's intent through the seat roster.

---

## brokkr ↔ bifrost

**Charters:** [[agents/brokkr]], [[agents/bifrost]]

**Deliberations:** 0 (no shared deliberation evidence)

**Pattern:** Brokkr produces artifacts; Bifrost performs git operations on explicit gardener instruction. Handoff is via git. Bifrost is structurally outside Odin's roster.

**Brokkr's standing check on Bifrost's work:** [inferred from design: whether build artifacts are complete before deploy operation.]

**Bifrost's standing check on Brokkr's work:** [inferred from design: whether the build produces a deployable artifact.]

**Last:** 2026-07-26 — @bifrost boundaries amendment ratified (Entry 011)

**Mode:** X-as-a-Service — Brokkr produces artifacts, Bifrost deploys them.

---

## muninn ↔ skuld

**Charters:** [[agents/muninn]], [[agents/skuld]]

**Deliberations:** 1 (scribe relationship)

**Shared deliberations:**
1. 2026-07-28 — deliberation/session-brief-scope/ (muninn as transcriber)

**Pattern:** Muninn transcribes Skuld's position and response files because Skuld holds only `Read, Glob, Grep`. Four transcription discrepancies were caught (citation drift), none changing any conclusion.

**Muninn's standing check on Skuld's work:** Are the citations accurate to the source?

**Skuld's standing check on Muninn's work:** Is the transcription verbatim, or silently corrected?

**Concession rate:** Skuld accepted all 4 corrections (4/4).

**Last:** 2026-07-28 — session-brief-scope (transcription of 01 and 05)

**Mode:** Facilitation — Muninn provides the write capability Skuld lacks.

---

## verdandi ↔ skuld

**Charters:** [[agents/verdandi]], [[agents/skuld]]

**Deliberations:** 1 (decider relationship)

**Shared deliberations:**
1. 2026-07-28 — deliberation/session-brief-scope/ (Verdandi ruled PROCEED)

**Pattern:** Verdandi rules on whether a plan passes review. In session-brief-scope, ruled PROCEED with V3 resolved. Also resolved the ambiguity about roadmap edits being brokkr territory.

**Verdandi's standing check on Skuld's work:** Do the done-conditions incorporate all critic conditions?

**Skuld's standing check on Verdandi's work:** Is the ruling grounded in the record?

**Last:** 2026-07-28 — session-brief-scope (PROCEED after Var's FAIL)

**Mode:** Facilitation — Verdandi provides the decision gate.

---

## verdandi ↔ var

**Charters:** [[agents/verdandi]], [[agents/var]]

**Deliberations:** 1 (decider-critic relationship)

**Shared deliberations:**
1. 2026-07-28 — deliberation/session-brief-scope/ (Var FAIL, Verdandi PROCEED)

**Pattern:** Var filed FAIL. Verdandi considered V3 alongside Skuld's response and ruled conditions met. PROCEED did not overrule Var — it confirmed the fix.

**Verdandi's standing check on Var's work:** Is the FAIL a genuine blocking finding?

**Var's standing check on Verdandi's work:** Does the PROCEED ruling rest on the actual revised done-conditions?

**Last:** 2026-07-28 — session-brief-scope

**Mode:** Facilitation — distinct roles in the decision chain.

---

## odin ↔ kvasir

**Charters:** [[agents/odin]], [[agents/kvasir]]

**Deliberations:** 0 (dispatch and correction relationship)

**Pattern:** Odin dispatches Kvasir for structural-fit reviews. In the P3 prior review, Odin's summary of Kvasir's position was inaccurate. RULING Q2 found the loop log correct and Odin's report wrong.

**Odin's standing check on Kvasir's work:** Does the structural ruling cite the correct ratified entries?

**Kvasir's standing check on Odin's work:** Is the report a verbatim summary, or lossy-compressed?

**Last:** 2026-07-28 — session-brief-scope (RULING Q2)

**Mode:** Facilitation — Odin dispatches Kvasir and routes its rulings.

---

## odin ↔ heimdall

**Charters:** [[agents/odin]], [[agents/heimdall]]

**Deliberations:** 0 (escalation relationship)

**Pattern:** Heimdall issues BLOCK verdicts; Odin routes them to the gardener. Security BLOCK is a mandatory stop per gates.md. Odin does not override or adjudicate.

**Heimdall's standing check on Odin's work:** Are security findings routed without dilution?

**Odin's standing check on Heimdall's work:** Is the BLOCK scoped to the capability under review?

**Last:** 2026-07-28 — harness-decision (Heimdall's scoped BLOCK)

**Mode:** Facilitation — Heimdall's risk assessment enables safe dispatch.

---

## var ↔ brokkr

**Charters:** [[agents/var]], [[agents/brokkr]]

**Deliberations:** 0 (mediated through done-conditions)

**Pattern:** Var's verifiability findings constrain Brokkr's execution. In session-brief-scope, V13 identified self-certification risk (builder defining the scope it is measured against).

**Var's standing check on Brokkr's work:** Does the execution self-define the scope it is measured against?

**Brokkr's standing check on Var's work:** Has the verifiability check been run against actual commands in the actual environment?

**Last:** 2026-07-28 — session-brief-scope (V13)

**Mode:** X-as-a-Service — Var's criteria define the interface Brokkr builds to.

---

## Loki pairs — designed but untested

The following pairs involve Loki (opposition seat). Loki is chartered and has best-practice assertions embedded, but has never been seated in a deliberation. These entries will be updated once actual interaction occurs.

### skuld ↔ loki

**Charters:** [[agents/skuld]], [[agents/loki]]
**Pattern:** [inferred from design] Loki provides steelman counter-arguments to Skuld's plans.
**Last:** No interaction recorded.

### loki ↔ var

**Charters:** [[agents/loki]], [[agents/var]]
**Pattern:** [inferred from design] Loki challenges Var's verifiability findings from an adversarial angle.
**Last:** No interaction recorded.

### loki ↔ kvasir

**Charters:** [[agents/loki]], [[agents/kvasir]]
**Pattern:** [inferred from design] Loki pressure-tests Kvasir's structural rulings.
**Last:** No interaction recorded.

### loki ↔ heimdall

**Charters:** [[agents/loki]], [[agents/heimdall]]
**Pattern:** [inferred from design] Loki challenges Heimdall's risk assessments.
**Last:** No interaction recorded.

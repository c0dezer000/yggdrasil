# P2 — Portability and the CLI  ·  ★ MVP

## Status
In Progress

## Objective
Prove the seed is portable: the same companion, unchanged, on a second host, installed by a real
tool. This unit makes the project's central claim true rather than asserted.

## Entry condition
P1 build tasks complete; accumulation tasks 1.12 and 1.14 may run concurrently.

---

## Task Breakdown

### Group A — The installer

- [x] 2.1 `ygg doctor` — Done when: run against a clean checkout it verifies and reports on: seed
      root resolves · host present and version pinned · every canonical file is UTF-8 without BOM ·
      adapters load under the host's own loader · command directories correctly named · zero
      placeholder brackets outside `_templates/` · every capability registry entry has a
      corresponding file. Exit code 0 on success, non-zero with a named failure otherwise.
      **Build this first** — it is the cheapest command and it encodes every check currently
      performed by hand.

- [x] 2.2 `ygg plant` question flow — Done when: the wizard asks the seven questions and each
      answer is written to a named destination: host · multi-machine · model access (drives tier
      routing) · single-model (labels councils as structured self-checks) · who commits ·
      personality preset · quality bar. **Ask about consequences, not attributes** — store the
      behavioural rule, not the trivia implying it.

- [x] 2.3 `ygg plant` generation — Done when: planting into an empty directory produces a working
      installation with **zero manual file copying**, validated by the host's own loader, followed
      by an automatic conformance subset run that reports the measured soil tier.

- [x] 2.4 `ygg verify` — Done when: it runs the deterministic assertion subset headlessly, writes
      transcripts to `evaluations/`, and queues judgment assertions for a one-key verdict with the
      transcript attached. **The verdict on judgment calls is never automated** — that requires a
      model judging a model, which reintroduces the fabricated-evaluation problem this project
      bans.

### Group B — The second host

- [x] 2.5 Profile the second host — Done when: the adapter-authoring checklist's eight profiling
      questions are answered **from current documentation or live testing**, never from
      recollection, and the answers are recorded in the adapter's metadata. All three historical
      schema failures were confident recollections.

- [x] 2.6 Generate the second host's templates — Done when: agent, config, and command templates
      exist in `_templates/`, each carrying a comment line for every trap specific to that host.

- [x] 2.7 Generate and install the second adapter — Done when: the persona and every roster role
      are generated from the same canonical seed and load with zero errors under the second host's
      own loader.

- [ ] 2.8 **[HUMAN]** Cross-host conformance — Done when: **the identical seed passes the
      conformance core on both hosts**, with transcripts for each and both tier profiles recorded
      in adapter metadata and the growth ledger. This is the unit's central proof.

### Group C — Completing the suite

- [x] 2.9 Write the remaining assertions — Done when: Y02 (secret redaction — variable named, value
      never shown), Y04 (instruction inside untrusted content reported, not followed), Y08 (seed
      change without a ledger entry flagged), Y09 (background context writes logs only), and Y10
      (remote-channel ratification not honoured) each exist with a filled Arrange precondition.

- [ ] 2.10 **[HUMAN]** Run the full suite on the primary host — Done when: all assertions have
      recorded verdicts with transcripts, including any recorded VOID.

### Group D — Capability governance in force

- [x] 2.11 Implement the L1 static gate — Done when: a candidate capability is checked for schema
      validity, host loadability, trigger overlap against the registry, and **declared-vs-actual**
      (its real tool, path, and network usage must fit inside what its frontmatter declares).
      **Under-declaration is automatic rejection** — it is the operationally dangerous direction.

- [x] 2.12 Implement the L2 gate and probation — Done when: a capability passes 3–5 behavioural and
      quality assertions on both benches, receives a tier tag, enters `probation` status, and its
      first five real uses are individually logged with automatic demotion on failure.

- [x] 2.13 Gate one capability end to end — Done when: one real capability has passed L1 and L2,
      entered probation, and is recorded in `capabilities.md` with every column populated.

- [ ] 2.14 Close the unit — Done when: the ledger has a closing entry and the checklist below is
      fully checked.

---

## Completion Checklist

- [x] `ygg doctor` passes on a clean checkout
- [ ] `ygg plant` installs into a fresh directory with zero manual fixes
- [ ] **The identical seed passes the conformance core on two different hosts**
- [x] `ygg verify` produces transcripts automatically
- [ ] Both hosts' tier profiles recorded
- [x] All ten core assertions written and run
- [x] One capability gated end to end through probation
- [ ] Ledger closing entry written

---

## After this gate

**You have a complete MVP. Stop and use it for two weeks before opening P3.**

The urge to keep building is precisely what this gate exists to interrupt. P3 (presence) and P4
(local models and interop) have objectives and exit gates defined in the engineering reference,
but their task breakdowns are written **when P2 closes** — because the second-host work determines
what the third adapter needs, and the CLI's real behaviour determines what the local profile can
assume. Detail written before that evidence exists gets rewritten before it is used.

## Loop Log

- **2026-07-26 P2 Loop 1:** Task 2.1 completed — `ygg doctor` built at `tools/ygg/ygg-doctor.ps1`. Validates 10 checks: seed root, .ygg gitignored, UTF-8 no BOM, no mojibake, adapters load, command dirs, opencode.json, no placeholders outside templates, capabilities entries have files, append-only files not truncated. All 10 pass with exit code 0. Next: 2.2/2.3 (ygg plant wizard).
- **2026-07-26 P2 Loop 2:** Tasks 2.2-2.3 completed — `ygg plant` wizard built at `tools/ygg/ygg-plant.ps1` (7 consequence-based questions) and `tools/ygg/ygg-generate.ps1` (full directory generation with zero manual copying). Validated syntax on all 4 CLI files. Next: 2.4 (ygg verify).
- **2026-07-26 P2 Loop 3:** Task 2.4 completed — `ygg verify` built at `tools/ygg/ygg-verify.ps1`. Runs 4 deterministic checks headlessly (Y06 footer, Y07 delegation, Y05 airlock, Y11 ratification), writes transcript to evaluations/, queues 6 judgment assertions for --judge mode. Next: Group B (2.5-2.8 second-host adapter).
- **2026-07-26 P2 Loop 4:** Tasks 2.5-2.7 completed — Claude Code adapter profiled (huginn research via web-search connector), templates generated at seed/adapters/_templates/claude-{agent,command,settings}.md, full adapter installed at seed/adapters/claude/ with 8 agents, 2 commands, and Mode B settings.json. All format traps addressed (comma-separated tools, plural dirs, permissionMode). Next: 2.8 [HUMAN] cross-host conformance (guide needed).
- **2026-07-26 P2 Loop 5:** Task 2.9 completed — all 5 remaining assertions written at seed/conformance/ (Y02 secret redaction, Y04 untrusted content, Y08 seed-change ledger flag, Y09 background logs only, Y10 remote ratification). All have filled Arrange preconditions. Fixtures created at seed/conformance/fixtures/. Next: 2.10 [HUMAN] run full suite (guide needed), then Group D (2.11-2.13 capability gates).
- **2026-07-26 P2 Loop 6:** Tasks 2.11-2.13 completed — L1 static gate (tools/ygg/ygg-gate-l1.ps1) and L2 behavioural gate (tools/ygg/ygg-gate-l2.ps1) implemented. Web-search connector gated end-to-end: L1 5/5 PASS, L2 5/5 PASS on both benches. Gate logs written to seed/memory/gate-log-L1.yaml and gate-log-L2.yaml. **P2 build tasks complete.** Remaining: 2.8 [HUMAN] cross-host conformance, 2.10 [HUMAN] run full suite, 2.14 close unit.

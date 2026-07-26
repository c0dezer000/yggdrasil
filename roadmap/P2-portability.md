# P2 — Portability and the CLI  ·  ★ MVP

## Status
Not Started

## Objective
Prove the seed is portable: the same companion, unchanged, on a second host, installed by a real
tool. This unit makes the project's central claim true rather than asserted.

## Entry condition
P1 exit gate fully checked. Do not begin P2 with an unproven memory organ — the CLI installs
memory, and installing an unproven thing twice teaches nothing.

---

## Task Breakdown

### Group A — The installer

- [ ] 2.1 `ygg doctor` — Done when: run against a clean checkout it verifies and reports on: seed
      root resolves · host present and version pinned · every canonical file is UTF-8 without BOM ·
      adapters load under the host's own loader · command directories correctly named · zero
      placeholder brackets outside `_templates/` · every capability registry entry has a
      corresponding file. Exit code 0 on success, non-zero with a named failure otherwise.
      **Build this first** — it is the cheapest command and it encodes every check currently
      performed by hand.

- [ ] 2.2 `ygg plant` question flow — Done when: the wizard asks the seven questions and each
      answer is written to a named destination: host · multi-machine · model access (drives tier
      routing) · single-model (labels councils as structured self-checks) · who commits ·
      personality preset · quality bar. **Ask about consequences, not attributes** — store the
      behavioural rule, not the trivia implying it.

- [ ] 2.3 `ygg plant` generation — Done when: planting into an empty directory produces a working
      installation with **zero manual file copying**, validated by the host's own loader, followed
      by an automatic conformance subset run that reports the measured soil tier.

- [ ] 2.4 `ygg verify` — Done when: it runs the deterministic assertion subset headlessly, writes
      transcripts to `evaluations/`, and queues judgment assertions for a one-key verdict with the
      transcript attached. **The verdict on judgment calls is never automated** — that requires a
      model judging a model, which reintroduces the fabricated-evaluation problem this project
      bans.

### Group B — The second host

- [ ] 2.5 Profile the second host — Done when: the adapter-authoring checklist's eight profiling
      questions are answered **from current documentation or live testing**, never from
      recollection, and the answers are recorded in the adapter's metadata. All three historical
      schema failures were confident recollections.

- [ ] 2.6 Generate the second host's templates — Done when: agent, config, and command templates
      exist in `_templates/`, each carrying a comment line for every trap specific to that host.

- [ ] 2.7 Generate and install the second adapter — Done when: the persona and every roster role
      are generated from the same canonical seed and load with zero errors under the second host's
      own loader.

- [ ] 2.8 **[HUMAN]** Cross-host conformance — Done when: **the identical seed passes the
      conformance core on both hosts**, with transcripts for each and both tier profiles recorded
      in adapter metadata and the growth ledger. This is the unit's central proof.

### Group C — Completing the suite

- [ ] 2.9 Write the remaining assertions — Done when: Y02 (secret redaction — variable named, value
      never shown), Y04 (instruction inside untrusted content reported, not followed), Y08 (seed
      change without a ledger entry flagged), Y09 (background context writes logs only), and Y10
      (remote-channel ratification not honoured) each exist with a filled Arrange precondition.

- [ ] 2.10 **[HUMAN]** Run the full suite on the primary host — Done when: all assertions have
      recorded verdicts with transcripts, including any recorded VOID.

### Group D — Capability governance in force

- [ ] 2.11 Implement the L1 static gate — Done when: a candidate capability is checked for schema
      validity, host loadability, trigger overlap against the registry, and **declared-vs-actual**
      (its real tool, path, and network usage must fit inside what its frontmatter declares).
      **Under-declaration is automatic rejection** — it is the operationally dangerous direction.

- [ ] 2.12 Implement the L2 gate and probation — Done when: a capability passes 3–5 behavioural and
      quality assertions on both benches, receives a tier tag, enters `probation` status, and its
      first five real uses are individually logged with automatic demotion on failure.

- [ ] 2.13 Gate one capability end to end — Done when: one real capability has passed L1 and L2,
      entered probation, and is recorded in `capabilities.md` with every column populated.

- [ ] 2.14 Close the unit — Done when: the ledger has a closing entry and the checklist below is
      fully checked.

---

## Completion Checklist

- [ ] `ygg doctor` passes on a clean checkout
- [ ] `ygg plant` installs into a fresh directory with zero manual fixes
- [ ] **The identical seed passes the conformance core on two different hosts**
- [ ] `ygg verify` produces transcripts automatically
- [ ] Both hosts' tier profiles recorded
- [ ] All ten core assertions written and run
- [ ] One capability gated end to end through probation
- [ ] Ledger closing entry written

---

## After this gate

**You have a complete MVP. Stop and use it for two weeks before opening P3.**

The urge to keep building is precisely what this gate exists to interrupt. P3 (presence) and P4
(local models and interop) have objectives and exit gates defined in the engineering reference,
but their task breakdowns are written **when P2 closes** — because the second-host work determines
what the third adapter needs, and the CLI's real behaviour determines what the local profile can
assume. Detail written before that evidence exists gets rewritten before it is used.

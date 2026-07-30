# Knowledge Index

> Topic-to-file mapping for structured retrieval. Updated by Muninn after every deliberation
> and decision. Grep this file for `ygg retrieve --topic <topic>`.

## Topics

### architecture
- [[work/session-state]]  ephemeral session state file
- [[deliberation/harness-decision/]]  full deliberation: harness vs seed architecture
- [[deliberation/session-brief-scope/]]  plan review: session-brief scope and structure
- [[seed/protocols/deliberation]]  deliberation workspace protocol (file-based exchange)
- [[seed/protocols/planning-board]]  planning board structure and review flow
- [[seed/protocols/council]]  council protocol (structured adversarial deliberation)
- [[seed/protocols/phase-gate-standard]]  phase-gate readiness criteria (G1-G8, S1-S5)
- [[seed/protocols/tier-routing]]  model assignment per role by budget and independence
- [[seed/protocols/graduated-autonomy]]  migration protocol: must-ask to may-do-alone
- [[seed/protocols/inquiry]]  retrieve-before-stating discipline
- [[seed/constitution/boundaries]]  permission boundaries and must-never rules
- [[seed/constitution/gates]]  gate definitions including Gate 4 (external reach)
- [[seed/memory/knowledge-index]]  this file, topic-to-file mapping
- [[seed/memory/capabilities]]  capability registry (connectors, skills)
- [[seed/memory/staging]]  ratification airlock for durable memory
- [[prior-evidence/FINDINGS]]  full findings corpus (E1-E75+)
- [[prior-evidence/EXTRACTION-MAP]]  seed extraction map from predecessor

### security
- [[seed/constitution/gates]]  gate definitions, Gate 4 (external reach), mandatory stops
- [[seed/adapters/opencode/agents/heimdall]]  security review charter
- [[seed/adapters/opencode/agents/ratatoskr]]  remote channel responder (read-only primary)
- [[seed/memory/capabilities]]  capability registry with lethal-trifecta assessments
- [[seed/conformance/Y04-instruction-untrusted-content]]  Y04: instruction in untrusted content
- [[seed/conformance/Y16-lethal-trifecta-assessment]]  Y16: trifecta considers resulting configuration
- [[seed/conformance/Y09-background-context-logs-only]]  Y09: background writes logs only
- [[seed/conformance/Y10-remote-ratification-not-honoured]]  Y10: remote ratification not honoured
- [[seed/conformance/Y01-gated-action-stops]]  Y01: gated action stops
- [[seed/conformance/Y02-secret-redaction]]  Y02: secret redaction
- [[seed/conformance/README]]  conformance suite overview
- [[prior-evidence/FINDINGS]]  E30 (lethal trifecta correction), E47 (remote-channel registration)
- [[deliberation/harness-decision/03-heimdall-risk]]  heimdall's security BLOCK on daemon
- [[deliberation/harness-decision/memo]]  6 mandatory stop, 7 SECURITY REVIEW
- [[deliberation/session-brief-scope/04-heimdall-risk]]  ground B (avoided, not discharged)
- [[tools/ygg/ygg-daemon.ps1]]  background daemon (heartbeat scheduling, Telegram listener)
- [[tools/ygg/ygg-listen.ps1]]  Telegram inbound listener
- [[guides/incident-response-playbook]]  incident-response playbook
- [[guides/P3-remote-channel-test]]  remote channel test guide (6 tests, Y04 pass)

### planning
- [[roadmap/SLICES]]  work index (active phase, status, dependencies)
- [[roadmap/P0-foundation]]  P0: foundation phase tasks
- [[roadmap/P1-memory]]  P1: memory phase tasks
- [[roadmap/P2-portability]]  P2: portability + MVP phase tasks
- [[roadmap/P3-presence]]  P3: always-on presence phase tasks
- [[roadmap/P5-self-improvement]]  P5: self-improvement phase outline
- [[seed/protocols/loop]]  loop protocol (plan  execute  validate cycle)
- [[seed/protocols/planning-board]]  plan review before work begins
- [[seed/protocols/brief]]  session/loop brief protocol (four-section report)
- [[seed/adapters/opencode/agents/skuld]]  planner charter (read-only, selects next task)
- [[seed/adapters/opencode/agents/verdandi]]  controller charter (read-only, continue/complete/block)
- [[deliberation/session-brief-scope/]]  plan review: session-brief scope deliberation
- [[deliberation/session-brief-scope/01-skuld-position]]  skuld's position on session-brief scope
- [[deliberation/session-brief-scope/05-skuld-response]]  skuld's response to critics

### memory
- [[seed/memory/profile]]  gardener profile (identity, environment, access, preferences)
- [[seed/memory/goals]]  standing objectives (goals with staleness detection)
- [[seed/memory/projects]]  project index and state pointers
- [[seed/memory/relationships]]  seat pair relationship ledger
- [[seed/memory/capabilities]]  capability registry (connectors, skills, lethal trifecta)
- [[seed/memory/decisions]]  cross-project decision record (append-only)
- [[seed/memory/provenance]]  behavioural provenance ledger
- [[seed/memory/staging]]  ratification airlock for durable memory writes
- [[seed/memory/knowledge-index]]  this file, topic-to-file mapping
- [[seed/memory/distilled-local]]  compressed memory profile for local tier (2K tokens)
- [[seed/memory/log/]]  session digests and heartbeat logs
- [[seed/memory/log/2026-07-26]]  session digest 2026-07-26
- [[seed/memory/log/2026-07-28]]  session digest 2026-07-28
- [[seed/memory/log/2026-07-29]]  session digest 2026-07-29
- [[seed/memory/log/heartbeat-2026-07-26]]  heartbeat log 2026-07-26
- [[seed/memory/log/heartbeat-2026-07-27]]  heartbeat log 2026-07-27
- [[seed/memory/log/heartbeat-2026-07-28]]  heartbeat log 2026-07-28
- [[seed/memory/log/heartbeat-2026-07-29]]  heartbeat log 2026-07-29
- [[seed/protocols/archive]]  memory log lifecycle and archive protocol (proposed)
- [[seed/protocols/distill-local]]  compressed memory profile protocol
- [[seed/adapters/opencode/agents/kvasir]]  architect & memory consolidation charter
- [[seed/adapters/opencode/agents/muninn]]  memory & documentation keeper charter
- [[prior-evidence/FINDINGS]]  E26 (seed-root resolution), E29 (context budget)

### tooling
- [[tools/ygg/ygg.ps1]]  CLI dispatcher (subcommand router)
- [[tools/ygg/ygg.cmd]]  batch entry point
- [[tools/ygg/ygg-doctor.ps1]]  environment verification checks
- [[tools/ygg/ygg-plant.ps1]]  interactive seed installation wizard
- [[tools/ygg/ygg-verify.ps1]]  static content checks and judgment assertions
- [[tools/ygg/ygg-gate-l1.ps1]]  L1 static capability gate
- [[tools/ygg/ygg-gate-l2.ps1]]  L2 behavioural capability gate
- [[tools/ygg/ygg-gate-common.ps1]]  shared gate utilities
- [[tools/ygg/ygg-heartbeat.ps1]]  daily heartbeat (goal staleness, active unit)
- [[tools/ygg/ygg-daemon.ps1]]  background daemon (heartbeat scheduling, Telegram listener)
- [[tools/ygg/ygg-daemon-install.ps1]]  daemon installation script
- [[tools/ygg/ygg-listen.ps1]]  Telegram inbound listener
- [[tools/ygg/ygg-session-state.ps1]]  session-state subcommand
- [[tools/ygg/ygg-distill.ps1]]  memory distillation script
- [[tools/ygg/ygg-generate.ps1]]  file generation utility
- [[tools/ygg/ygg-retrieve.ps1]]  knowledge-index retrieval (grep-based)
- [[work/session-state]]  ephemeral session state (produced by ygg-session-state)

### communication
- [[seed/constitution/identity]]  register and tone, identity statement
- [[seed/constitution/values]]  core values
- [[seed/protocols/disclosure]]  disclosure footer protocol (skills|subagents|mem-writes)
- [[seed/adapters/opencode/agents/ratatoskr]]  remote channel responder charter
- [[seed/adapters/opencode/agents/odin]]  orchestrator charter (dispatch and relay)
- [[guides/P3-communication-channel]]  communication channel setup guide
- [[guides/P3-remote-channel-test]]  remote channel test guide (6 tests, Y04 pass)
- [[deliberation/harness-decision/03-heimdall-risk]]  heimdall's BLOCK on unauthenticated remote channel
- [[seed/conformance/Y04-instruction-untrusted-content]]  Y04 injection refusal
- [[seed/conformance/Y10-remote-ratification-not-honoured]]  Y10 remote ratification gate

### delegation
- [[seed/protocols/loop]]  loop protocol (dispatch, execute, validate, record)
- [[seed/protocols/deliberation]]  deliberation workspace (file-based seat exchange)
- [[seed/protocols/planning-board]]  planning board (review flow and role structure)
- [[seed/protocols/council]]  council protocol (structured adversarial deliberation)
- [[seed/protocols/consult]]  consultation protocol (new project adoption)
- [[seed/protocols/onboard]]  onboarding protocol (existing codebase adoption)
- [[seed/protocols/brief]]  brief protocol (session/loop report structure)
- [[seed/protocols/session]]  session protocol (bootstrap and wrap)
- [[seed/adapters/opencode/agents/odin]]  orchestrator charter (E18: never do seat work)
- [[seed/adapters/opencode/agents/skuld]]  planner charter (what next)
- [[seed/adapters/opencode/agents/verdandi]]  controller charter (whether to continue)
- [[seed/adapters/opencode/agents/muninn]]  memory keeper charter (index, canon, digests)
- [[seed/adapters/opencode/agents/var]]  validation charter (done-condition verification)
- [[seed/adapters/opencode/agents/brokkr]]  backend builder charter
- [[seed/adapters/opencode/agents/heimdall]]  security review charter
- [[seed/adapters/opencode/agents/huginn]]  researcher charter
- [[seed/adapters/opencode/agents/kvasir]]  architect & memory consolidation charter
- [[seed/adapters/opencode/agents/loki]]  opposition seat charter
- [[seed/conformance/Y07-real-delegation]]  Y07: real nested task-tool delegation
- [[seed/conformance/Y12-orchestrator-delegates]]  Y12: orchestrator delegates
- [[seed/memory/relationships]]  seat pair relationship ledger
- [[prior-evidence/FINDINGS]]  E18 (orchestrator doing seat work), E27 (roster compliance)

### quality
- [[seed/protocols/review]]  review protocol (seven checks, evidence-based)
- [[seed/protocols/phase-gate-standard]]  phase-gate criteria (G1-G8 must-meet, S1-S5 should-meet)
- [[seed/protocols/conformance]]  conformance protocol (before-creation sequence)
- [[seed/protocols/planning-board]]  plan review before work begins
- [[seed/adapters/opencode/agents/var]]  validation and QA charter
- [[seed/adapters/opencode/agents/forseti]]  code review charter
- [[seed/adapters/opencode/agents/loki]]  opposition seat charter
- [[seed/conformance/]]  Y-assertion suite (Y01 through Y16)
- [[seed/conformance/README]]  conformance suite overview
- [[seed/conformance/Y01-gated-action-stops]]  gated actions stop correctly
- [[seed/conformance/Y02-secret-redaction]]  secrets redacted from output
- [[seed/conformance/Y03-cold-resume]]  cold resume from files alone
- [[seed/conformance/Y04-instruction-untrusted-content]]  untrusted content reported
- [[seed/conformance/Y05-ratification-airlock]]  ratification airlock works
- [[seed/conformance/Y06-disclosure-footer]]  disclosure footer present and truthful
- [[seed/conformance/Y07-real-delegation]]  real nested task-tool delegation
- [[seed/conformance/Y08-seed-change-ledger-flag]]  seed changes logged
- [[seed/conformance/Y09-background-context-logs-only]]  background writes logs only
- [[seed/conformance/Y10-remote-ratification-not-honoured]]  remote ratification not honoured
- [[seed/conformance/Y11-ratification-completes]]  ratification completes staging cycle
- [[seed/conformance/Y12-orchestrator-delegates]]  orchestrator delegates
- [[seed/conformance/Y13-table-integrity]]  table state integrity
- [[seed/conformance/Y14-seed-root-unique]]  seed root unique
- [[seed/conformance/Y15-no-host-builtins]]  no host built-ins used
- [[seed/conformance/Y16-lethal-trifecta-assessment]]  trifecta considers resulting config
- [[seed/conformance/fixtures/]]  conformance test fixtures
- [[tools/ygg/ygg-verify.ps1]]  static content verification and judgment
- [[deliberation/session-brief-scope/02-var-critique]]  var's 17 findings (1 Critical, 3 High)
- [[deliberation/harness-decision/02-var-critique]]  var's critique of harness vs seed

### deliberation
- [[deliberation/harness-decision/]]  full deliberation: harness vs seed (7 files)
- [[deliberation/harness-decision/00-question]]  harness vs seed question and evidence
- [[deliberation/harness-decision/01-kvasir-position]]  kvasir's position (architect)
- [[deliberation/harness-decision/02-var-critique]]  var's critique (validation)
- [[deliberation/harness-decision/03-heimdall-risk]]  heimdall's risk review (security BLOCK)
- [[deliberation/harness-decision/04-brokkr-feasibility]]  brokkr's feasibility (10-layer table)
- [[deliberation/harness-decision/05-kvasir-response]]  kvasir's response to critics
- [[deliberation/harness-decision/memo]]  verdandi's synthesis memo (642 lines)
- [[deliberation/session-brief-scope/]]  plan review: session-brief scope (7 files)
- [[deliberation/session-brief-scope/00-question]]  session-brief scope question
- [[deliberation/session-brief-scope/01-skuld-position]]  skuld's position (planner)
- [[deliberation/session-brief-scope/02-var-critique]]  var's critique (17 findings)
- [[deliberation/session-brief-scope/03-kvasir-structure]]  kvasir's structural fit ruling
- [[deliberation/session-brief-scope/04-heimdall-risk]]  heimdall's risk review
- [[deliberation/session-brief-scope/05-skuld-response]]  skuld's response (all findings conceded)
- [[deliberation/session-brief-scope/memo]]  muninn's synthesis memo (448 lines)
- [[seed/protocols/deliberation]]  deliberation workspace protocol
- [[seed/memory/relationships]]  seat pair relationship ledger

### constitution
- [[seed/constitution/identity]]  register, tone, identity statement
- [[seed/constitution/boundaries]]  permission boundaries (May do alone, Must never, Must ask)
- [[seed/constitution/gates]]  gate definitions (Gate 1-4, mandatory stops)
- [[seed/constitution/values]]  core values
- [[seed/protocols/session]]  session protocol (bootstrap loads constitution first)
- [[seed/adapters/opencode/agents/odin]]  orchestrator charter (constitution enforcement)

### growth
- [[seed/growth/ledger]]  growth ledger (append-only seed changes with evidence)
- [[seed/memory/provenance]]  behavioural provenance ledger
- [[seed/memory/staging]]  ratification airlock staging area
- [[seed/memory/capabilities]]  capability registry
- [[seed/conformance/Y08-seed-change-ledger-flag]]  Y08: every seed change has ledger entry
- [[prior-evidence/FINDINGS]]  full findings corpus
- [[prior-evidence/EXTRACTION-MAP]]  seed extraction map

### conformance
- [[seed/conformance/]]  conformance assertion suite (Y01-Y16)
- [[seed/conformance/README]]  conformance suite overview
- [[seed/conformance/fixtures/]]  test fixture files
- [[seed/protocols/conformance]]  conformance protocol (before-creation sequence)
- [[tools/ygg/ygg-verify.ps1]]  static content verification and judgment
- [[tools/ygg/ygg-doctor.ps1]]  environment verification checks
- [[evaluations/]]  evaluation transcripts and verdicts
- [[evaluations/opencode/]]  opencode-specific evaluation transcripts
- [[evaluations/P2-self-certification]]  P2 self-certification results
- [[evaluations/session-state-build-report-2026-07-28]]  session-state build report

### review
- [[seed/protocols/review]]  review protocol (seven checks: narrowing, precondition, etc.)
- [[seed/protocols/planning-board]]  plan review before work begins
- [[seed/adapters/opencode/agents/var]]  validation charter (seven-check review process)
- [[seed/adapters/opencode/agents/forseti]]  code review charter
- [[seed/adapters/opencode/agents/loki]]  opposition seat charter
- [[deliberation/session-brief-scope/02-var-critique]]  var's 17-plan review findings
- [[deliberation/harness-decision/02-var-critique]]  var's critique with six falsifiers

### ygg
- [[tools/ygg/ygg.ps1]]  CLI dispatcher
- [[tools/ygg/ygg.cmd]]  batch entry point (calls ygg.ps1
- [[tools/ygg/ygg-retrieve.ps1]]  knowledge-index retrieval
- [[tools/ygg/ygg-doctor.ps1]]  environment checks
- [[tools/ygg/ygg-plant.ps1]]  seed installation
- [[tools/ygg/ygg-verify.ps1]]  static verification
- [[tools/ygg/ygg-gate-l1.ps1]]  L1 gate
- [[tools/ygg/ygg-gate-l2.ps1]]  L2 gate
- [[tools/ygg/ygg-gate-common.ps1]]  gate utilities
- [[tools/ygg/ygg-heartbeat.ps1]]  daily heartbeat
- [[tools/ygg/ygg-daemon.ps1]]  background daemon
- [[tools/ygg/ygg-daemon-install.ps1]]  daemon installation
- [[tools/ygg/ygg-listen.ps1]]  Telegram listener
- [[tools/ygg/ygg-session-state.ps1]]  session-state subcommand
- [[tools/ygg/ygg-distill.ps1]]  memory distillation
- [[tools/ygg/ygg-generate.ps1]]  file generation

### session-state
- [[work/session-state]]  ephemeral session state file (overwritten, never appended)
- [[tools/ygg/ygg-session-state.ps1]]  session-state subcommand (--update, --clear)
- [[tools/ygg/ygg.ps1]]  CLI dispatcher (subcommand router)
- [[guides/session-state-workflow]]  beginner-level workflow guide
- [[deliberation/session-brief-scope/]]  plan review that defined session-state scope
- [[deliberation/session-brief-scope/01-skuld-position]]  skuld's session-brief proposal
- [[deliberation/session-brief-scope/03-kvasir-structure]]  kvasir's container ruling (work/ not seed/memory/log/)
- [[evaluations/session-state-build-report-2026-07-28]]  build report transcript
- [[evaluations/session-state-guide-run-2026-07-28]]  guide run transcript
- [[seed/protocols/loop]]  step 7b: session-state update in loop

### heartbeat
- [[tools/ygg/ygg-heartbeat.ps1]]  heartbeat mechanism (daily check, briefing, --full flag)
- [[seed/memory/log/heartbeat-*-]]  daily heartbeat logs
- [[roadmap/P3-presence]]  task 3.1 (heartbeat) and 3.7 (Y09 verification)
- [[seed/conformance/Y09-background-context-logs-only]]  Y09: background writes logs only
- [[seed/memory/goals]]  goals parsed by heartbeat for staleness
- [[seed/memory/staging]]  staging age checked by heartbeat
- [[guides/schedule-heartbeat]]  heartbeat scheduling guide

### remote-channel
- [[seed/adapters/opencode/agents/ratatoskr]]  remote channel responder (read-only primary)
- [[tools/ygg/ygg-listen.ps1]]  Telegram inbound listener
- [[tools/ygg/ygg-daemon.ps1]]  background daemon (Telegram dispatch)
- [[seed/memory/capabilities]]  remote-channel capability row (probation)
- [[seed/conformance/Y04-instruction-untrusted-content]]  Y04 injection refusal
- [[guides/P3-communication-channel]]  communication channel setup
- [[guides/P3-remote-channel-test]]  remote channel test guide (6 tests, E75 fail-closed)
- [[deliberation/harness-decision/03-heimdall-risk]]  heimdall's security BLOCK on daemon
- [[guides/schedule-listener]]  listener scheduling guide
- [[prior-evidence/FINDINGS]]  E47 (remote-channel re-staged), E75 (ratatoskr fail-closed)

### agent-charters
- [[seed/adapters/opencode/agents/odin]]  orchestrator (primary, write+edit+bash)
- [[seed/adapters/opencode/agents/skuld]]  planner (subagent, read-only)
- [[seed/adapters/opencode/agents/verdandi]]  controller (subagent, read-only)
- [[seed/adapters/opencode/agents/muninn]]  memory keeper (subagent, write only)
- [[seed/adapters/opencode/agents/var]]  validation (subagent, write+edit+bash)
- [[seed/adapters/opencode/agents/brokkr]]  backend builder (subagent, write+edit+bash)
- [[seed/adapters/opencode/agents/heimdall]]  security (subagent, write+edit+bash)
- [[seed/adapters/opencode/agents/huginn]]  researcher (subagent, write only)
- [[seed/adapters/opencode/agents/kvasir]]  architect (subagent, write only)
- [[seed/adapters/opencode/agents/ratatoskr]]  remote responder (primary, read-only)
- [[seed/adapters/opencode/agents/forseti]]  code review (subagent, read-only)
- [[seed/adapters/opencode/agents/loki]]  opposition seat (subagent, read-only)
- [[seed/adapters/opencode/agents/sindri]]  frontend builder (subagent, write+edit+bash)
- [[seed/adapters/opencode/agents/mimir]]  data/schema (subagent, write+edit+bash)
- [[seed/adapters/opencode/agents/bifrost]]  deployment (subagent, gardener-invokable only)

### protocol
- [[seed/protocols/session]]  session bootstrap and wrap
- [[seed/protocols/loop]]  loop plan-execute-validate-record cycle
- [[seed/protocols/deliberation]]  deliberation workspace (file-based seat exchange)
- [[seed/protocols/planning-board]]  plan review before execution
- [[seed/protocols/council]]  council protocol (adversarial deliberation)
- [[seed/protocols/brief]]  session/loop brief production
- [[seed/protocols/review]]  review protocol (seven checks)
- [[seed/protocols/conformance]]  conformance before-creation sequence
- [[seed/protocols/inquiry]]  retrieve-before-stating discipline
- [[seed/protocols/disclosure]]  disclosure footer (skills|subagents|mem-writes)
- [[seed/protocols/consult]]  consultation for new projects
- [[seed/protocols/onboard]]  onboarding for existing codebases
- [[seed/protocols/off-map]]  off-map request classification
- [[seed/protocols/tier-routing]]  model assignment per role
- [[seed/protocols/phase-gate-standard]]  phase-gate readiness criteria
- [[seed/protocols/graduated-autonomy]]  autonomy migration protocol
- [[seed/protocols/distill-local]]  compressed memory for local tier
- [[seed/protocols/archive]]  memory log lifecycle (proposed)

## Domains

### Architecture
- [[work/session-state]]  ephemeral session state file
- [[deliberation/*]] 
- [[seed/protocols/deliberation]]  deliberation workspace protocol
- [[seed/protocols/planning-board]]  planning board structure
- [[seed/protocols/council]]  council protocol
- [[seed/protocols/phase-gate-standard]]  phase-gate criteria
- [[seed/protocols/tier-routing]]  model assignment per role
- [[seed/protocols/graduated-autonomy]]  migration protocol
- [[seed/protocols/inquiry]]  retrieve-before-stating
- [[seed/constitution/boundaries]]  permission boundaries
- [[seed/constitution/gates]]  gate definitions
- [[seed/memory/capabilities]]  capability registry
- [[seed/memory/staging]]  ratification airlock
- [[seed/memory/knowledge-index]]  this file

### Security
- [[seed/constitution/gates]]  gate definitions including Gate 4
- [[seed/adapters/opencode/agents/heimdall]]  security review charter
- [[seed/adapters/opencode/agents/ratatoskr]]  remote channel responder
- [[seed/memory/capabilities]]  capability registry with lethal-trifecta
- [[seed/conformance/Y04-instruction-untrusted-content]]  Y04
- [[seed/conformance/Y09-background-context-logs-only]]  Y09
- [[seed/conformance/Y10-remote-ratification-not-honoured]]  Y10
- [[seed/conformance/Y16-lethal-trifecta-assessment]]  Y16
- [[seed/conformance/Y01-gated-action-stops]]  Y01
- [[seed/conformance/Y02-secret-redaction]]  Y02
- [[deliberation/harness-decision/03-heimdall-risk]]  security BLOCK
- [[deliberation/harness-decision/memo]]  6 mandatory stop
- [[deliberation/session-brief-scope/04-heimdall-risk]]  ground B
- [[tools/ygg/ygg-daemon.ps1]]  background daemon
- [[tools/ygg/ygg-listen.ps1]]  listener
- [[guides/incident-response-playbook]]  playbook
- [[prior-evidence/FINDINGS]]  E30, E47

### Planning
- [[roadmap/SLICES]]  work index
- [[roadmap/P3-presence]]  active P3 tasks
- [[roadmap/P0-foundation]]  P0 tasks
- [[roadmap/P1-memory]]  P1 tasks
- [[roadmap/P2-portability]]  P2 tasks
- [[seed/protocols/loop]]  loop protocol
- [[seed/protocols/planning-board]]  planning board
- [[seed/protocols/brief]]  brief protocol
- [[seed/adapters/opencode/agents/skuld]]  planner charter
- [[seed/adapters/opencode/agents/verdandi]]  controller charter
- [[deliberation/session-brief-scope/]]  plan review deliberation

### Memory
- [[seed/memory/profile]]  gardener profile
- [[seed/memory/goals]]  standing objectives
- [[seed/memory/projects]]  project index
- [[seed/memory/relationships]]  seat relationships
- [[seed/memory/capabilities]]  capability registry
- [[seed/memory/decisions]]  decision record
- [[seed/memory/provenance]]  behavioural provenance
- [[seed/memory/staging]]  ratification airlock
- [[seed/memory/knowledge-index]]  this file
- [[seed/memory/distilled-local]]  compressed profile
- [[seed/memory/log/]]  session digests and heartbeat logs
- [[seed/protocols/archive]]  log lifecycle (proposed)
- [[seed/protocols/distill-local]]  distillation protocol
- [[seed/adapters/opencode/agents/kvasir]]  memory consolidation
- [[seed/adapters/opencode/agents/muninn]]  memory keeper

### Tooling
- [[tools/ygg/ygg.ps1]]  CLI dispatcher
- [[tools/ygg/ygg.cmd]]  batch entry point
- [[tools/ygg/ygg-retrieve.ps1]]  knowledge-index retrieval
- [[tools/ygg/ygg-doctor.ps1]]  environment checks
- [[tools/ygg/ygg-plant.ps1]]  seed installation
- [[tools/ygg/ygg-verify.ps1]]  static verification
- [[tools/ygg/ygg-gate-l1.ps1]]  L1 gate
- [[tools/ygg/ygg-gate-l2.ps1]]  L2 gate
- [[tools/ygg/ygg-gate-common.ps1]]  gate utilities
- [[tools/ygg/ygg-heartbeat.ps1]]  daily heartbeat
- [[tools/ygg/ygg-daemon.ps1]]  background daemon
- [[tools/ygg/ygg-daemon-install.ps1]]  daemon installation
- [[tools/ygg/ygg-listen.ps1]]  Telegram listener
- [[tools/ygg/ygg-session-state.ps1]]  session-state subcommand
- [[tools/ygg/ygg-distill.ps1]]  memory distillation
- [[tools/ygg/ygg-generate.ps1]]  file generation

### Communication
- [[seed/constitution/identity]]  register and tone
- [[seed/constitution/values]]  core values
- [[seed/protocols/disclosure]]  disclosure footer
- [[seed/adapters/opencode/agents/ratatoskr]]  remote channel responder
- [[seed/adapters/opencode/agents/odin]]  orchestrator
- [[guides/P3-communication-channel]]  channel setup
- [[guides/P3-remote-channel-test]]  channel test guide
- [[deliberation/harness-decision/03-heimdall-risk]]  security BLOCK
- [[seed/conformance/Y04-instruction-untrusted-content]]  Y04
- [[seed/conformance/Y10-remote-ratification-not-honoured]]  Y10

### Delegation
- [[seed/protocols/loop]]  loop protocol
- [[seed/protocols/deliberation]]  deliberation protocol
- [[seed/protocols/planning-board]]  planning board
- [[seed/protocols/council]]  council protocol
- [[seed/protocols/session]]  session protocol
- [[seed/adapters/opencode/agents/odin]]  orchestrator charter
- [[seed/adapters/opencode/agents/skuld]]  planner charter
- [[seed/adapters/opencode/agents/verdandi]]  controller charter
- [[seed/memory/relationships]]  seat relationships
- [[seed/conformance/Y07-real-delegation]]  Y07
- [[seed/conformance/Y12-orchestrator-delegates]]  Y12
- [[prior-evidence/FINDINGS]]  E18, E27

### Quality
- [[seed/protocols/review]]  review protocol (seven checks)
- [[seed/protocols/phase-gate-standard]]  phase-gate criteria
- [[seed/protocols/conformance]]  conformance protocol
- [[seed/adapters/opencode/agents/var]]  validation charter
- [[seed/adapters/opencode/agents/forseti]]  code review charter
- [[seed/adapters/opencode/agents/loki]]  opposition seat
- [[seed/conformance/]]  Y-assertion suite
- [[tools/ygg/ygg-verify.ps1]]  static verification
- [[deliberation/session-brief-scope/02-var-critique]]  var's 17 findings
- [[deliberation/harness-decision/02-var-critique]]  var's critique

### Deliberation
- [[deliberation/harness-decision/]]  full deliberation: harness vs seed
- [[deliberation/session-brief-scope/]]  plan review: session-brief scope
- [[seed/protocols/deliberation]]  deliberation protocol
- [[seed/memory/relationships]]  seat relationships

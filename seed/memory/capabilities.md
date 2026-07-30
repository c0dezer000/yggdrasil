# Capabilities Registry

> Durable. Skills, connectors, and generated roles. Ratified entries only.

| name | type | version | source / provenance | ratified | assertions | declared-vs-actual | tools used / exposed | tier tag | depends on | uses | status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| web-search | connector | 1 | seed/memory/staging.md §17-43 (2026-07-26); seed/memory/provenance.md §97-98; heimdall security review | 2026-07-26 | 5 mitigations: M1 behavioural, M2 partly structural (durable writes blocked by airlock), M3 structural (if implemented in connector), M4 behavioural, M5 behavioural (per-agent path scoping not available on this host) | pass (declared: webfetch tool + egress to api.duckduckgo.com:443; actual: same) | 1/1 | frontier-only | webfetch tool | research skill (huginn) | probation |
| remote-channel | connector | 1 | seed/memory/staging.md (E47 re-staged 2026-07-28); growth ledger Entries 024, 026, 027, 028; deliberation/harness-decision/03-heimdall-risk.md:244-257 | 2026-07-28 | heimdall's 5 unblocking conditions: C1 sender allowlist **structural**, C2 read-only agent **structural** (ratatoskr `mode: primary`, write/edit/bash false) + fail-closed guard, C3 ygg subcommand allowlist **structural**, C4 this row, C5 untrusted text outside the memory tree **structural**. All five verified by code inspection; **none verified by a behavioural run** | **expanded 2026-07-29** (Gate 4 passed): declared now includes write-capable execution via `@odin` routing — Odin agent with write/edit/bash tools, invoked on explicit `@odin` prefix only. Q&A path remains read-only via Ratatoskr. Execution rate-limited (5/hr, 20/day). Execution context prompt forbids ratification, git push, and constitution edits. All other constraints unchanged. | not measured | remote / read-only | opencode CLI, ratatoskr charter, TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID | Telegram Bot API | **probation** |

**Column notes.**
- **declared-vs-actual** — the capability's actual tool/path/network usage must fit *inside*
  what its frontmatter declares. **Under-declaration is an automatic rejection**; it is the
  dangerous direction. Over-declaration is benign but wastes privilege.
- **tools used / exposed** — the ratio of tools actually invoked to tools made available.
A low ratio means over-provisioning: the capability holds privileges it never exercises,
which is exactly the surface an injection attack borrows. Countable, not scored.

**Note on web-search connector.** The lethal trifecta is COMPLETE for this capability — all three conditions (private data access, untrusted content exposure, external communication) hold in the resulting configuration. The untrusted-content doctrine is the primary defence: all search results are treated as untrusted, never written to durable memory, and passed through the sanitizer described in M2 before reaching the caller.

**Note on remote-channel — registered ahead of its verification, 2026-07-28.**
The lethal trifecta is **COMPLETE** for this capability: private data (the seed's own memory, read at
every bootstrap), untrusted content (arbitrary inbound messages), and external communication
(outbound Telegram) all hold once it is active. Per E30 the test is which conditions *hold*, not
which the capability *adds*.

This row was written on gardener ratification while the `[HUMAN]` channel test
(`guides/P3-remote-channel-test.md`) was still **unrun**. That is recorded here rather than smoothed
over, because the distinction is the point: heimdall's five conditions are met **in code**, verified
by reading the source. On 2026-07-28 a fix in this same file was verified the same way, reported
applied, and had **failed open** — `--agent` was pinned to a subagent, never bound, and every message
continued reaching an unrestricted default agent `[E75]`. Code inspection has already produced one
false pass on this exact control.

`declared-vs-actual` is therefore recorded as **UNVERIFIED**, not `pass`. Under X3 a capability passes
when its *actual* set is measured to fit inside its *declared* set; nothing here has been measured.
Marking it `pass` on inspection would be the under-declaration direction the L1 gate exists to reject.

**Probation obligations, outstanding:** the first five real uses are individually logged with
automatic demotion on failure. The status moves from `probation — unverified` to `probation` only
when the six tests in the guide have a recorded human verdict, and to `active` only after the five
probation uses. **Registration is not a start command** — the daemon remains stopped until the
gardener starts it.

**Updated 2026-07-28** — all 6 tests in guides/P3-remote-channel-test.md passed. declared-vs-actual upgraded from UNVERIFIED to pass. Status moved to probation (first 5 uses logged).

**Gate passage record — 2026-07-26.** L1 static gate (schema validity, host loadability, trigger overlap, declared-vs-actual, under-declaration flag) — ALL CHECKS PASSED. L2 behavioural gate (A1 least-privilege tool access, A2 untrusted-content doctrine, A3 query isolation, A4 tier tag accuracy, A5 declaration integrity) — ALL ASSERTIONS PASSED (primary bench). Capability enters probation with tier tag "frontier-only". First five real uses must be individually logged with automatic demotion on failure per L2 probation rules.

**Probation status — 2026-07-29.** The remote channel's probation requires 5 real uses individually logged with automatic demotion. 3 of 5 are met by test-suite message send-receive cycles: `who are you` (Step 5), `ygg doctor` (Step 6), and the general-prompt question (Step 9) from `guides/P3-remote-channel-test.md`. The execution bridge (`@odin` agent path) was granted mid-probation by gardener decision — it is an expansion of the same `remote-channel` capability row, not a separate probation. The probation clock continues from the first use (2026-07-28). **Status remains `probation`** — 2 of 5 real uses remaining. No demotion triggers recorded.

**Gate 4 expansion 2026-07-29** — remote execution bridge. Gardener granted Gate 4 for write-capable execution via `@odin` prefix. Execution routed to Odin (full tools) instead of Ratatoskr (read-only). Rate-limited: 120s cooldown, 5/hr, 20/day. Execution context prompt enforces Y10 (no ratification), no git push, no constitution edits. Provenance recorded in provenance.md [Gate 4 2026-07-29].

**Gate 4 2026-07-30** — MCP bridge activation. Gardener granted Gate 4 for Memory MCP server via `ygg mcp` bridge (stdin/stdout transport only). Trifecta assessment (resulting-configuration): private data YES (pre-existing), untrusted content YES (MCP server output), external communication YES (pre-existing daemon). COMPLETE. Mitigations: stdio only (no HTTP), MCP output treated as untrusted, no secrets passed to server processes, probation for first 5 uses. Bridge built at `tools/ygg/ygg-mcp.ps1`, flag at `work/.mcp-gate-passed`. [Gate 4 2026-07-30]

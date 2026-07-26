# Capabilities Registry

> Durable. Skills, connectors, and generated roles. Ratified entries only.

| name | type | version | source / provenance | ratified | assertions | declared-vs-actual | tools used / exposed | tier tag | depends on | uses | status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| web-search | connector | 1 | seed/memory/staging.md §17-43 (2026-07-26); seed/memory/provenance.md §97-98; heimdall security review | 2026-07-26 | 5 mitigations: M1 behavioural, M2 partly structural (durable writes blocked by airlock), M3 structural (if implemented in connector), M4 behavioural, M5 behavioural (per-agent path scoping not available on this host) | pass (declared: webfetch tool + egress to api.duckduckgo.com:443; actual: same) | 1/1 | frontier-only | webfetch tool | research skill (huginn) | probation |

**Column notes.**
- **declared-vs-actual** — the capability's actual tool/path/network usage must fit *inside*
  what its frontmatter declares. **Under-declaration is an automatic rejection**; it is the
  dangerous direction. Over-declaration is benign but wastes privilege.
- **tools used / exposed** — the ratio of tools actually invoked to tools made available.
A low ratio means over-provisioning: the capability holds privileges it never exercises,
which is exactly the surface an injection attack borrows. Countable, not scored.

**Note on web-search connector.** The lethal trifecta is COMPLETE for this capability — all three conditions (private data access, untrusted content exposure, external communication) hold in the resulting configuration. The untrusted-content doctrine is the primary defence: all search results are treated as untrusted, never written to durable memory, and passed through the sanitizer described in M2 before reaching the caller.

**Gate passage record — 2026-07-26.** L1 static gate (schema validity, host loadability, trigger overlap, declared-vs-actual, under-declaration flag) — ALL CHECKS PASSED. L2 behavioural gate (A1 least-privilege tool access, A2 untrusted-content doctrine, A3 query isolation, A4 tier tag accuracy, A5 declaration integrity) — ALL ASSERTIONS PASSED (primary bench). Capability enters probation with tier tag "frontier-only". First five real uses must be individually logged with automatic demotion on failure per L2 probation rules.

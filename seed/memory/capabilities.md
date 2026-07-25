# Capabilities Registry

> Durable. Skills, connectors, and generated roles. Ratified entries only.

| name | type | version | source / provenance | ratified | assertions | declared-vs-actual | tools used / exposed | tier tag | depends on | uses | status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| | skill/connector/agent | | | | | pass/fail | n/m | local-ok/frontier-only | | | probation/trusted/demoted/retired |

**Column notes.**
- **declared-vs-actual** — the capability's actual tool/path/network usage must fit *inside*
  what its frontmatter declares. **Under-declaration is an automatic rejection**; it is the
  dangerous direction. Over-declaration is benign but wastes privilege.
- **tools used / exposed** — the ratio of tools actually invoked to tools made available.
  A low ratio means over-provisioning: the capability holds privileges it never exercises,
  which is exactly the surface an injection attack borrows. Countable, not scored.

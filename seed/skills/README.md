# Skills — canonical source

> Skills live here, in the seed. Host directories are **generated from** these files, never
> authored in place — the same rule `seed/adapters/` follows for agent charters.

## Why this directory exists

Until 2026-07-28 the project's only skill existed solely at
`~/.config/opencode/skills/research/SKILL.md` — outside the repository, outside version control,
absent from the Claude adapter, and not reproducible by `ygg plant`. A seed whose central claim is
portability had a capability that could not travel `[E70]`.

## Install targets

| Host | Destination |
|---|---|
| OpenCode | `~/.config/opencode/skills/<name>/SKILL.md` |
| Claude Code | `.claude/skills/<name>/SKILL.md` |

Both are generated copies. When a skill changes, it changes here first, then both hosts are
re-copied and the change is recorded in the growth ledger.

## Current skills

| Skill | Source | Installed on | Conformance assertion |
|---|---|---|---|
| `research` | `seed/skills/research/SKILL.md` | OpenCode only — **not yet installed for Claude Code** | **none — owed** `[E69]` |

**Known gaps, recorded rather than hidden:**

- The `research` skill is not installed for Claude Code. Copying it to `.claude/skills/research/`
  is untested on this soil and is deliberately not done as part of an audit remediation; it needs a
  loader check of its own.
- No conformance assertion enforces the skill's anti-confabulation rule. Task 1.10's done-condition
  requires one and it does not exist; 1.10 is unticked accordingly `[E69]`.
- `ygg doctor` does not yet check that host skill copies match this directory. That check is owed
  and is the skill-side equivalent of the generator-drift check already run for adapters.

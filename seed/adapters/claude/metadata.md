# Claude Code Adapter — Metadata

## Soil Profile

Profile produced by huginn via web-search connector (current documentation); eight profiling questions answered below.

| # | Question | Answer | Detail |
|---|----------|--------|--------|
| 1 | Does it load local instruction files? | **YES** — qualified soil | Claude Code loads `CLAUDE.md` at session start by walking up the directory tree. Also loads `.claude/rules/*.md` and auto-memory. This is a qualified soil. |
| 2 | Where do agent/persona files live? | `.claude/agents/` (project scope), `~/.claude/agents/` (user scope) | Scanned recursively. Agent identity comes from the `name` frontmatter field, not filename. |
| 3 | Where do command/trigger files live? | `.claude/commands/` (plural, legacy but supported) and `.claude/skills/<name>/SKILL.md` (plural, recommended) | Both produce `/command` invocations. The README warning about plural vs singular applies: OpenCode uses `.opencode/command/` (singular), Claude Code uses `.claude/commands/` (plural). |
| 4 | What is the frontmatter schema? | YAML frontmatter with `---` markers | The `tools` field is a **comma-separated string** (e.g., `tools: Read, Grep, Glob`) or a YAML list — NOT a YAML object of booleans as OpenCode uses. Key subagent fields: `name` (required), `description` (required), `tools`, `disallowedTools`, `model`, `permissionMode`, `maxTurns`, `skills`, `mcpServers`, `hooks`, `memory`, `background`, `effort`, `isolation`, `color`, `initialPrompt`. |
| 5 | How is tool policy expressed? | Through multiple layers | (a) `tools` frontmatter as allowlist, (b) `disallowedTools` as denylist, (c) `permissions.allow/ask/deny` in `settings.json` using `Tool(specifier)` format with `*` wildcards, (d) `permissionMode` field in frontmatter. |
| 6 | Does it support sub-agent delegation? | **YES** — full support | Supports the `Agent` tool. Built-in agents (Explore, Plan, General). Custom agents in `.claude/agents/`. Nested spawning supported. Each subagent runs in its own context. The `Agent(agent_type)` syntax in `tools` restricts spawning. Equivalent to `mode: subagent`. |
| 7 | What command validates config and personas? | `claude doctor` (or `/doctor` in-session) | Validates config, checks for duplicate agent names, proposes fixes. `/status` confirms settings sources loaded. After adding agents, restart may be needed. |
| 8 | How are models selected per agent? | Via the `model` field in frontmatter | String alias (`sonnet`, `opus`, `haiku`, `fable`) or full model ID (`claude-opus-5`). Default is `inherit` (same as main conversation). Resolution order: env var `CLAUDE_CODE_SUBAGENT_MODEL` > per-invocation param > frontmatter > main model. |

## Adapter-Authoring Checklist Status

See `seed/adapters/_templates/README.md` for the full checklist.

### Step 1 — Profile the soil (DONE)
Recorded above.

### Step 2 — Build the templates (DONE)
- [x] `claude-agent.md` — literal frontmatter template with `<slots>`, trap comments for Claude Code format differences
- [x] `claude-settings.json` — permission/config template in Mode B shape
- [x] `claude-command.md` — trigger template with Odin-only guard line

### Step 3 — Generate the adapter (DONE)
- [x] Orchestrator persona (odin) with constitution digest + loop protocol + roster + footer rule
- [x] One charter per roster role (skuld, verdandi, var, muninn, brokkr, huginn, heimdall)
- [x] Commands: `/loop` trigger and `/thing` council trigger
- [x] Config file (`settings.json`) in Mode B shape

### Step 4 — Validate (NOT RUN)
- `claude doctor` not run — Claude Code CLI may not be installed on this machine
- Step to be completed in a validation loop

### Step 5 — Classify the tier (DONE)
Tier classification: **Tier 1** — per-agent tool allowlists are structurally enforced by the host. Verified: skuld/verdandi/kvasir have no write or exec capability. Permission deny list in settings.json blocks destructive git commands project-wide. `permissionMode: plan` on bifrost and kvasir.

**Residue:** The orchestrator boundary ("Odin never builds") is prose-only — not structurally enforced. All NOT-for clauses in descriptions are advisory text.

**Conformance profile:** 10 agents discovered and loadable. No generator drift between seed/adapters/claude/ and .claude/.

### Step 6 — Register (PARTIAL)
- Growth-ledger entry: Cross-host Claude Code adapter registered. Tier 1 soil. 10 charters.
- **No conformance transcript exists for this soil.** `evaluations/claude/cross-host-conformance-2026-07-27.md`
  was cited here and at the tier classification below; the path has never existed and no
  `evaluations/claude/` directory exists. Every conformance transcript in the repository is under
  `evaluations/opencode/deepseek-v4-flash/`. Task 2.8 is unticked accordingly `[E42]`.

## Model assignment on this soil — independence tier is unavailable

`seed/adapters/opencode/model-assignment.md` assigns var and heimdall a model from a **different
lab** than the roles whose work they review (`:45` — "Review is the one role that must come from a
different lab than the work it assesses"). **That property cannot be reproduced on Claude Code.**
This host serves Anthropic models only, so every seat — orchestrator, builder, validator, security —
is one lab by construction. Assigning a `model:` field here selects a capability tier; it cannot
select a lab.

**Consequence, which must be carried wherever a verdict is reported:** on this soil, var reviewing
brokkr's work, heimdall reviewing var's finding, and any council or deliberation seat reviewing
another are **structured self-checks, not independent review** `[review.md §4]`. One model in several
seats produces one opinion in several voices. A report that does not label them so has overstated
its own evidence.

- **Volume / capability tiering** *is* available via `model:` (`haiku`, `sonnet`, `opus`, `fable`)
  and is currently **unassigned** — all ten agents inherit the main conversation model. Whether to
  tier by cost on this soil is a gardener decision, staged rather than assumed.
- **Independence tiering** is **not available on this soil at any setting.** It is not a gap to be
  filled by a future assignment; it is a property of the host.
- The derivation rule at `model-assignment.md:51-68` still applies to rule 2 (capability) and
  rule 3 (volume). **Rule 1 (independence) has no satisfying assignment here** and must escalate to
  the gardener or to a second soil.

`[E50]`

---

## Format Traps Summary

| Trap | OpenCode (wrong for Claude) | Claude Code (correct) |
|------|----------------------------|----------------------|
| Tool shape | YAML object of booleans (`read: true`) | Comma-separated string (`Read, Grep`) |
| Agent directory | `.opencode/agents/` | `.claude/agents/` |
| Command directory | `.opencode/command/` (singular) | `.claude/commands/` (plural) |
| Config file | `opencode.json` (root) | `.claude/settings.json` |
| Agent identity | From filename | From `name` frontmatter field |
| Agent naming | Any case | Lowercase with hyphens recommended |
| Subagent mode | `mode: subagent` field | No `mode` field; uses `permissionMode` instead |
| Invalid permissionMode | Silent ignore | `defaultsOnly` is silently ignored; valid values: `default`, `acceptEdits`, `plan`, `bypassPermissions` |

### Tier classification (2026-07-27, transcript gap recorded 2026-07-28)
- **Soil tier:** Tier 1 — per-agent tool allowlists host-enforced
- **Residue:** orchestrator boundary (Odin never builds) is prose-only; all NOT-for clauses in descriptions are advisory
- **Conformance profile:** 10 charters present, 0 generator drift between `seed/adapters/claude/` and `.claude/`
- **Reviewer:** Claude Code (Opus 5) — **same lab as every seat reviewed; a structured self-check, not independent review** `[E50]`
- **Transcript:** **none.** The previously cited `evaluations/claude/cross-host-conformance-2026-07-27.md`
  does not exist and never did `[E42]`. The tier claim above rests on inspection, not on a recorded
  conformance run, and is unverified until 2.8 produces a transcript on this soil.

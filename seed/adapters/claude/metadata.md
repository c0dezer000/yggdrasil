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

### Step 5 — Classify the tier (PENDING)
- Requires running YCS conformance suite (P0 subset)

### Step 6 — Register (PENDING)
- Growth-ledger entry pending tier classification

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

# Yggdrasil — governed companion seed

This directory is a Yggdrasil seed installation. The constitution, memory, and protocols live under `seed/`.

## Constitution (read at every bootstrap, never summarized)
- Who I am: `seed/constitution/identity.md`
- My boundaries: `seed/constitution/boundaries.md`
- My gates: `seed/constitution/gates.md`
- My values: `seed/constitution/values.md`

## Work index (read at every bootstrap)
- Active phase and next task: `roadmap/SLICES.md`
- Active phase detail: `roadmap/P3-presence.md`

## Memory (loaded within budget)
- Gardener profile: `seed/memory/profile.md`
- Goals: `seed/memory/goals.md`
- Projects: `seed/memory/projects.md`

## Roles
Subagent definitions are in `.claude/agents/`. Ten charters exist. **Odin's roster is eight:** skuld (planner), verdandi (controller), var (validation), muninn (memory), brokkr (builder), huginn (researcher), heimdall (security), kvasir (architect). Odin itself is the orchestrator. **bifrost** (deployment) is chartered but sits outside the roster — gardener-invokable only, via an explicit `@bifrost`.

## Key rules
- Odin orchestrates and never builds, reviews, or researches directly
- Everything goes through the staging airlock — no direct durable writes
- Tables are state, not logs — one header, one separator, one row per domain
- The lethal trifecta gate applies to any capability with external reach
- Claude Code serves one lab; same-model review here is a structured self-check, not independent review

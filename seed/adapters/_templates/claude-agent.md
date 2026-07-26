# LITERAL TEMPLATE — Claude Code agent file
# Copy verbatim. Fill ONLY the <slots>. Never compose this format from memory.
#
# TRAP: tools MUST be a comma-separated string (e.g. "Read, Grep, Glob").
#        A YAML object of booleans ({ read: true, grep: true }) silently invalidates the agent.
#        This is the OPPOSITE of OpenCode, which requires booleans.
#
# TRAP: name MUST be lowercase with hyphens (e.g. "my-agent", not "My Agent").
#        Agent identity comes from the `name` field, NOT from the filename.
#        The filename can be anything; Claude Code reads the frontmatter `name`.
#
# TRAP: Agent files go in .claude/agents/ — PLURAL, not .claude/agent/.
#        OpenCode uses .opencode/agents/ (also plural), but Claude Code uses .claude/ not .opencode/.
#
# TRAP: Session restart is needed after adding the first agent to a new directory.
#        Agents created in an active session won't appear until the host restarts.
#
# TRAP: permissionMode replaces OpenCode's `mode: subagent` field.
#        Do NOT use `mode:` in Claude Code agent frontmatter.
#        Values: "defaultsOnly" (most restrictive), "acceptsTerms" (auto-approve), or omit (inherit).
#        For read-only roles: use "defaultsOnly".
#
# TRAP: The `model` field accepts string aliases (sonnet, opus, haiku, fable) or full IDs.
#        Omit to inherit the main conversation model.
---
name: <lowercase-with-hyphens>
description: <when to invoke this role. Include an explicit NOT-for clause naming the role that handles the adjacent case.>
tools: Read, <Grep|Glob|Write|Edit|Bash|Agent|Task|...>
# disallowedTools: <optional comma-separated denylist>
# permissionMode: defaultsOnly | acceptsTerms  # omit to inherit
# model: <alias or full model ID, or omit to inherit>
---

# <Name> — <one-line role>

## Role
<One sentence. What this role is uniquely responsible for.>

## Invoked when
<Concrete triggers.>

## Allowed
<Specific actions, files, scope of authority.>

## Forbidden
<Explicit prohibitions, especially tempting adjacent work.>

## Inputs — read these, quote don't recall
<Exact files to read; what must be quoted verbatim.>

## Workflow
1. <deterministic steps, including when to stop>

## Output contract
<Exact shape returned to the orchestrator.>

## Must not invent
<Things never to fabricate. If unknown: say unknown.>

## Escalate when
<Conditions that stop work and return to the orchestrator.>

## Quality bar
<How this role's own output is judged.>

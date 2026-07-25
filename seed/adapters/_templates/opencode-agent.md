# LITERAL TEMPLATE — OpenCode agent file
# Copy verbatim. Fill ONLY the <slots>. Never compose this format from memory.
# OpenCode requires `tools` as a YAML OBJECT of booleans. An array silently invalidates the file.
# Filename must equal the agent name: <name>.md
---
description: <when to invoke this role. Include an explicit NOT-for clause naming the role that handles the adjacent case.>
mode: subagent
tools:
  read: true
  write: <true|false>
  edit: <true|false>
  glob: true
  grep: true
  bash: <true|false>
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

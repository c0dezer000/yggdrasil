# LITERAL TEMPLATE — Skill (Agent Skills spec compliant)
# Conforms to the open Agent Skills specification so skills are portable across compliant
# hosts, and so ecosystem skills can be consumed after passing the capability gates.
#
# THREE-TIER PROGRESSIVE DISCLOSURE — the reason catalog size stops costing context:
#   Tier 1  frontmatter only (name + description) loads at startup   — keep it tiny
#   Tier 2  this file's body loads when the description matches      — keep it focused
#   Tier 3  reference/ and scripts/ load only during execution       — put bulk here
#
# ONE SKILL, ONE VERB. If sections of this body apply only to some triggers, split the skill.
---
name: <kebab-case, must equal the directory name>
description: <TIER 1 — the routing signal. When to invoke, in one sentence, PLUS an explicit
  NOT-for clause naming the skill that handles the adjacent case. This text is the only thing
  loaded at startup; if it is vague the skill never fires, and if it overlaps another skill
  both fire wrongly.>
---

# <Skill name>

## When this applies
<Concrete triggers. Mirror the description; do not contradict it.>

## When this does NOT apply
<The adjacent cases and which skill owns them. Overlap is a registration-time failure.>

## Procedure
1. <Deterministic steps. Prefer scripts for anything with an exact command —
   linting, formatting, test runs, deploys. Deterministic where possible,
   intelligent only where necessary.>

## Inputs — quote, do not recall
<Which files must be read and what must be quoted verbatim before acting.>

## Output contract
<Exact shape of what this skill produces.>

## Must not invent
<Things this skill may never fabricate. If unknown: say unknown.>

## Declared capabilities
<TIER 1 HONESTY REQUIREMENT. List every tool, file path, network destination, and permission
this skill actually uses. The gate verifies that the ACTUAL capability set fits inside this
DECLARED set. Under-declaration — doing something not disclosed here — is the dangerous
direction and is an automatic rejection. Over-declaration is benign but wastes privilege.>

## Reference files (Tier 3)
<Paths under reference/ or scripts/ loaded only during execution. Put bulk here, not above.>

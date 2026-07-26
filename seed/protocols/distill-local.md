# Distill-Local Protocol — Compressed Memory Profile for the Local Tier

> [SELF-GOVERNANCE] This protocol modifies how the bootstrap loads memory at session start
> (seed/protocols/session.md §2). It defines a compressed variant of the three durable memory
> sources that fits within the local model's 2K token budget. The protocol is invoked by
> `tools/ygg/ygg-distill.ps1`, which reads the source files and produces
> `seed/memory/distilled-local.md`.

## Selection Order

When loading memory for the local tier (≤2K tokens), items are selected from the three durable
sources in the following order of priority:

1. **Pinned always** — Any memory entry explicitly marked as pinned survives distillation
   unconditionally. No pinned entry is ever omitted for budget reasons.
2. **Project affinity** — Entries related to the currently active project (per
   `memory/projects.md`) are preferred over unrelated entries. This preserves task-continuity.
3. **Recency** — Among entries of equal affinity, newer ratified entries supersede older ones.
   The ratification date is used when available; file position within a section is a tiebreaker.
4. **Budget fill** — After applying rules 1–3, fill the remaining token budget with the most
   recent session digest from `memory/log/` and any pinned active-task context provided by the
   orchestrator.
5. **Naming what was omitted** — The distilled output always includes a note listing which
   entries or sections were omitted to stay within budget, so the recipient knows what exists
   but was not loaded.

## Distillation Rules — Per File

### profile.md — Target: ~400 tokens

**Include only:**
- Name (C0dezer0 / Zero)
- Location / timezone (Cavite, Philippines — governs applicable law, currency, timezone)
- Role (solo developer; no team)
- OS and shell (Windows, PowerShell)
- Model routing (strongest for orchestration/building; cheap/local for review/digests/opposition)
- Cost posture (both plans paid; local inference free; no new spend required)
- Standing instructions 1–8 as **single-line summaries** (no elaboration, no origin citations)
- Standing constraints as **single-line summaries**

**Omit:**
- Full environment table (Machines, Editor, Version control, Local inference, View layer)
- Access table details (OpenCode Go, Claude Pro, Ollama details)
- Communication preferences table
- Verbose descriptions, origin citations on standing instructions
- Epigraph / header quotes

### goals.md — Target: ~200 tokens

**Include only:**
- Goal number
- One-line goal (the Goal column only, truncated to a single line)
- Status (active / done / blocked / dormant)

**Omit:**
- "Why it matters" column entirely
- "Blocked by" column when empty (show only when non-empty)
- "Last movement" column
- Bootstrap rule note (it is structural, not data)

### projects.md — Target: ~300 tokens

**Include only:**
- Project name
- Location (path)
- State pointer (file reference)
- Status

**Omit:**
- Notes sections entirely
- "How this file changes" section entirely
- "Last touched" column
- Self-reference rule note (it is structural, not data)

### Remaining Budget — ~1,100 tokens

After the three distilled sections above (total ~900 tokens), fill the remaining ~1,100 tokens with:
1. **Most recent session digest** from `seed/memory/log/` — the file with the latest date
   (YYYY-MM-DD.md format), included in full or truncated to fit.
2. **Pinned active-task context** — any explicitly pinned context item from the orchestrator.

If no session digest exists (empty log directory), state that explicitly and note the available
headroom.

## Conflict Rule

A proposed fact contradicting an existing durable fact is **never silently overwritten**.
Surface both at ratification time with one of three dispositions:
- **supersede** — the new fact replaces the old; the old record acquires a pointer to the
  replacement.
- **keep both (scoped)** — both facts coexist with explicit scope boundaries documented.
- **reject** — the proposed fact is declined; the existing durable fact stands.

This rule is quoted from seed/protocols/session.md §CONFLICT and applies identically at the
local tier. Distillation compresses but never silently resolves a contradiction — if a
contradiction is detected during distillation, the output must flag it rather than pick a side.

## Budget Accounting

| Source | Raw (estimate) | Distilled target | Omitted |
|---|---|---|---|
| profile.md | ~900 tokens | ~400 tokens | Environment table, Access details, Communication prefs, verbose descriptions |
| goals.md | ~350 tokens | ~200 tokens | "Why it matters", "Blocked by" (when empty), "Last movement" |
| projects.md | ~500 tokens | ~300 tokens | Notes sections, "How this file changes", self-reference rule |
| Subtotal | ~1,750 tokens | ~900 tokens | |
| Session digest + pinned context | — | ~1,100 tokens | |
| **Total** | | **≤2,000 tokens** | |

## Invocation

Run `& "tools/ygg/ygg-distill.ps1"` to regenerate `seed/memory/distilled-local.md`. The script
reads the three source files from `seed/memory/`, applies these distillation rules, writes the
compressed output, and verifies the total fits within 2K tokens.

The distilled file is read at bootstrap (per session.md §2) when the active model tier is
"local" (≤2K token budget). The frontier tier (≤4K) uses the full uncompressed memory sources.

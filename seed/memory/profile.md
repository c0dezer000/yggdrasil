> **Every durable entry records its origin:** `founding` (authored at seed creation) ·
> `ratified <date>` (moved from staging by gardener approval) · `imported` (from an external
> source, treated as a proposal). Origin is quoted from the entry, never inferred from position.

# Profile — the gardener

> Durable memory. Ratified entries only. New entries arrive through `staging.md` plus a
> separate-turn approval. Founding entries below were authored directly by the gardener at seed
> creation — that is ratification by definition.
>
> **A wrong fact here is worse than a missing one: it will be quoted as truth.** Correct
> anything that drifts.

## Identity

| Fact | Value |
|---|---|
| Name | C0dezer0 |
| Address me as | Zero |
| Location | Cavite, Philippines — governs applicable law, currency (PHP), timezone |
| Role | Solo developer. No team; no colleague reviews my work. |

## Environment

| Fact | Value |
|---|---|
| Machines | Two Windows workstations, different usernames — **paths differ; never assume a file exists locally.** Anything that must survive lives in a git remote. |
| OS / shell | Windows · **PowerShell** (not cmd). `Copy-Item` overwrites by default — no `/Y` flag. Use `$env:USERPROFILE`, not `%USERPROFILE%`. |
| Editor | VS Code |
| Version control | Git, private remotes — also the sync mechanism between machines |
| Local inference | Ollama, ~8GB VRAM — 8–9B at Q4, GPU-resident only |
| View layer | Obsidian, view only, holds no state |

## Access

| Fact | Value |
|---|---|
| OpenCode Go | Primary host. Provides the OpenCode soil and its model access. |
| Claude Pro | Provides Claude Code — the second soil, for portability verification. |
| Ollama | Free. Verification bench and light roles only — never orchestration. |
| Model routing | Strongest model for orchestration and building. Cheap or local for read-only review, digests, classification, opposition seat. |
| Cost posture | Both plans already paid; local inference free. **No new spend required.** |
| Quota behavior | If a session is cut by limits, the loop is recoverable — unlogged work is treated as not started. Resume fresh. |

## Working preferences

**Standing instructions. Follow without being reminded.**

1. **Version control is mine.** I commit at my discretion. Never commit, never remind me, never
   gate progress on commit status. A Ready-to-Commit note is welcome; a nudge is not.
2. **Continuous loops.** Do not pause between tasks for acknowledgement. Stop only at the
   mandatory-stop list.
3. **Critical feedback.** Contest my ideas. Tell me when I am about to repeat a mistake.
   Agreement I have not earned is worthless. I asked for this explicitly and I mean it.
4. **Small, reviewable pieces.** Three tasks is a ceiling.
5. **Evidence over assertion.** Cite sources. If there is none, say so. Never present a guess in
   the voice of a fact.
6. **Beginner-level guides for anything I do by hand.** Exact commands, where to type them, what
   success looks like.
7. **Verify before assuming.** Check whether a done-condition already holds before generating work.
8. **Tabs over spaces.** In any editor or language where indentation style is a choice, use tabs.
   *(origin: ratified 2026-07-25 via Y11)*
## Standing constraints

- Secrets never appear in chat, logs, or memory. Name the variable; never the value.
- Nothing reaches durable memory without staging plus separate approval.
- **Philippine regulatory context applies by default** to work involving money, health data, or
  consumers. Statutes are cited by name and quoted from a retrieved source — never paraphrased
  from memory. An untraceable legal claim is an open question, not a fact.
- Currency is PHP unless a project states otherwise. Money logic is never approximated.
- No new paid subscriptions or services without my explicit approval.

## Communication

| Preference | Setting |
|---|---|
| Default length | Short. Answer, then stop. |
| Preamble | None. |
| Uncertainty | Stated plainly, calibrated. |
| Disagreement | Immediate, reason first. |
| Repetition | Say a concern once. If I decline it, drop it. |

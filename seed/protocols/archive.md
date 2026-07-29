# Archive Protocol — Memory Log Lifecycle

> Status: **proposed** — drafted by Kvasir 2026-07-29.
> Depends on: `seed/protocols/session.md` (bootstrap loading), `seed/protocols/distill-local.md`
> (distillation integration), `seed/constitution/boundaries.md` (archive is logs-only, no
> ratification needed — within "May do alone" read/write scope).
> Invoked by: periodic schedule, `ygg archive` command, or as a step in distill-local workflow.

## Problem

Log entries accumulate without bound. Session digests describe past work. Heartbeat files
duplicate state across multiple briefings per day with low signal-to-noise ratio after 14 days.
Without an archive rule, the context budget at bootstrap is consumed by history rather than by
current work.

## Scope

This protocol governs **log files only** — the contents of `seed/memory/log/`:

| Pattern | Type | Lifecycle |
|---------|------|-----------|
| `YYYY-MM-DD.md` | Session digest | 30-day hot → 90-day warm → monthly digest |
| `heartbeat-YYYY-MM-DD.md` | Heartbeat briefing | 14-day hot → weekly digest |

This protocol does **not** govern durable memory files (`profile.md`, `goals.md`, `projects.md`,
`capabilities.md`, `decisions.md`, `provenance.md`) — those have their own lifecycle through
staging and ratification. Archive is logs-only, no ratification needed.

---

## 1. Archive Schedule

### 1.1 Session digests — 30-day window

A session digest `memory/log/YYYY-MM-DD.md` is considered **hot** (included in bootstrap loading)
for 30 calendar days after its date stamp. After 30 days:

- The file **remains on disk** at its original path for audit and deep retrieval.
- It is **excluded from bootstrap loading** (see §4 — Bootstrap update).
- It is eligible for consolidation into a monthly digest (see §1.2).

The cutover is date-based, not filesystem-timestamp-based. A log dated 2026-07-01 becomes cold on
2026-07-31 (30 calendar days inclusive). The bootstrap filter uses the date in the filename.

### 1.2 Session digests — 90-day consolidation

A session digest older than 90 calendar days is consolidated into a **monthly digest file**:

- **Hot:** 0–30 days — loaded at bootstrap, full file available.
- **Warm:** 31–90 days — excluded from bootstrap, available for explicit retrieval.
- **Cold:** 91+ days — consolidated into monthly digest; raw file may be moved to
  `seed/memory/log/archive/` (see §3).

The monthly digest is a single markdown file per month:
`seed/memory/log/archive/YYYY-MM-digest.md`

Each monthly digest contains:
- A header with the month, file count, and total line count.
- One entry per session digest, in date order.
- A one-paragraph summary of the session's work.
- Key decisions extracted (prefixed with `decision:`).
- Facts that appeared and their promotion status.

### 1.3 Heartbeat files — 14-day consolidation

Heartbeat files have a shorter hot window because they carry low-uniqueness content:

- **Hot:** 0–14 days — included in bootstrap loading.
- **Cold:** 15+ days — consolidated into a **weekly digest** and moved to archive.

The weekly heartbeat digest: `seed/memory/log/archive/heartbeat-YYYY-W##-digest.md`

Each weekly digest contains:
- The latest state from the last heartbeat of the week.
- A note of state changes detected across the week.
- Individual heartbeat files older than 14 days are moved to the archive subdirectory.

---

## 2. Promotion Trigger

Any fact, decision, or pattern appearing in **3 or more distinct log entries** without having been
promoted to durable memory is flagged by Kvasir at the next memory review for consolidation.

### 2.1 Trigger rule

```
count(log entries containing fact F) >= 3
AND F not present in durable memory
AND F not already staged for promotion
-> Kvasir proposes: [consolidation] promote <F> from log to <target> (seen N times)
```

### 2.2 Scope of scanning

Kvasir scans eligible log entries during a memory review:
- All hot session digests (<=30 days) in full.
- Cold session digests (>30 days) via their monthly digest summaries only.
- Heartbeat files for staging state and blocked tasks only.

### 2.3 Consolidation proposal format

```
[consolidation] promote <F> from log to <target> (seen N times -- YYYY-MM-DD, YYYY-MM-DD, YYYY-MM-DD)
```

### 2.4 Exception — ephemeral facts

Facts that are inherently temporary (e.g., "staging has 14 pending proposals on 2026-07-28") are
never promoted, regardless of frequency.

---

## 3. Archive Location

### 3.1 Directory structure

```
seed/memory/log/
  YYYY-MM-DD.md                    # Hot/warm session digests (<=90 days)
  heartbeat-YYYY-MM-DD.md          # Hot heartbeat files (<=14 days)
  archive/
    index.md                       # Master index of all archived content
    YYYY-MM-digest.md              # Monthly session digest (91+ days)
    heartbeat-YYYY-W##-digest.md   # Weekly heartbeat digest (15+ days)
    YYYY-MM/                       # Cold raw logs (moved here at 91 days, optional)
```

### 3.2 Archive index format

`seed/memory/log/archive/index.md` is append-only. Each entry records an archive operation.

### 3.3 Cold storage of raw logs (optional)

At 91 days, raw session digest files **may** be moved to the monthly subdirectory. No file is
ever deleted — only moved. The move is a `git mv`, preserving file history.

---

## 4. Bootstrap Update

`seed/protocols/session.md` step 2 is amended to add:

> **Log loading is filtered by date — only entries from the last 30 days are eligible for
> bootstrap inclusion.** Log files with a date stamp older than 30 calendar days before the
> current session date are excluded from automatic loading. They remain on disk for explicit
> retrieval. The filter is filename-based: `YYYY-MM-DD.md` and `heartbeat-YYYY-MM-DD.md`
> patterns are checked against the 30-day threshold.

Step 2a is added:

> 2a. **Resolution check.** Before reading a log entry, confirm its date is within the 30-day
> hot window. Archived entries are never loaded automatically — read on explicit demand only.

---

## 5. Invocation

### 5.1 As part of distill-local workflow

When distillation runs, it first checks archive eligibility:
1. Check for files older than 30 days — mark as cold (bootstrap exclusion).
2. Check for files older than 90 days — consolidate into monthly digest if not yet done.
3. Check for heartbeat files older than 14 days — consolidate into weekly digest.

### 5.2 As a standalone command

```
ygg archive            -- run full archive cycle
ygg archive status     -- show what would be archived without doing it
ygg archive digest     -- consolidation pass only
```

### 5.3 Schedule

| Trigger | Action | Responsibility |
|---------|--------|----------------|
| Weekly memory review (Kvasir) | Check promotion triggers | Kvasir |
| ygg-distill run | Check archive eligibility | Distill script |
| Manual `ygg archive` | Full archive cycle | Gardener or orchestrated |

The archive protocol does **not** run autonomously on a timer — it is triggered by existing
workflows (distillation, memory review, manual command).

---

## 6. Boundaries Compliance

### 6.1 Archive is logs-only

Archiving operates exclusively on `seed/memory/log/`. It does not touch durable memory files.

### 6.2 No ratification required

Writing to `memory/log/` is a may-do-alone action. Archiving generates new files (digests, index)
and moves existing log files within the log directory tree. Neither action requires staging or
gardener ratification.

**Exception:** A promotion trigger that results in a durable-memory proposal **does** require
staging and ratification.

### 6.3 No files deleted

No files are deleted — only moved. The `ygg archive` command never uses `Remove-Item` or `rm`.

### 6.4 No background writes

The archive operation is never triggered by a background, scheduled, or heartbeat context. All
archive actions run within a session context or on explicit manual invocation.

---

## 7. Change Log

| Date | Change | Author |
|------|--------|--------|
| 2026-07-29 | Initial draft | Kvasir |

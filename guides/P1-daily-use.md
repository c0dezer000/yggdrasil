# P1 — Two Weeks of Real Use (Task 1.12)

A beginner-level step-by-step guide for the gardener (Zero / C0dezer0).

---

## What this task requires

**Task 1.12** is the core deliverable of the P1 (Memory in Daily Use) unit. It proves the memory
system works not just in tests but in **real, sustained use** — you and Odin working together
for 14 calendar days.

The done-condition has three parts, **all must be true:**

| # | Condition | How it's met |
|---|---|---|
| 1 | Fourteen daily digests exist in `seed/memory/log/` | A digest file written every day you work. Days can be non-consecutive, but you need 14 files. |
| 2 | At least five facts ratified into durable memory through actual work | Real facts you approve via the staging airlock — not test data. Preferences, project details, conventions, decisions. |
| 3 | Ratification burden measured at under 60 seconds per day | The time you spend reading and approving staged entries is tracked and stays under 1 minute per day on average across the 14 days. |

**What counts as a "day":** Any calendar day where you open the project and run at least one
loop. You can do multiple sessions in a day — that still counts as one digest for that date.
Days do not need to be consecutive; you could do 14 days spread over 3 weeks.

**What "real use" means:** You are actually using Odin for real work — asking questions,
having it research, having it write code, having it review files. The digests and facts
accumulate naturally from this work, not from artificial test scenarios.

---

## Prerequisites

Before your first daily-use session, confirm these are true:

| # | Check | How to verify |
|---|---|---|
| 1 | You are in `C:\projects\yggdrasil` | Run `cd C:\projects\yggdrasil` then `Get-Location` — should show `C:\projects\yggdrasil` |
| 2 | Task 1.11 is complete (web-search connector approved) | Look at `roadmap/P1-memory.md` line 73 — checkbox should be `[x]` |
| 3 | The 14-day log directory exists | Run `mkdir seed\memory\log -Force` (safe even if it exists) |
| 4 | Staging file exists and is ready | Run `Get-ChildItem seed\memory\staging.md` — file must exist |
| 5 | You have real work you want to accomplish | A question to research, a project to start, code to write, a concept to explore. **This is the most important prerequisite.** Without real work, there are no facts to ratify. |

---

## Day-by-day workflow

Each day follows the same rhythm. Steps 1–4 are your daily session. Step 5 is your daily
close-out. Steps 6–7 happen only when you want to check progress or at the very end.

---

### Step 1 — Open a PowerShell terminal and launch Odin

```powershell
cd C:\projects\yggdrasil
opencode
```

**Verify:**

1. The interface opens. Look for the **agent picker** (usually a dropdown or button in the
   top-left or top-right area).
2. Select **odin** from the list.
3. **Verify the agent indicator reads `Odin`** — not Build, not Plan, not Explore.

> **⚠️ If the indicator does not say Odin, STOP.** Running under the wrong agent means
> the constitution and memory system are not loaded. Select Odin before proceeding.

---

### Step 2 — Run a work loop

Send exactly this into the chat:

```
/loop
```

**What happens:**

- Odin (orchestrator) reads the work index and identifies the active unit (P1).
- Odin invokes Skuld (planner) to identify the next unfinished task.
- Since 1.12 is `[HUMAN]`, Odin checks whether its done-condition already holds.
  - **First 13 days:** The done-condition does not hold (not enough digests yet).
    Odin follows the loop protocol: invokes Var to write this guide, then **STOPS**
    and presents you the guide location.
  - **Day 14+:** If the done-condition holds, Odin marks the task complete.

**Expected output (first day — guide not yet written):**

```
[Skuld] Next task: 1.12 — Two weeks of real use
[HUMAN] CHECK — done-condition not yet met.
[Var] Guide written to guides/P1-daily-use.md.
Loop STOP — human task requires human action.
```

**Expected output (after guide exists):**

```
[Skuld] Next task: 1.12 — Two weeks of real use
[HUMAN] CHECK — done-condition: 14 daily digests, 5 ratified facts, burden <60s/day.
[HUMAN] CHECK — <X> digests found, <Y> facts ratified, burden <measured>.
[HUMAN] CHECK — not yet met. Guide exists at guides/P1-daily-use.md.
Loop STOP — human task requires human action.
```

---

### Step 3 — Do your real work for the day

This is the most important step. Task 1.12 is about **using** the companion, not building it.

**What to do:** Ask Odin to help you with something real. Examples:

- **Research a topic:** _"Use huginn to research the current best practices for Rust error
  handling and give me a brief."_
- **Work on a personal project:** _"I want to start a small CLI tool in Python that
  renames files based on their creation date. Help me plan the architecture."_
- **Ask questions:** _"What's the difference between `git merge` and `git rebase`? When
  should I use each?"_
- **Review or analyze something:** _"Look at this error log I pasted and tell me what's
  going wrong."_
- **Generate ideas:** _"Help me brainstorm a naming convention for my React components."_

> **💡 Tip for Zero:** The more real the work, the more likely the session produces
> facts worth ratifying. A fact like _"Zero prefers tabs over spaces"_ or _"Zero's
> timezone is PST (UTC+8)"_ or _"Project X uses Express.js"_ — these only arise when
> the conversation touches real preferences and real projects.

**How to interact during work:**

- Talk to Odin naturally. Ask follow-up questions.
- If Odin suggests something and you agree, say so: _"Yes, that's right."_
- If Odin gets something wrong, correct it: _"Actually, I prefer snake_case not camelCase."_
- If you make a decision, state it: _"Let's go with option B."_

These conversations are the raw material for staged facts and daily digests.

---

### Step 4 — End the session by wrapping

When you are done working for the day, send exactly:

```
Wrap the session.
```

**What happens (per the session protocol — `seed/protocols/session.md`):**

1. Odin writes a **daily digest** to `seed/memory/log/YYYY-MM-DD.md` (e.g., `seed/memory/log/2026-07-26.md`).
   This digest records: what was worked on, what changed, decisions taken, blockers, what
   the next session should pick up.

2. Odin proposes **durable facts** into `seed/memory/staging.md` — facts it learned about
   you, your preferences, your projects. Each proposal carries:
   - **Type:** `fact`, `capability`, or `consolidation`
   - **Content:** what the fact is
   - **Source:** which log entry or event produced it

3. Odin presents a **ratification batch** — a short list of everything staged, with a
   compact prompt like:

   ```
   Ratification batch:
   - [fact] Zero prefers tabs over spaces (source: log/2026-07-26 §work)
   - [fact] Project CLI-tool uses Python 3.12 (source: log/2026-07-26 §work)
   
   Reply with: ratify all · ratify <number> · reject <number>
   ```

4. **You decide** what to approve. Respond with one of:
   - `ratify all` — approve everything in the batch
   - `ratify 1` — approve only item 1
   - `ratify 1, 3` — approve items 1 and 3
   - `reject 2` — reject item 2 (removes it from staging)
   - `reject all` — reject everything

5. After you respond, Odin executes the ratification:
   - Approved items are moved from `staging.md` into the correct durable file
     (`profile.md`, `goals.md`, `projects.md`, `decisions.md`, `capabilities.md`).
   - Clears approved items from `staging.md`.
   - Appends a **behavioral provenance** entry to `seed/memory/provenance.md`.
   - Prints the **disclosure footer**.

**Expected output (partial — wording varies):**

```
[Session] Writing digest to seed/memory/log/2026-07-26.md...
[Session] Proposing 2 facts to staging...

Ratification batch:
- [fact] Zero prefers tabs over spaces (source: log/2026-07-26 §work)
- [fact] Project CLI-tool uses Python 3.12 (source: log/2026-07-26 §work)

Reply with: ratify all · ratify <number> · reject <number>

> ratify all

[Session] Ratifying: Zero prefers tabs over spaces → seed/memory/profile.md
[Session] Ratifying: Project CLI-tool uses Python 3.12 → seed/memory/projects.md
[Session] Proposing to provenance.md...
[Session] Staging cleared.
---

[ roles invoked: muninn (memory keeper) ]
[ staged: 0 · ratified: 2 · rejected: 0 ]
[ model: deepseek-v4-flash · mode: balanced ]
```

---

### Step 5 — Verify the daily digest was written

After the wrap completes, open a **separate** PowerShell terminal (the `opencode` session is
still running — that's fine). Run:

```powershell
cd C:\projects\yggdrasil
Get-ChildItem seed\memory\log\
```

**Expected output:** You should see a file for today's date:

```
    Directory: C:\projects\yggdrasil\seed\memory\log

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----         7/26/2026   5:30 PM           1234 2026-07-26.md
```

If you are on day 7, you should see 7 files. On day 14, 14 files.

To check the content of today's digest:

```powershell
Get-Content seed\memory\log\2026-07-26.md
```

(Replace `2026-07-26` with today's actual date.)

**Expected output:** The digest content — a structured log of what was worked on, what
changed, decisions taken, blockers, and what the next session should pick up.

**If the file does not exist:** The wrap did not complete. Re-open Odin, make sure the
session ended properly, and try wrapping again. A digest is only written when you send
`Wrap the session.` and the ratification batch completes.

---

### Step 6 — Track the ratification burden (time measurement)

The done-condition requires that the **ratification burden** — the time you spend reading
and approving staged entries — is under 60 seconds per day on average.

**What counts as burden:** Only the time you spend actively reviewing the ratification
batch and deciding what to approve. This does **not** include:
- Time spent doing real work (Step 3).
- Time spent reading the daily digest.
- Time Odin spends writing files or processing.

**How to measure it:**

#### Method A — Simple timer (recommended)

1. Before you send `Wrap the session.`, note the time (or start a stopwatch).
2. Read the ratification batch, decide, type your response (`ratify all`, `ratify 1`, etc.).
3. Note the time after you send the response.
4. The difference is your ratification burden for that day.

Track it in a simple text file:

```powershell
# Create a tracking file (run this once at the start)
@"
Date,Ratification Time (seconds),Facts Ratified
"@ | Out-File -FilePath seed\memory\ratification-burden.csv -Encoding utf8
```

After each session, append a row:

```powershell
# Run this after each wrap — replace the values with your actual numbers
"2026-07-26,45,2" | Out-File -FilePath seed\memory\ratification-burden.csv -Encoding utf8 -Append
```

(Change the date, seconds, and facts count to match your session.)

#### Method B — Clock check

Simpler but less precise: glance at the clock before and after the ratification step.
If the whole interaction (reading the batch + deciding + typing) takes less than 60
seconds, you are under the limit.

**How to tell if you are on track:**

After several days, check the average:

```powershell
# After you have at least 3-4 entries
Import-Csv seed\memory\ratification-burden.csv | Measure-Object -Property "Ratification Time (seconds)" -Average
```

Expected output:
```
Count    Average
-----    -------
   7     38.2
```

If the average is above 60, look for ways to speed up:
- Read the batch quickly — most entries are short facts you already discussed during work.
- Use `ratify all` when everything looks correct.
- Only scrutinise entries that seem wrong or surprising.

> **💡 Tip:** If a session produces 0 staged facts (nothing worth ratifying), the burden
> is effectively 0 seconds for that day — you spent no time ratifying. That is fine and
> helps the average.

---

### Step 7 — Verify the done-condition (checking progress)

You can check your progress at any time, not just at the end. Run these checks in a
PowerShell terminal (not inside Odin):

#### Check 1 — Digest count

```powershell
cd C:\projects\yggdrasil
(Get-ChildItem seed\memory\log\*.md).Count
```

**Expected:** A number. It should increase by 1 every time you complete a session with a wrap.

- **Target:** 14 or more.
- **If below target:** Keep using Odin daily. You need one digest per day you work.

#### Check 2 — Ratified facts count

```powershell
cd C:\projects\yggdrasil
$facts = @()
# Check profile.md for ratified facts (entries with "ratified" origin)
$facts += Select-String -Path seed\memory\profile.md -Pattern "ratified"
# Check projects.md for ratified entries
if (Test-Path seed\memory\projects.md) { $facts += Select-String -Path seed\memory\projects.md -Pattern "ratified" }
# Check decisions.md for ratified entries
$facts += Select-String -Path seed\memory\decisions.md -Pattern "ratified"
# Count total
$facts.Count
```

**Expected:** A number representing how many distinct facts have been ratified into
durable memory.

- **Target:** 5 or more.
- **If below target:** Focus your work sessions on topics that produce ratifiable facts
  — preferences, decisions, project conventions, rules.

A simpler visual check:

```powershell
Get-ChildItem seed\memory\staging.md | Select-String -Pattern "^- \[fact\]"
```

This shows what is currently staged (awaiting your approval). A lean staging file means
you have been ratifying regularly.

#### Check 3 — Ratification burden average

```powershell
cd C:\projects\yggdrasil
if (Test-Path seed\memory\ratification-burden.csv) {
    Import-Csv seed\memory\ratification-burden.csv | Measure-Object -Property "Ratification Time (seconds)" -Average
} else {
    Write-Host "No tracking file found. Start measuring (see Step 6)."
}
```

**Expected:** Average under 60.

- **Target:** Under 60 seconds per day on average.
- **If above target:** Approve batches faster. Use `ratify all` when you trust the
  content. The burden should shrink as you get familiar with the rhythm.

---

## Full done-condition verification (end of 14 days)

After you have completed 14 sessions (not necessarily consecutive), run this sequence
to confirm all three conditions are met:

```powershell
cd C:\projects\yggdrasil

Write-Host "=== CHECK 1: Daily digests ==="
$digestCount = (Get-ChildItem seed\memory\log\*.md).Count
Write-Host "Digests found: $digestCount (target: 14+)"
Get-ChildItem seed\memory\log\*.md | Select-Object Name

Write-Host "`n=== CHECK 2: Ratified facts ==="
$facts = @()
$facts += Select-String -Path seed\memory\profile.md -Pattern "ratified"
if (Test-Path seed\memory\projects.md) { $facts += Select-String -Path seed\memory\projects.md -Pattern "ratified" }
$facts += Select-String -Path seed\memory\decisions.md -Pattern "ratified"
Write-Host "Ratified facts found: $($facts.Count) (target: 5+)"
$facts | ForEach-Object { Write-Host "  - $($_.Line.Trim())" }

Write-Host "`n=== CHECK 3: Ratification burden ==="
if (Test-Path seed\memory\ratification-burden.csv) {
    $avg = Import-Csv seed\memory\ratification-burden.csv | Measure-Object -Property "Ratification Time (seconds)" -Average
    Write-Host "Average burden: $([math]::Round($avg.Average, 1)) seconds/day (target: under 60)"
    Write-Host "(Based on $($avg.Count) measurements)"
} else {
    Write-Host "No tracking file. Measure manually (see Step 6)."
}

Write-Host "`n=== OVERALL VERDICT ==="
if ($digestCount -ge 14 -and $facts.Count -ge 5) {
    $burdenOk = $true
    if (Test-Path seed\memory\ratification-burden.csv) {
        $avg = Import-Csv seed\memory\ratification-burden.csv | Measure-Object -Property "Ratification Time (seconds)" -Average
        if ($avg.Average -ge 60) { $burdenOk = $false }
    }
    if ($burdenOk) {
        Write-Host "ALL CONDITIONS MET. Task 1.12 is complete!" -ForegroundColor Green
    } else {
        Write-Host "Burden condition not yet met. Keep tracking." -ForegroundColor Yellow
    }
} else {
    Write-Host "Not yet complete. Keep going!" -ForegroundColor Yellow
    Write-Host "  Digests: $digestCount/14"
    Write-Host "  Facts: $($facts.Count)/5"
}
```

**Expected output when all conditions are met:**

```
=== CHECK 1: Daily digests ===
Digests found: 14 (target: 14+)

    Directory: C:\projects\yggdrasil\seed\memory\log

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----         7/26/2026   5:30 PM           1234 2026-07-26.md
-a----         7/27/2026   4:15 PM            987 2026-07-27.md
...
-a----         8/10/2026   6:00 PM           1456 2026-08-10.md

=== CHECK 2: Ratified facts ===
Ratified facts found: 7 (target: 5+)
  - (origin: ratified 2026-07-26 via wrap)
  - (origin: ratified 2026-07-28 via wrap)
  ...

=== CHECK 3: Ratification burden ===
Average burden: 32.5 seconds/day (target: under 60)
(Based on 14 measurements)

=== OVERALL VERDICT ===
ALL CONDITIONS MET. Task 1.12 is complete!
```

---

## Expected rhythm — what a typical day looks like

| Time | Action | What happens |
|---|---|---|
| **Start** | `cd C:\projects\yggdrasil` then `opencode` | Host launches. Select Odin. |
| **Moment 1** | Send `/loop` | Odin reads the index, identifies task 1.12, confirms it isn't done yet, presents the guide. The loop stops — it's a `[HUMAN]` task. |
| **Work block** | Ask Odin for help with real work | Research, code, planning, questions. This is where facts are generated. |
| **End of work** | Send `Wrap the session.` | Odin writes the digest, proposes facts, presents the ratification batch. |
| **Ratification** | Read the batch, respond `ratify all` or pick individually | Takes ~30 seconds. Facts move to durable memory. |
| **Verification** | In a separate terminal: `Get-ChildItem seed\memory\log\` | Confirm the digest file exists for today. |
| **Tracking** | Append a row to `ratification-burden.csv` | Log the time spent and facts ratified (optional but recommended). |

**Total time commitment per day:** The work block is whatever you want it to be (5 minutes
or 2 hours). The wrap + ratification + verification adds about 2–3 minutes.

---

## Common mistakes and how to avoid them

| Mistake | Consequence | Fix |
|---|---|---|
| Working but never wrapping | No digest is written that day | Always send `Wrap the session.` at the end |
| Wrapping but not ratifying | Facts stay in staging — never reach durable memory; digest is still written but facts don't count toward the 5-fact condition | Respond to the ratification batch with `ratify all` or pick items |
| Ratifying everything without reading | A wrong fact could enter durable memory, where it will be quoted as truth | Read the batch quickly but honestly. If something looks wrong, reject it |
| Forgetting to check the digest was written | You may assume it was created but it wasn't | Run `Get-ChildItem seed\memory\log\` after every wrap |
| Not measuring the ratification burden | No data for the done-condition at the end | Start a simple CSV or note the time before/after ratification each day |
| Doing only artificial test work | Facts are contrived, not real — the task says "through actual work" | Use Odin for real things you care about |
| Thinking days must be consecutive | The task says "fourteen daily digests" — they can be spread out | One digest per calendar day you work. Non-consecutive is fine |
| Forgetting which agent you are in | Running under the wrong agent means no memory system | Always check the agent indicator says `Odin` |

---

## Quick reference

| Item | Value |
|---|---|
| **Project root** | `C:\projects\yggdrasil` |
| **Agent to select** | Odin |
| **Launch command** | `cd C:\projects\yggdrasil && opencode` |
| **Start-work command** | `/loop` |
| **End-work command** | `Wrap the session.` |
| **Ratification command** | `ratify all` or `ratify <number>` or `reject <number>` |
| **Digest location** | `seed/memory/log/YYYY-MM-DD.md` |
| **Staging location** | `seed/memory/staging.md` |
| **Durable memory files** | `seed/memory/profile.md`, `goals.md`, `projects.md`, `decisions.md`, `capabilities.md` |
| **Provenance file** | `seed/memory/provenance.md` |
| **Burden tracker** | `seed/memory/ratification-burden.csv` (optional, recommended) |
| **Digest count check** | `(Get-ChildItem seed\memory\log\*.md).Count` |
| **Task target** | 14 digests, 5+ ratified facts, burden <60s/day average |
| **Task source** | `roadmap/P1-memory.md` §79-81 |

---

## After the 14 days — what to do when done

Once all three conditions are met:

1. Run the full verification script from **Step 7** to get the green **ALL CONDITIONS MET** output.
2. The next time you run `/loop` under Odin, the `[HUMAN]` check will detect that the
   done-condition holds and mark task 1.12 complete.
3. Proceed to **Task 1.13** — Onboard one existing project.

---

*Generated by Var for task 1.12 of P1-Memory. Based on roadmap/P1-memory.md §77-81,
seed/protocols/session.md, seed/memory/staging.md, and GUIDE.md.*

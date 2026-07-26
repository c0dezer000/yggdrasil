# Y03 — Cold Resume Test (Task 0.10)

A beginner-level step-by-step guide for the gardener.

---

## What this test proves

This test checks whether the companion (Odin) can **recover its full session state from files alone** after a complete host restart — no hints, no chat history, no memory except what is written in the project files.

A real-world deployment cannot assume a session lives forever. The host crashes, laptops reboot, connections drop. The question this test answers is:

> *If the process dies entirely and I reopen, does the companion know where we were without being told?*

**It also classifies the failure mode if it does not recover:**

- **Missing-task gap:** The companion cannot name any next task at all — it has no awareness of the active work unit. This means a structural fact (what unit is active, or what the next task is) exists only in session memory, not in any file.
- **Wrong-task gap:** The companion names a task, but it is not the correct one. It may skip forward, name a completed task, or invent something. This means the file records are ambiguous or contradictory.
- **Asks-for-context:** The companion replies with a question like *"What were we working on?"* or *"Can you remind me what the next step is?"* — it knows it needs state but cannot find it in files.

Both are **valuable findings** — they pinpoint exactly what fact needs to be written down in durable files. A failure here is the **most valuable result available** in this phase.

---

## Prerequisites

Before starting, confirm ALL of these are true:

| # | Check | How to verify |
|---|---|---|
| 1 | You are in `C:\projects\yggdrasil` | Run `cd C:\projects\yggdrasil` |
| 2 | The seed is installed and loads | Run `opencode agent list` — you should see 6 agents (`odin`, `skuld`, `verdandi`, `var`, `muninn`, `brokkr`) with zero errors |
| 3 | The evaluations directory exists for your model | Run `mkdir evaluations\opencode\deepseek-v4-flash -Force` (safe to run even if it exists) |
| 4 | **A pen/pencil and paper (or a text note)** — you will write down the next unfinished task before exiting. A phone note, sticky note, Notepad window, or any external medium works. | ⚠️ **This is the most common mistake.** Read the box below. |
| 5 | A clear understanding of the current session state | The roadmap shows tasks 0.1–0.9 are complete. The next task is **0.10 Y03** (this test). You will confirm this with Odin in Step 4. |

---

### ⚠️ CRITICAL PRECONDITION WARNING

**The test requires you to WRITE DOWN the exact next unfinished task BEFORE you exit.** This is the only way to know whether the companion got it right on resume.

Why this matters:
- You will be comparing the companion's answer after restart against **what you recorded externally**.
- If you did not write it down, you have no ground truth. The test is **VOID**.
- This cannot be guessed from memory — the whole point is that the companion must recover from files, not from your memory.

**The fix:** After completing the precondition loop (Step 4), write the exact next task verbatim on paper, in a Notepad window, or anywhere outside OpenCode. Example: *"Task 0.10 — Y03 cold resume"* or whatever Odin names.

---

## Step-by-step instructions

### Step 1 — Open a PowerShell terminal

Launch **PowerShell** (Windows) from the Start Menu or your preferred terminal application.

---

### Step 2 — Navigate to the project directory

```powershell
cd C:\projects\yggdrasil
```

**Verify:**

```powershell
Get-Location
```

Expected output:
```
C:\projects\yggdrasil
```

---

### Step 3 — Launch OpenCode and select Odin

```powershell
opencode
```

When the interface opens:

1. Look for the **agent picker / agent selector** (usually a dropdown or button in the top-left or top-right area).
2. Select **odin** from the list.
3. **Verify the agent indicator reads `Odin`** — not Build, not Plan, not Explore.

> **⚠️ If the indicator does not say Odin, STOP.** Running this test under the wrong agent is a **VOID** result (finding E15). The wrong agent has no constitution loaded and may not follow the loop protocol at all.

---

### Step 4 — Run the precondition loop

This step serves **two purposes**:
1. It satisfies the precondition **"one loop has completed"** — the session needs to have run at least one loop so there is a state to resume to.
2. It tells you exactly what the next task is, so you can write it down.

Send exactly this into the chat:

```
/loop
```

Let the companion run through its full loop:
- Odin invokes Skuld (planner) to identify the next task.
- If the next task is `[HUMAN]`, Odin checks whether its done-condition is met.
- Since this test (Y03) is the next task and its done-condition is not yet met, Odin should follow the protocol: invoke Var to write this guide, then **STOP** — presenting the guide location.

**Expected output (partial — exact wording may vary):**

```
[Skuld] Next task: 0.10 — Y03 cold resume
[HUMAN] CHECK — done-condition not met.
[Var] Guide written to guides/Y03-cold-resume.md.
Loop STOP — human task requires human action.
```

> **⚠️ If the loop produces no output, errors, or never reaches a clear next task — STOP.** The precondition cannot be established. Investigate the agent state and file integrity before proceeding.

Now read what Odin identified as the next task. It will appear in the response — look for the task name and number.

---

### Step 5 — WRITE DOWN the exact next task (CRITICAL)

**Take a pen and paper, or open a separate text note.** Write down **verbatim** what Odin named as the next task.

Example of what you write:
```
0.10 Y03 cold resume — done-condition: a transcript after a full host restart shows the correct next task identified from files alone.
```

> **Why paper or a separate note?** Anything inside OpenCode (a chat message, a file you just created) will be gone after you exit the host. The whole point is to have an independent record that survives the restart.

---

### Step 6 — EXIT THE HOST COMPLETELY

**This is the most important step of the entire test.**

You must exit the **entire host process** — not just close the chat tab, not just start a new conversation, not just minimize the window.

**How to exit completely:**
- **Close the terminal/command window** that is running `opencode`.
- **OR** press `Ctrl+C` in the terminal to kill the process, then close the window.
- **OR** use Task Manager to ensure no `opencode` process remains.

**Verify that the host is completely gone:**

```powershell
Get-Process opencode -ErrorAction SilentlyContinue
```

Expected output: *(nothing — no process found)*

If a process is listed, kill it:

```powershell
Stop-Process -Name opencode -Force
```

Then verify again until no process remains.

> **🔴 If you do not fully exit, the companion may still have session memory.** The test would be **VOID** — you would be testing hot resume, not cold resume. A new chat within the same host process keeps the model's conversation context alive.

---

### Step 7 — Reopen the host

Open a **fresh** PowerShell terminal (not the same one — it was closed in Step 6).

```powershell
cd C:\projects\yggdrasil
opencode
```

---

### Step 8 — Select Odin (again)

1. Use the agent picker to select **odin**.
2. **Verify the agent indicator reads `Odin`**.

> **⚠️ If the indicator does not say Odin, STOP.** Selecting the wrong agent produces a VOID result.

---

### Step 9 — Send only `/loop` — NO context, NO reminders

Type **exactly** this into the chat and send it:

```
/loop
```

**Do NOT add any preamble.** Do NOT say:
- ❌ *"Hey Odin, we were working on Y03, remember?"*
- ❌ *"As a reminder, the next task is 0.10..."*
- ❌ *"Let's continue where we left off."*
- ❌ *"Can you tell me what the next task is?"*

The ONLY input is `/loop`. The companion must recover everything from files.

---

### Step 10 — Observe and record the response

Watch what Odin does. Compare what it says against what you wrote down in Step 5.

#### ✅ PASS — Correct task identified from files alone

Odin (via Skuld) identifies the same next task you recorded externally. The output will look something like:

```
[Skuld] Next task: 0.10 — Y03 cold resume
[HUMAN] CHECK — done-condition: a transcript after a full host restart shows the correct next task identified from files alone.
[HUMAN] CHECK — not yet met. Invoking Var to write the guide.
[Var] Guide already exists at guides/Y03-cold-resume.md.
Loop STOP — human task requires human action.
```

**What this means:** The companion found the active unit, read the roadmap, identified the next unchecked task, and reconciled from files alone — all without a single hint from you.

Record: **PASS — correct next task from files alone**

#### ❌ FAIL — Wrong task identified

The companion names a different task than the one you wrote down. Examples:
- It names a completed task (e.g., *"Task 0.9 Y11 ratification"*).
- It skips ahead to a future task (e.g., *"Task 0.11 Local-model smoke test"*).
- It invents a task not in the roadmap.

Record: **FAIL — wrong task. Named: `<what it said>`. Expected: `<what you wrote>`.**

#### ❌ FAIL — No task identified / asks for context

The companion cannot identify a next task at all. Examples:
- *"What would you like to work on?"*
- *"Can you remind me where we left off?"*
- *"I don't see an active work unit."*
- *"Let's start by checking the project status."* (without naming a specific next task)

Record: **FAIL — no task identified. Companion asked for context or named nothing specific.**

#### ❌ FAIL — Re-does completed work

The companion attempts to re-execute a task that was already marked complete. For example, it tries to run Y01 or Y05 again as if they haven't been done.

Record: **FAIL — re-did completed work. Describe what it attempted to redo.**

---

### Step 11 — For a FAILURE: identify the missing fact

If the test failed, this is the **most valuable moment** of the entire P0 phase. A failure means a fact that the companion needed exists **nowhere in the project files**.

Ask yourself: **What fact was missing?**

Common categories:

| Symptom | Likely missing fact | Where it should live |
|---|---|---|
| Cannot name any task | Active work unit is not recorded in any file | `roadmap/` index or `seed/growth/ledger.md` |
| Names a completed task | Completed tasks are not marked as `[x]` in the roadmap | `roadmap/P0-foundation.md` |
| Names a future task | The checkpoint between tasks is not recorded | `seed/growth/ledger.md` or `seed/memory/session.md` |
| Asks "what were we doing?" | Session continuity record is missing | `seed/memory/session.md` |
| Cannot determine next task from roadmap | Roadmap format is not parseable by the companion | `roadmap/P0-foundation.md` |

**Write down which fact was missing** and include it in the transcript. This is a real gap in the memory design — not a model problem.

---

### Step 12 — Save the transcript

1. In OpenCode, locate the **transcript export** feature (usually a "Copy transcript", "Save conversation", or "Download" option in the chat menu).

2. **Copy or save the conversation from Step 9 only** — the `/loop` message through the companion's full response. (The precondition loop from Step 4 is a separate session and not part of this test.)

3. **Save the transcript** as a new file:

   ```
   C:\projects\yggdrasil\evaluations\opencode\deepseek-v4-flash\Y03-2026-07-25.md
   ```

   Create the file using PowerShell if needed:

   ```powershell
   mkdir evaluations\opencode\deepseek-v4-flash -Force
   ```

   Then paste the transcript content into the new file.

4. **At the top or bottom of the transcript**, add a verdict line recording what you observed:

   ```
   VERDICT: PASS — correct next task identified from files alone: "0.10 Y03 cold resume"
   ```

   or

   ```
   VERDICT: FAIL — wrong task. Named: "0.7 Y01 gated action". Expected: "0.10 Y03 cold resume".
   Missing fact: completed tasks not marked with [x] in roadmap/P0-foundation.md.
   ```

   or

   ```
   VERDICT: FAIL — no task identified. Companion asked "What would you like to work on?"
   Missing fact: no active unit record in any file.
   ```

5. **Also include your external note** — the task you wrote down in Step 5 — as part of the transcript evidence. Add it right after the verdict line:

   ```
   GROUND TRUTH (written before restart): 0.10 Y03 cold resume
   ```

6. **Verify the file was saved correctly:**

   ```powershell
   Get-ChildItem evaluations\opencode\deepseek-v4-flash\Y03-2026-07-25.md
   ```

   You should see the file listed with a non-zero size.

---

## Summary: Pass/Fail at a glance

| What happens | Verdict | Notes |
|---|---|---|
| Companion names the exact same task you wrote down | ✅ **PASS** | Files-only recovery works. Record the task name. |
| Companion names a different task (completed, future, or invented) | ❌ **FAIL** — Wrong task | Record what it said vs what you wrote. Identify the missing fact. |
| Companion asks for context or cannot name a task | ❌ **FAIL** — No task | Companion has no awareness of session state from files. |
| Companion re-does completed work | ❌ **FAIL** — Re-do | Completed tasks not marked as done in files. |
| You did not write down the next task before exiting | **VOID** | No ground truth to compare against. Re-run. |
| You did not fully exit the host process | **VOID** | Session memory may have survived. Re-run with a full exit. |
| Agent indicator does not say `Odin` | **VOID** (E15) | Wrong agent. Select Odin and re-run. |

---

## How to tell if the recovery was truly from files

This is important for classifying the result. The companion might seem to know the task but actually be guessing or repeating a pattern. Here is how to distinguish genuine file-based recovery from other behaviours:

| Evidence in the transcript | What it means |
|---|---|
| Skuld explicitly reads from `roadmap/` or `seed/` files (tool calls to `read` or `glob`) | Genuine file-based recovery — the companion consulted durable files |
| Companion names the task instantly without any tool calls | Suspicious — may be hallucinating or using session memory. Check if the task matches **exactly** what was written externally |
| Companion reads a file but misinterprets it (e.g., reads the wrong line) | File-based but logic error — still a FAIL, but the missing fact is specific (e.g., "roadmap checked but completed tasks not marked") |
| Companion says "based on the files, the next task is..." but names something not in any file | Hallucination — FAIL. Check whether the roadmap was actually read |
| No file reads at all, just a direct answer | Likely not file-based. Could be session memory if the exit was incomplete. Investigate. |

**Why it matters:** The whole point of this test is to prove that **files are sufficient** for recovery. If the companion gets the right answer but without reading any files, that is actually a weaker result — it may have gotten lucky, or it may still have residual context from an incomplete exit. A genuine PASS includes evidence of file reads (visible tool calls to `read` on roadmap or seed files).

---

## Common mistakes and how to avoid them

| Mistake | Consequence | Fix |
|---|---|---|
| Not writing down the next task before exiting | No ground truth — test is **VOID** | Write it on paper, phone note, or separate text file BEFORE closing the host |
| Exiting only the chat tab, not the whole process | Session memory survives — test is **VOID** | Close the terminal window or `Ctrl+C` the process. Verify with `Get-Process opencode` |
| Sending anything other than `/loop` in Step 9 | You are giving hints — test is **VOID** | Send ONLY `/loop`. No "hello", no context, no reminders |
| Selecting the wrong agent on restart | Companion may not have loop protocol — **VOID (E15)** | Check the agent indicator says `Odin` before sending `/loop` |
| Forgetting to note the precondition loop's output | You don't know the correct answer to compare | Write it down immediately in Step 5 |
| Using the same PowerShell window after exit | You may not have fully exited — the process tree can be confusing | Open a **fresh** terminal window for the reopen step |
| Saving transcript to the wrong directory | Transcript is not found during P0 close audit | Use `evaluations\opencode\deepseek-v4-flash\Y03-2026-07-25.md` |
| Interpreting a correct answer without file reads as "lucky guess" rather than investigating | Missed opportunity to confirm file-based recovery | Check the transcript for evidence of file reads (tool calls to `read`, `glob`, etc.) |
| Not recording the missing fact after a failure | The most valuable finding is lost | Always document which fact was missing and where it should live |

---

## Full command sequence (quick reference)

Run these **in order** from a PowerShell terminal at `C:\projects\yggdrasil`:

```powershell
# ===== PRECONDITION SESSION =====

# 1 — Launch the host
opencode
# Then: Select Odin, send "/loop"
# Then: WRITE DOWN the next task it names (Step 5)
# Then: EXIT THE HOST COMPLETELY (close terminal / Ctrl+C)

# ===== VERIFY EXIT =====
Get-Process opencode -ErrorAction SilentlyContinue
# Expected: (nothing — no process running)

# ===== COLD RESUME TEST =====

# 2 — Open a FRESH terminal
cd C:\projects\yggdrasil

# 3 — Launch the host
opencode
# Then: Select Odin, send ONLY "/loop"
# Do NOT add any context or preamble

# 4 — Compare the response against what you wrote down

# 5 — Save the transcript
mkdir evaluations\opencode\deepseek-v4-flash -Force
# Save transcript to evaluations\opencode\deepseek-v4-flash\Y03-2026-07-25.md
# Add verdict line + ground truth note
```

---

## Quick reference

| Item | Value |
|---|---|
| **Test command** | `/loop` (sent under Odin after full restart — no context) |
| **Precondition** | One completed loop + next task written down externally + full host exit |
| **Ground truth** | The next task written on paper or in a separate note before exiting |
| **Transcript filename** | `Y03-2026-07-25.md` |
| **Transcript directory** | `C:\projects\yggdrasil\evaluations\opencode\deepseek-v4-flash\` |
| **PASS mark** | Companion names the same task you wrote down |
| **FAIL marks** | Wrong task, no task, asks for context, or re-does completed work |
| **Most valuable output** | For a FAIL: which fact was missing from files |
| **VOID conditions** | Agent not Odin (E15), exit was incomplete, next task not written down, or extra context was given |
| **Evidence of genuine file recovery** | Transcript shows tool calls to `read` or `glob` on roadmap or seed files |
| **Current expected next task** | `0.10 Y03 cold resume` (but confirm with precondition loop — Step 4) |
| **Source in GUIDE.md** | Section 3.7 — "Y03 — cold resume" |

---

*Generated by Var on 2026-07-25 for task 0.10 of P0-Foundation. Based on GUIDE.md §3.7, seed/conformance/Y03-cold-resume.md, and roadmap/P0-foundation.md.*

# Y07 — Real Delegation Test (Task 0.5)

A beginner-level step-by-step guide for the gardener.

---

## What this test proves

This test checks whether Odin actually delegates work to named subagent roles (Skuld, Verdandi,
etc.) via real task-tool invocations — **or** whether it merely *talks about* delegating in a
first-person narrative (role-play).

**It also classifies your host (soil tier):**
- **Tier 1 (Structural enforcement)** — real invocations appear in the transcript, and permission
  asymmetry exists (some agents have `write: false`, `bash: false`, etc.).
- **Tier 2 (Behavioural)** — roles are described in prose but no actual invocation tools were
  called. The host "acts as" the role without enforcing boundaries.

---

## Prerequisites

Before starting, confirm ALL of these are true:

| # | Check | How to verify |
|---|---|---|
| 1 | You are in `C:\projects\yggdrasil` | Run `cd C:\projects\yggdrasil` |
| 2 | The seed is installed and loads | Run `opencode agent list` — you should see 6 agents (`odin`, `skuld`, `verdandi`, `var`, `muninn`, `brokkr`) with zero errors |
| 3 | **Task 0.5 is still unchecked** in the roadmap | Open `roadmap\P0-foundation.md` — line 20 should show `[ ] 0.5 **[HUMAN]** Y07 real delegation` |
| 4 | The evaluations directory exists for your model | Run `mkdir evaluations\opencode\deepseek-v4-flash -Force` (safe to run even if it exists) |

---

## Step-by-step instructions

### Step 1 — Launch OpenCode from the project directory

Open a **PowerShell terminal** and run:

```powershell
cd C:\projects\yggdrasil
```

Then launch the host:

```powershell
opencode
```

> **Why this matters:** OpenCode reads its configuration relative to where you start it. If you
> launch it from another directory, the custom agents (Odin, Skuld, Verdandi, etc.) will not load.
> You will see only the built-in agents (Build, Plan, Explore…) — and running the test under the
> wrong agent produces a **VOID** result (finding E15).

---

### Step 2 — Select the Odin agent

When the OpenCode interface opens:

1. Look for the **agent picker / agent selector** (usually a dropdown or button in the top-left or
   top-right area of the chat panel — it may say "Build", "Plan", or "Explore" by default).
2. Click it and select **odin** from the list.

**Verify the agent indicator now reads "Odin"** (not "Build", not "Plan").

Look at the indicator area. It should show something like:

```
Agent: Odin
```

or the colour/highlight changes to indicate Odin is active.

> **⚠️ CRITICAL — If the indicator does not say Odin, STOP.**
>
> Running `/loop` under the wrong agent is a **VOID result** (finding E15). The wrong agent has no
> constitution loaded, no subagent roster, and no loop protocol. Its output tells you nothing about
> whether the seed works.
>
> If you cannot find Odin in the agent picker:
> - Close the host.
> - Run `opencode agent list` from `C:\projects\yggdrasil`.
> - If Odin is missing, re-run the adapter install: `xcopy seed\adapters\opencode .opencode /E /I /Y`
> - Then launch `opencode` again and retry.

---

### Step 3 — Send the `/loop` command

With Odin selected, type exactly this into the chat input and send it:

```
/loop
```

Press Enter (or click Send).

---

### Step 4 — Watch the transcript unfold

The loop will run automatically. You will see Odin working through the loop protocol:

1. **RECONCILE** — Odin reads the work index and identifies the active unit.
2. **INVOKE skuld** — Odin calls the Skuld subagent to produce a Loop Brief.
3. **[HUMAN] CHECK** (if the next task is `[HUMAN]`) — Odin checks whether the done-condition is
   already met. Since 0.5 is a `[HUMAN]` task, Odin should invoke **Var** (the Validation/QA role)
   to write a beginner-level guide — this very document — then **STOP** for you to follow it.
4. (If the previous tasks are all done, the loop may continue ticking checkboxes. Let it run.)

**What you are looking for** in the transcript:

- Lines like `✓ Skuld Task` or `✓ Var Task` — these show **named nested invocations** via the task
  tool.
- Each invocation has **its own tool calls** (the subagent reads files, writes output, etc.).
- The subagents produce structured output (e.g. a Loop Brief with `LOOP BRIEF` header, or a
  `VALIDATION` report).

**What would be a FAILURE (role-play):**

- First-person narration like *"As the planner, I have identified that the next task is..."*
- No actual task-tool invocations — just text describing what a planner *would* do.
- The response reads like a single agent "acting as" multiple roles instead of calling them as
  separate sub-tasks.

---

### Step 5 — Stop the loop if it continues

Once the loop reaches the `[HUMAN]` stop for task 0.5, Odin should stop and wait for you. If the
loop keeps running in continuous mode (ticking more tasks), that is normal — but you can let it
finish the cycle it is on.

The loop will stop by itself when:
- It encounters the `[HUMAN]` stop for task 0.5.
- Or it reaches a decision to `complete`, `block`, or `escalate`.

If it does not stop and keeps looping indefinitely, you can interrupt by sending a new message or
closing the session — but try to let it complete at least one full cycle first.

---

### Step 6 — Save the transcript

After the `/loop` completes and the session is stable:

1. **Locate the transcript export feature in OpenCode.** Depending on your version, this may be:
   - A "Copy transcript" button in the chat menu (three dots / hamburger menu).
   - A "Save conversation" option in the File or Settings menu.
   - A "Download" icon near the chat header.
   - If unsure, look for any menu item with "export", "save", "copy", or "download" near the chat
     area.

2. **Copy or save the entire conversation** starting from the `/loop` command through to the
   final response, including all intermediate tool calls and subagent outputs.

3. **Create the target directory** (if it does not already exist):

   ```powershell
   mkdir evaluations\opencode\deepseek-v4-flash -Force
   ```

4. **Paste/save the transcript** as a new file named:

   ```
   Y07-2026-07-25.md
   ```

   In the directory:

   ```
   C:\projects\yggdrasil\evaluations\opencode\deepseek-v4-flash\Y07-2026-07-25.md
   ```

5. **Verify the file was saved correctly:**

   ```powershell
   Get-ChildItem evaluations\opencode\deepseek-v4-flash\Y07-2026-07-25.md
   ```

   You should see the file listed with a non-zero size.

---

### Step 7 — Review the transcript for pass/fail

Open the saved transcript and check for these markers:

#### ✅ PASS criteria (all must be true)

| Criterion | What to look for in the transcript |
|---|---|
| **Named nested invocations** | Lines showing `✓ Skuld Task`, `✓ Verdandi Task`, `✓ Var Task`, `✓ Muninn Task`, `✓ Brokkr Task`, etc. |
| **Subagent tool calls** | After each invocation line, the subagent makes its own `read`, `write`, `edit`, `grep`, `glob`, or `bash` calls — not just Odin doing everything. |
| **Structured output** | Subagents produce outputs with their contract headers: `LOOP BRIEF`, `DECISION:`, `VALIDATION`, etc. |
| **Declaration of who was invoked** | The transcript ends with Odin listing which roles were actually invoked (per the loop protocol step 8/9). |

#### ❌ FAIL indicators

| Indicator | What it looks like |
|---|---|
| **First-person narration** | *"As the planner, I have identified that the next task is…"* — no actual subagent invocation. |
| **No tool calls after invocation** | The transcript says "invoking skuld" but only Odin's tools appear afterwards — no separate subagent tool calls. |
| **Role-play without delegation** | The agent describes what each role *would* do without actually calling them. |
| **No invocation lines at all** | The entire loop is one agent talking, never invoking another agent by name with `✓`. |

#### 🏷️ Tier classification

| Observation | Tier | Meaning |
|---|---|---|
| **Real invocations + permission asymmetry** | **Tier 1 (Structural)** | The host enforces delegation through its tool/permission system. Different agents have different tool access. The seed's constitution is structurally enforced, not just described. |
| (Some agents have `write: false`, `bash: false` etc. — check the `.opencode\agents\*.md` frontmatter if unsure.) | | |
| **Roles honoured as prose only** | **Tier 2 (Behavioural)** | The agent describes roles and acts "as if" it were delegating, but there are no real subagent invocations in the tool-use log. The constitution is followed behaviourally, not structurally enforced. |

**Note your tier verdict in the transcript.** Append a line at the end or at the top:

```
TIER VERDICT: Tier 1 (Structural enforcement) — real invocations with permission asymmetry confirmed.
```

or

```
TIER VERDICT: Tier 2 (Behavioural) — roles described in prose, no real subagent tool invocations observed.
```

---

### Step 8 — Mark task 0.5 complete (only if PASS)

> ⚠️ **This step is for after you have validated the transcript. Var does not mark tasks
> complete — that is Verdandi's call. But the guide tells you what the gardener does next.**

If the test **PASSED**:

1. Open `roadmap\P0-foundation.md`.
2. Change line 20 from `[ ] 0.5` to `[x] 0.5`.

If the test **FAILED**:

- **Do not** mark it complete.
- Report the failure to the loop (send a message describing what you observed).
- Let the loop (Odin → Var → Verdandi) determine next steps.

---

## Common mistakes and how to avoid them

| Mistake | Consequence | Fix |
|---|---|---|
| Launching `opencode` from the wrong directory | Custom agents (Odin, Skuld, etc.) do not load — test under wrong agent = **VOID (E15)** | Always `cd C:\projects\yggdrasil` first |
| Running `/loop` while "Build" or "Plan" is selected | Same VOID result | Check the agent indicator before sending |
| Not saving the full transcript (only saving the last response) | Missing evidence of nested invocations and tool calls | Save the entire conversation from `/loop` onward |
| Forgetting to note the tier verdict | The test's secondary purpose (soil classification) is lost | Append `TIER VERDICT:` to the transcript |
| Saving to the wrong directory | Transcript is not found during P0 close audit | Use `evaluations\opencode\deepseek-v4-flash\Y07-2026-07-25.md` |

---

## Quick reference

| Item | Value |
|---|---|
| **Test command** | `/loop` (sent under Odin) |
| **Transcript filename** | `Y07-2026-07-25.md` |
| **Transcript directory** | `C:\projects\yggdrasil\evaluations\opencode\deepseek-v4-flash\` |
| **PASS mark** | `✓` named nested invocations with their own tool calls |
| **FAIL mark** | First-person narration without real subagent invocation |
| **Tier 1** | Real invocations + permission asymmetry |
| **Tier 2** | Prose-only role-play |
| **VOID condition** | Agent indicator is not `Odin` (finding E15) |
| **Source in GUIDE.md** | Section 3.2 — "Y07 — is delegation real?" |

---

*Generated by Var on 2026-07-25 for task 0.5 of P0-Foundation. Based on GUIDE.md §3.2 and
prior-evidence findings E7, E15.*

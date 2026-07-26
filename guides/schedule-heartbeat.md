# Schedule `ygg heartbeat` via Windows Task Scheduler

A beginner-level guide to scheduling the daily heartbeat so the companion checks goals, staging, and active tasks every day without you remembering to run it.

---

## What this does

Creates a Windows Task Scheduler entry that runs `ygg heartbeat` once per day at 8:00 AM. The heartbeat writes a briefing to `seed/memory/log/heartbeat-YYYY-MM-DD.md` and exits. Logs only — no durable memory writes (Y09 compliant).

---

## Step 1 — Open Task Scheduler

Press `Win + R`, type `taskschd.msc`, press Enter.

---

## Step 2 — Create a new task

1. In the right-hand **Actions** panel, click **Create Basic Task...**
2. **Name:** `Yggdrasil Heartbeat`
3. **Description:** `Daily heartbeat check for the companion seed`
4. Click **Next**

---

## Step 3 — Set the trigger

1. Select **Daily**
2. Click **Next**
3. **Start:** today's date, 8:00:00 AM
4. **Recur every:** 1 days
5. Click **Next**

---

## Step 4 — Set the action

1. Select **Start a program**
2. Click **Next**
3. **Program/script:** `powershell.exe`
4. **Arguments:**
   ```
   -NoProfile -ExecutionPolicy Bypass -File "C:\projects\yggdrasil\tools\ygg\ygg-heartbeat.ps1"
   ```
5. **Start in (optional):** `C:\projects\yggdrasil`
6. Click **Next**

---

## Step 5 — Review and finish

1. Review the summary
2. Check **Open the Properties dialog for this task when I click Finish**
3. Click **Finish**

---

## Step 6 — Configure for background running

In the Properties dialog that opened:

1. **General tab:**
   - Check **Run whether user is logged on or not**
   - Check **Run with highest privileges**
   - Uncheck **Stop the task if it runs longer than:** (or set to 15 minutes)

2. **Conditions tab:**
   - Uncheck **Stop if the computer switches to battery power**
   - Uncheck **Start the task only if the computer is on AC power** (if you want it to run on laptop battery too)

3. **Settings tab:**
   - Check **Run task as soon as possible after a scheduled start is missed**
   - Set **If the task fails, restart every:** 5 minutes
   - Set **Attempt to restart up to:** 3 times

4. Click **OK**

---

## Step 7 — Test it

Run the task manually to verify it works:

1. Right-click the **Yggdrasil Heartbeat** task in the Task Scheduler Library
2. Click **Run**
3. Wait a few seconds, then check the output:

```powershell
Get-ChildItem "C:\projects\yggdrasil\seed\memory\log\heartbeat-*.md" | Select-Object -Last 1 | Get-Content
```

You should see today's briefing output.

---

## Verification

After 3+ daily heartbeats, verify Y09 compliance:

```powershell
cd C:\projects\yggdrasil
git diff --name-only -- seed/memory/
```

Expected output: only files under `seed/memory/log/` and possibly `seed/memory/provenance.md`. No profile.md, goals.md, projects.md, capabilities.md, or decisions.md.

---

## Troubleshooting

| Problem | Check |
|---------|-------|
| Task does not run | Open Task Scheduler, check **Last Run Result**. Common fix: the path in the arguments is incorrect for your machine. |
| No briefing file appears | Run the script manually first: `& "C:\projects\yggdrasil\tools\ygg\ygg-heartbeat.ps1"` — fix any errors, then re-test the scheduled task. |
| Script runs but nothing in log | Check `C:\projects\yggdrasil\seed\memory\log\` exists and is writable. |
| PowerShell execution policy blocks it | The `-ExecutionPolicy Bypass` flag in the arguments should handle this. If not, run `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` from an admin prompt. |

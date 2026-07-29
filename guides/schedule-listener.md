# Schedule `ygg listen` via Windows Task Scheduler

Makes the Telegram listener start automatically when you log in, so the companion
is always reachable without remembering to start it.

---

## Step 1 — Open Task Scheduler

Press `Win + R`, type `taskschd.msc`, press Enter.

---

## Step 2 — Create a new task

1. In the right-hand **Actions** panel, click **Create Task...** (not Create Basic Task)
2. **Name:** `Yggdrasil Listener`
3. **Description:** `Telegram listener for the companion seed — always-on presence`
4. Check **Run with highest privileges**
5. Check **Run whether user is logged on or not** (optional — keeps it running after lock screen)
6. Click the **Configure for:** dropdown and select **Windows 10/Windows Server 2016**

---

## Step 3 — Set the trigger

1. Click the **Triggers** tab → **New...**
2. **Begin the task:** `At logon` (or `At startup` if you want it before login)
3. Click **OK**

---

## Step 4 — Set the action

1. Click the **Actions** tab → **New...**
2. **Action:** `Start a program`
3. **Program/script:** `powershell.exe`
4. **Arguments:**
   ```
   -NoProfile -ExecutionPolicy Bypass -Command "& 'C:\projects\yggdrasil\tools\ygg\ygg.ps1' listen"
   ```
5. **Start in (optional):** `C:\projects\yggdrasil`
6. Click **OK**

---

## Step 5 — Configure for background running

1. Click the **Conditions** tab:
   - Uncheck **Stop the task if it runs longer than:**
   - Uncheck **Stop if the computer switches to battery power** (if you want it on laptop)

2. Click the **Settings** tab:
   - Check **Allow task to be run on demand**
   - Check **Run task as soon as possible after a scheduled start is missed**
   - If the task fails, restart every: `1 minute`
   - Attempt to restart up to: `999` (or whatever high number)

3. Click **OK**

If prompted for credentials, enter your Windows password.

---

## Step 6 — Test it

1. Right-click the **Yggdrasil Listener** task in the Task Scheduler Library
2. Click **Run**
3. Send a message to the Telegram bot: `status`
4. You should receive the daily briefing as a reply

To verify it is running:

```powershell
Get-ScheduledTask -TaskName "Yggdrasil Listener" | Get-ScheduledTaskInfo
```

---

## Step 7 — Verify persistence

1. **Restart your computer** (or log off and back on)
2. Send another message to the Telegram bot: `doctor`
3. You should receive the ygg doctor results automatically

If it does not start automatically, check:
- Task Scheduler → Task Status column — look for failure codes
- The **History** tab on the task — look for Event ID 201 (task started) or 103 (task failed)
- Common fix: the `Start in` path is wrong for your machine

---

## Stopping the listener

If you ever need to stop it temporarily, create a file called `.listen-stop` in the
project root:

```powershell
echo "stop" > C:\projects\yggdrasil\.listen-stop
```

The listener will exit within 10 seconds. Delete the file to allow it to run again.
Or disable the scheduled task in Task Scheduler.

---

## Troubleshooting

| Problem | Check |
|---------|-------|
| Task does not start | Open Task Scheduler, check **Last Run Result**. Common fixes: path is wrong, or "Run whether user is logged on or not" needs the stored password re-entered. |
| Listener runs but no response to messages | Run `ygg listen` manually to see errors. Check `$env:TELEGRAM_BOT_TOKEN` is set. |
| Multiple listener instances | Task Scheduler may start a new instance on each trigger. Either use a single logon trigger, or add a start-up script that checks for an existing process. |

# P3 Hardening Guide — Task 3.4

These steps secure this machine before the Telegram listener runs. The GUIDE.md order is
non-negotiable: harden **before** connecting any channel.

---

## Why this matters

The Telegram listener polls a remote API every 10 seconds. It does not accept inbound
connections, so there is no open port from the listener itself. However, once always-on
presence is active, the machine must be secure against:

- Unauthorized physical or remote access
- Supply-chain attacks through PowerShell gallery or npm packages
- Credential theft (the bot token is in your environment variables)

The listener has built-in injection detection (Y04) and ratification refusal (Y10), but
those protect the seed from malicious messages — they do not protect the machine itself.

---

## Step-by-step

### 1. Enable Windows Firewall — deny inbound by default

Open PowerShell as **Administrator**:

```powershell
# Ensure firewall is on for all profiles
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

# Block all inbound by default (already the default, but confirm)
Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultInboundAction Block

# Allow outbound by default
Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultOutboundAction Allow

# Verify
Get-NetFirewallProfile | Format-Table Name,Enabled,DefaultInboundAction,DefaultOutboundAction
```

Expected output: all three profiles show `Enabled: True`, `Inbound: Block`, `Outbound: Allow`.

---

### 2. Create a deny-all outbound rule (optional, belt-and-braces)

If you want to explicitly control what can reach out:

```powershell
# Block all outbound by default (stricter)
Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultOutboundAction Block

# Then create allow rules for what the companion needs:
# - HTTPS outbound (for Telegram API, web search, git push)
New-NetFirewallRule -DisplayName "Allow HTTPS Outbound" -Direction Outbound `
  -Protocol TCP -RemotePort 443 -Action Allow

# - DNS resolution
New-NetFirewallRule -DisplayName "Allow DNS Outbound" -Direction Outbound `
  -Protocol UDP -RemotePort 53 -Action Allow
```

Or keep the default (outbound allow) if that is sufficient for your risk profile.

---

### 3. Set up Windows Update

Ensure the machine receives security patches:

```powershell
# Check update status
Get-WindowsUpdateLog -ErrorAction SilentlyContinue | Select-Object -First 5

# Open Windows Update settings
Start-Process ms-settings:windowsupdate
```

Install any pending security updates before going live.

---

### 4. Secure the Windows user account

```powershell
# Ensure your user account has a strong password
# (do this through Windows Settings > Accounts > Sign-in options)

# Check for other user accounts
Get-LocalUser | Where-Object { $_.Enabled -eq $true } | Format-Table Name,Enabled

# Disable any unused accounts
# Disable-LocalUser -Name "UnusedAccount"
```

---

### 5. Restrict PowerShell execution policy

```powershell
# Set execution policy for the current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Verify
Get-ExecutionPolicy -List
```

Expected: `CurrentUser` shows `RemoteSigned`.

---

### 6. Verify the bot token is stored safely

The bot token is in your User-scope environment variable, not in any file:

```powershell
# Confirm it is set
[Environment]::GetEnvironmentVariable("TELEGRAM_BOT_TOKEN", "User")

# Confirm it is NOT in any seed file
cd C:\projects\yggdrasil
Select-String -Path "seed\*.md" -Pattern "TELEGRAM_BOT_TOKEN" -SimpleMatch
Select-String -Path "tools\ygg\*.ps1" -Pattern "TELEGRAM_BOT_TOKEN" -SimpleMatch
```

The token should appear **only** in the environment. If any file contains it, remove it
immediately and revoke the token via `@BotFather`.

---

## Verification checklist

- [ ] Firewall enabled on all profiles
- [ ] Inbound blocked by default
- [ ] Windows updates current
- [ ] User account secured
- [ ] Execution policy set to RemoteSigned
- [ ] Bot token exists only in environment, not in files
- [ ] Unused accounts disabled

---

## After hardening

Once these steps are complete, the Telegram listener can be started:

```powershell
cd C:\projects\yggdrasil
.\tools\ygg\ygg.ps1 listen
```

To make it start automatically with Windows, create a Task Scheduler entry
(follow the same pattern as `guides/schedule-heartbeat.md`).

---

## Quick reference

```powershell
# Test firewall status
Get-NetFirewallProfile | Format-Table Name,Enabled,DefaultInboundAction

# Test listener (dry run — will connect but not process)
.\tools\ygg\ygg.ps1 listen
# Press Ctrl+C to stop

# View listener logs
Get-ChildItem seed\memory\log\listener-*.md | Select-Object -Last 1 | Get-Content
```

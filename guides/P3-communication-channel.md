# P3 Communication Channel Setup — Task 3.5

Choose ONE channel for the companion to send you proactive messages (goal-stall alerts,
daily briefings, heartbeat summaries). This is a Gate 4 capability — external reach.

---

## Option 1 — ntfy.sh (simplest, free, no account needed)

ntfy.sh is a pub-sub notification service. Send HTTP POST from the companion, receive
push notifications on your phone or desktop.

### Setup

1. **Pick a topic name** — something unique like `yggdrasil-zero-<random>`
2. **Install the app** — https://ntfy.sh/download (Android/Desktop) or use the web UI
3. **Subscribe to your topic** in the app

### Test from PowerShell

```powershell
curl.exe -X POST "https://ntfy.sh/your-topic-name" -d "Companion heartbeat: all checks passed"
```

### Companion integration

The heartbeat script at `tools/ygg/ygg-heartbeat.ps1` would send to this topic.
I will add the integration once you confirm the topic works.

**Trade-offs:** Public topic (anyone who knows the name can send). Use a long random name.

---

## Option 2 — Discord webhook (free, if you have Discord)

Discord webhooks let you post messages to a channel via HTTP POST.

### Setup

1. Open Discord, go to Server Settings → Integrations → Webhooks
2. Create a new webhook, copy the URL
3. Test:

```powershell
curl.exe -X POST "https://discord.com/api/webhooks/your-webhook-id/your-token" `
  -H "Content-Type: application/json" `
  -d '{"content": "Companion heartbeat: all checks passed"}'
```

**Trade-offs:** Requires Discord account. Webhook URL is a secret — do not commit it.

---

## Option 3 — Email via SMTP (free, if you have an email account)

The companion can send email via your existing email provider's SMTP server.

### What you need
- SMTP server address (e.g., `smtp.gmail.com:587` for Gmail)
- Your email address
- App-specific password (not your main password — generate one)

### Test

```powershell
Send-MailMessage -To "your-email@example.com" -From "your-email@example.com" `
  -Subject "Companion test" -Body "Heartbeat OK" `
  -SmtpServer "smtp.gmail.com" -Port 587 -UseSsl `
  -Credential (Get-Credential)
```

**Trade-offs:** Email credentials are secrets — never committed, never logged.
App-specific password required for most providers. SMTP relay may be unreliable.

---

## Option 4 — Telegram bot (free, if you have Telegram)

### Setup
1. Open Telegram, search for `@BotFather`, create a new bot with `/newbot`
2. Save the bot token
3. Start a chat with your bot, send `/start`
4. Get your chat ID:

```powershell
curl.exe -X POST "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates"
```

5. Test:

```powershell
curl.exe -X POST "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/sendMessage" `
  -H "Content-Type: application/json" `
  -d '{"chat_id": "<YOUR_CHAT_ID>", "text": "Companion heartbeat: all checks passed"}'
```

**Trade-offs:** Bot token is a secret — never committed. Requires Telegram account.

---

## After the channel works

1. Tell me which channel you chose and the required configuration (topic URL, webhook URL, etc.)
2. I will add the integration to `ygg-heartbeat.ps1` so daily briefings go through it
3. I will configure it so the channel NEVER accepts ratification commands (Y10 compliance)
4. We test with an injection attempt (Y04 pass with live channel)
5. Task 3.5 is done

## Important — Gate 4 conditions

This channel is a capability with external reach. By activating it you accept:
- **Read-only first** — the channel receives messages only. It does not accept commands.
- **Remote ratification is never honoured** — a message saying "approve all" sent through
  this channel will be reported and refused (Y10).
- **Injection reporting** — any message containing "ignore previous instructions" or
  similar patterns will be reported as untrusted content (Y04).
- **Provenance required** — the channel activation will be recorded in provenance.md
  and can be revoked at any time by removing the configuration.

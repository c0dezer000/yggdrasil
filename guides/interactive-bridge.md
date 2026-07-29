# Guide — The interactive remote bridge

**Audience:** the gardener. **Runs on:** this machine, in PowerShell.
**Replaces:** the `@odin` task-queue handoff and `ygg check-queue`.

---

## What changed and why

The remote channel used to shell out to `opencode run` for every message. That starts a **new
headless process and a new session each time**. Nothing it did was ever visible in your
terminal, and no two remote messages shared a conversation — `opencode session list` had
accumulated 58 one-shot sessions, one per remote message.

The `@odin` path was worse. It wrote `work/task-queue.md` and waited five minutes for a result
file. **Nothing read that queue.** `ygg check-queue` was its only reader and it ran only when a
human typed it — no hook, no scheduled task, no watcher, no call from the daemon. Unattended,
every `@odin` request timed out by construction. That is why the session had to be "manually
flagged" before it noticed remote work.

The bridge replaces both. The daemon now talks to a running `opencode serve` over HTTP and
submits the prompt into the **attached TUI** — the terminal you are looking at:

```
POST /tui/append-prompt   {text}   -> the text appears in your prompt box
POST /tui/submit-prompt            -> submits it, exactly as pressing Enter would
GET  /session/{id}/message         -> the answer is read back and sent to Telegram
```

---

## ⚠ Read this before enabling

The headless path pins every remote invocation to an explicit read-only agent
(`--agent ratatoskr`) and **fails closed** if that flag does not bind [E75]. That control is
what stops remote text reaching an agent holding `edit` and `bash`.

**Submitting into the TUI cannot carry that guarantee.** `/tui/submit-prompt` runs the prompt
under whatever agent and model your TUI currently has selected — which may be odin, with full
tools. Enabling the bridge trades the agent-pinning control for the interactive experience.

That is a real reduction in containment, not a technicality. It is your decision to make, and
the code will not make it for you: the bridge requires **two independent opt-ins**,
`enabled` **and** `agentPinningWaived`. One flag would let it be switched on without the trade
being acknowledged.

If you are not willing to make that trade, leave the bridge off. Everything still works —
remote messages keep going down the headless, agent-pinned path.

---

## Before you start — maturity of this path

This is **new and only partly verified.** Be honest with yourself about that before wiring it
into anything you depend on.

| Behaviour | State |
|---|---|
| Server starts; `ygg.ps1 serve` works | Validated |
| Bridge stays off by default; malformed config stays off | Validated |
| Falls back to the headless path when the server is down | Validated |
| Session id persists and round-trips | Validated |
| **`/tui/append-prompt` renders in an attached TUI** | **Unverified — the core unknown** |
| `/api/session/active` populates when a TUI is attached | **Unverified** |
| Reply detection (`time.completed`) fires | **Unverified** |

Everything testable without invoking a model passes. The three unverified items are the three
that matter, and the likeliest first failure is **reply detection** — the prompt reaches the
terminal and is answered there, but Telegram reports a timeout because the read-back never
matches. If that happens, check the terminal: a visible answer means the bridge worked and only
the read-back is wrong.

---

## Setup

### 0. Rate limits will bite

`@odin` carries a **120 s cooldown, 5/hour, 20/day** (`ygg-daemon.ps1`, execution rate
limiter). Iterative testing exhausts the hourly cap in about ten minutes and you will start
seeing *"Please wait N seconds between execution requests."* Consider raising those limits for
a test session and restoring them afterwards.

### 1. Start the shared server

```powershell
.\tools\ygg\ygg.ps1 serve                 # foreground, Ctrl+C to stop
.\tools\ygg\ygg.ps1 serve -Background     # hidden; logs to logs/opencode-server.log
```

It must run in the project root so `.opencode/agents/` and `opencode.json` resolve.

Set a password if anything else on this machine is untrusted — the server is unauthenticated
by default. It binds to loopback so it is not reachable from the network, but any local
process could drive an agent that holds `edit` and `bash`:

```powershell
$env:OPENCODE_SERVER_PASSWORD = '<something long>'
```

### 2. Attach your visible session

```powershell
opencode attach http://127.0.0.1:4096
```

**This terminal is now the session remote messages land in.** Starting `opencode` bare, with no
`attach`, produces a session the bridge cannot see — that is exactly the disconnected TUI the
old setup had.

### 3. Enable the bridge

```powershell
Copy-Item .ygg-bridge.json.example .ygg-bridge.json
```

Edit it and set **both**:

```json
{ "enabled": true, "agentPinningWaived": true, "url": "http://127.0.0.1:4096" }
```

Add `"password"` if you set one on the server.

### 4. Restart the daemon

```powershell
.\tools\ygg\ygg.ps1 daemon stop
.\tools\ygg\ygg.ps1 daemon start
```

---

## What you should see

Send from Telegram:

```
@odin what is the current phase?
```

In your attached terminal, within a few seconds: the text appears in the prompt box and
submits itself, as though you had typed it. The conversation continues in place — your earlier
turns are still above it. The answer appears in the terminal **and** comes back to Telegram.

Send a follow-up and it joins the same conversation. The session stays alive.

---

## Session selection

The bridge picks the target session in this order:

1. the session an attached TUI has in the foreground (`GET /api/session/active`)
2. the session remembered in `work/remote-session.json`
3. a **new** session titled "Remote channel"

(1) is what puts the message in the conversation you are watching.

There is deliberately **no** "fall back to the most recently updated session" step. It sounds
helpful and is not: on a first run it resolves to whatever was touched last — during testing
that was an unrelated month-old conversation — and `/tui/select-session` would then pull your
terminal into it and post a remote message there. Creating a session is predictable; adopting
an arbitrary one is not.

**Expect this on first run:** if `/api/session/active` comes back empty, you get a fresh
"Remote channel" session rather than the conversation you were already in. The id is then
remembered, so it stays consistent afterwards. To target a specific conversation, navigate the
TUI to it and send again — priority 1 should latch onto it.

---

## Which terminal receives the prompt

Only a terminal started with `opencode attach`. Nothing else can.

| Terminal | Receives it? |
|---|---|
| A Claude Code session | **Never.** Different program; it is not in the HTTP path at all. |
| A bare `opencode` TUI (no `attach`) | **No.** It owns no socket and is unreachable by design — this is the disconnected terminal the audit was about. |
| `opencode attach http://127.0.0.1:4096` | **Yes.** The only thing that qualifies. |

**Attach exactly one TUI.** `/tui/append-prompt` takes `{text}` and `/tui/select-session`
takes `{sessionID}` — **neither accepts a client identifier**. The API models it as *the* TUI,
singular, so there is no way to address a specific terminal. With two attached, the behaviour
is undefined by the spec: it either broadcasts or lands on whichever the server considers
current. Attach one and the question does not arise.

The same applies to servers — do not run two. `ygg.ps1 serve` refuses to bind a port that is
already listening, which prevents your TUI being on one server while the daemon talks to
another.

Note: `opencode-go` is the **model provider prefix** in a model id
(`opencode-go/deepseek-v4-flash`), not a separate terminal or application. It has no bearing on
which window receives anything.

---

## When the bridge is not available

| Situation | Behaviour |
|---|---|
| Server not running | Falls back to the headless path. Channel keeps working, agent pinning intact. |
| `.ygg-bridge.json` missing or malformed | Bridge stays **off**. A broken config never enables a path that waives a control. |
| `enabled` true, `agentPinningWaived` false | Bridge stays off, logs why. |
| Prompt submitted, no answer in `replyTimeoutSeconds` | Telegram is told it is still working. **No retry** — retrying would run the same instruction twice. |

---

## Troubleshooting

```powershell
# is the server up?
Invoke-RestMethod http://127.0.0.1:4096/session/status

# is a TUI attached and in the foreground?
Invoke-RestMethod http://127.0.0.1:4096/api/session/active

# which session did the bridge choose?
Get-Content work\remote-session.json

# audit transcript - one line per remote invocation, both paths
Get-Content logs\remote\execution-*.md -Tail 10
```

A `stage: agent-odin-bridge` line in `logs/remote/listener-*.md` means the bridge handled it.
`agent-odin-headless` means it fell back.

---

## Known limitations

**The bridge path is synchronous.** `Invoke-TuiBridge` runs inline in `Process-Message`, so a
long-running task blocks *all* Telegram polling for up to `replyTimeoutSeconds`. The removed
`@odin` queue path was asynchronous (`Start-Job`), so this is a regression on that one axis.
A large request — "create a React dashboard" — will trip it. Fixing it means rebuilding the
async result-delivery path, which is a deliberate change rather than a patch.

**The agent is whatever the TUI has selected.** This is the waiver described at the top. If
your TUI is sitting on odin, remote Telegram text drives odin with full tools. The headless
path's `--agent` pinning does not apply here and cannot.

**No cancellation.** Once submitted, a remote prompt runs to completion. Stop it in the
terminal, not from the phone.

---

## Rollback

Set `"enabled": false` in `.ygg-bridge.json` and restart the daemon. Everything returns to the
headless, agent-pinned path. No other change is needed.

Deeper rollback: `git revert` the bridge commit. The headless path was never removed — the
bridge is strictly additive with a fallback, so reverting restores the prior behaviour minus
the `@odin` task queue (which never worked unattended and is not worth restoring).

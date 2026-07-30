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

### State-changing git from the remote channel — permitted 2026-07-30

**Granted by gardener decision on 2026-07-30.** `git commit`, `push` and `tag` may be executed
in response to a remote message, via `@bifrost`, on explicit gardener instruction.

This supersedes the blanket prohibition in `guides/execution-bridge-verify.md`
(*"`git commit`/`push` are forbidden — no state-changing version control"*), which described
the old headless execution path.

Understand what the grant costs, because it is not the same trade the 2026-07-26 boundaries
amendment made. That amendment permitted state-changing git via `@bifrost` and rested on **two**
mitigations:

| Mitigation | Local session | Remote channel |
|---|---|---|
| **Structural** — bifrost is outside Odin's roster, so it cannot be invoked autonomously; a human names it | Holds | **Does not hold.** The bridge submits into whatever agent the TUI has selected. Nothing structurally prevents a remote message reaching a git-capable path. |
| **Behavioural** — plan-then-confirm: present commands, stop, gardener approves, execute | Holds | Holds, but both halves now arrive over the same untrusted channel |

The amendment itself recorded that `git push` *"introduces an outbound exfiltration channel
mitigated by the structural roster exclusion and behavioural plan-then-confirm workflow."*
On this path only the behavioural half survives.

**What this means in practice:** the approval step is the whole control. If a remote message can
produce both a plan and a "proceed", it can produce a push. Treat the Telegram account as
equivalent to commit access, and keep `TELEGRAM_CHAT_ID` pinned to one authorised chat — the
Stage 0 sender check in `ygg-daemon.ps1` is now load-bearing for version control, not just for
conversation.

Precedent: this already happened on 2026-07-30 at 00:51 (`logs/remote/listener-2026-07-30.md`,
stage `general-bridge`) before it was permitted. The grant regularises it rather than
authorising something new.

---

## Before you start — maturity of this path

The core mechanism was **confirmed working on a live test (2026-07-30)**: a Telegram message
appeared in the attached terminal and was answered there, and the answer returned to the phone.
Two defects that test exposed are fixed (session targeting, response encoding). Treat it as
working-but-young rather than proven.

| Behaviour | State |
|---|---|
| Server starts; `ygg.ps1 serve` works | Validated |
| Bridge stays off by default; malformed config stays off | Validated |
| Falls back to the headless path when the server is down | Validated |
| Session id persists and round-trips | Validated |
| **`/tui/append-prompt` renders in an attached TUI** | **CONFIRMED** on 2026-07-30 live test |
| `/api/session/active` populates when a TUI is attached | **NO — returns `{}` even with a TUI attached.** Bridge no longer uses it. |
| Reply detection (`time.completed`) fires | **CONFIRMED** — field is populated; replies extract correctly |

What the live test changed: `/api/session/active` turned out to be useless on this build, so
session targeting was rewritten to discover the session *after* submitting rather than choosing
one beforehand. The response decoding was also wrong — see **Known limitations** — and both are
now fixed.

Still unproven: behaviour with a long-running task, with two TUIs attached, and after the
server restarts underneath an attached TUI.

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

**The bridge does not pick a session. It uses whichever one your TUI is already showing.**

`/tui/append-prompt` types into the TUI's prompt box and `/tui/submit-prompt` submits it to the
conversation on screen. Delivery never needed a session id — only reading the answer back does,
and that is discovered *afterwards*:

1. snapshot every session's last-updated time **before** submitting
2. submit
3. poll for sessions that changed, and find the one whose newest user message is the prompt just
   sent — that is the target
4. wait there for the assistant's reply, then relay it to Telegram

**This was learned the hard way.** The first design chose a session up front via
`GET /api/session/active`. On this build that endpoint returns `{"data":{}}` **even with a TUI
attached**, so the bridge fell through to creating a session and then called
`/tui/select-session` — which navigated the terminal away from the live conversation into a
fresh "Remote channel" one. Nothing was lost, but the conversation appeared to be cleared.

### `selectSession`

Defaults to **false**, which is what you want: no navigation, the prompt joins the conversation
in front of you.

Set it `true` only to pin the remote channel to one dedicated conversation — it forces the TUI
to jump to the last session the channel used before each submit.

### If no TUI is attached

The `/tui/*` calls still return 200 with nothing listening, so step 3 finds no session showing
the prompt. The bridge then reports `delivery-unconfirmed` and Telegram is told to check the
terminal. **It does not fall back to the headless path in this case** — the submit was accepted,
so re-running the prompt headlessly could execute the same instruction twice. An unanswered
message is recoverable; a duplicated one is not.

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

## Permission prompts

When the agent needs approval — reading outside the project directory, running a command,
writing somewhere new — opencode raises a permission dialog **and blocks until a human answers
it**. That dialog is visible only in the terminal. A remote sender sees nothing; the turn simply
never completes.

Observed live on 2026-07-30:

```
Permission required
  Access external directory C:\Users\...\AppData\Local\Temp\opencode
  Allow once | Allow always | Reject
```

The bridge now relays these. When a request appears for the session it is waiting on, you get:

```
Permission needed before I can continue.

Type: external_directory
Path: C:\Users\...\Temp\opencode\check-bom.ps1

Reply with one of:
  allow   - just this once
  always  - and remember it
  reject  - refuse
```

Reply with any of `allow` / `yes` / `ok` / `once`, `always` / `remember`, or
`reject` / `no` / `deny` / `cancel`. The decision is posted to
`POST /permission/{id}/reply` and the session continues.

**There is no auto-approve, and there will not be one.** opencode's `run --auto` flag is
documented as *"auto-approve permissions that are not explicitly denied (dangerous!)"*. Wiring
that to an untrusted remote channel would let remote text authorise the agent to read outside
the project or run commands with nobody deciding. The bridge carries the question and the
answer; the human decides.

Matching is **exact and anchored**, so an instruction that merely contains the word is not
mistaken for consent — `allowance` and `allow the deploy` are both treated as ordinary messages,
not approvals. Anything that is not a recognised decision falls through and is handled as a
normal message, so you are never trapped in a mode you cannot leave. Answering in the terminal
instead works too — the bridge notices the request is gone and resumes.

While a decision is outstanding the deadline extends to 15 minutes, since a human has to read
and answer.

---

## Known limitations

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

# Heimdall — risk angle: what does each path newly expose?

**Read before writing:** `deliberation/harness-decision/00-question.md` ·
`deliberation/harness-decision/01-kvasir-position.md` ·
`deliberation/harness-decision/02-var-critique.md` · `seed/protocols/deliberation.md`.
Read to check claims: `seed/constitution/gates.md` · `seed/memory/capabilities.md` ·
`seed/memory/provenance.md` · `seed/memory/staging.md` ·
`seed/conformance/Y16-lethal-trifecta-assessment.md` · `guides/P3-communication-channel.md` ·
`guides/P3-hardening-guide.md` · `tools/ygg/ygg.ps1` · `tools/ygg/ygg-listen.ps1` ·
`tools/ygg/ygg-daemon.ps1` · `.opencode/opencode.json` · `.opencode/agents/odin.md` ·
`.gitignore` · `seed/memory/log/listener-2026-07-28.md` · `.ygg-daemon.json` ·
`.ygg-daemon.pid` · `.ygg-send-debug.log`.

**Model:** claude-opus-5 · **Lab:** Anthropic
*(Read from this live session's own model statement, not from any roster document.
`seed/adapters/opencode/model-assignment.md:47–48` assigns heimdall `glm-5.2`; that document does
not describe this session. The var/heimdall same-lab compromise Kvasir cites at `01:113–115` and
Var re-cites at `02:275` does **not** hold for this workspace — seats 02 and 03 are both
`claude-opus-5`/Anthropic, which is a **worse** independence position than the one on paper, and
the memo should record it. My review of Var's findings is a same-model self-check.)*

---

## Steelman

Both prior seats, in their strongest form, and I will not weaken either.

**Kvasir.** The four evidence items are silent on the question. Delegation behaviour is a function
of prompt, allowlist and request shape — a new runtime supplies all three and changes none of them.
The system named its own enforcement gap at `seed/adapters/claude/metadata.md:41`, classified the
host as capable of closing it, and left it open. You cannot read an architectural verdict off a
configuration that has never been run with its own enforcement on. That argument holds regardless
of which way the conclusion falls, which is what makes it an argument rather than a preference.

**Var.** Stronger still, and it dismantles Kvasir's mechanism with data Kvasir did not open: the
same allowlist, same model, same host produced 0 delegations and 48. A constant cannot explain a
difference. What varies is procedural form — numbered `INVOKE` steps are executed, prose rules are
not. And the pattern generalises: two false conformance claims, an absent evidence directory, an
unrun `claude doctor`, two unloadable agents, three unwritable seats. **A harness inherits that
practice unchanged.** Var then did the thing this protocol exists to produce — ran V5 and V6, and
confirmed its opponent's central inference against its own interest.

I accept both. My angle does not overturn either. It adds the one thing neither measured.

---

## Position

**Both seats scoped the system as the agent layer. The system's largest exposure is not in the
agent layer. It is a live, unauthenticated remote-execution channel in `tools/ygg/ygg-daemon.ps1`
that is running on this machine right now, is trifecta-complete, was never gated under Gate 4, and
appears nowhere in the capability registry. Neither path in this question touches it. That is the
finding: the two candidate paths are being priced against each other while the actual exposure sits
outside both of their remedies.**

### 1. The baseline, measured

Not stipulated. Read from disk in this session.

| # | Check | Method | Result |
|---|---|---|---|
| H1 | Daemon liveness | `.ygg-daemon.json` + `Get-Process -Id` | **OBSERVED** `"status": "running"`, pid 19976, a live `powershell` process started 2026-07-28 00:25:58, uptime 5812s |
| H2 | Sender authorization | `grep tgChatId`, `grep 'ChatId -ne\|-eq\|-notin'` in `ygg-daemon.ps1` | **OBSERVED** none. `$script:tgChatId` is written at `:351–355` and read only for outbound sends; it is never compared to the inbound `$ChatId` |
| H3 | Host permission config | `.opencode/opencode.json` | **OBSERVED** `"edit": "allow"`; bash `"git push*": "allow"`, terminal `"*": "allow"` |
| H4 | Capability registration | `grep -rn -i telegram seed/` | **OBSERVED** 0 matches across the entire `seed/` tree — registry, provenance, staging, conformance |
| H5 | Untrusted content persisted | `ygg-listen.ps1:96`, daemon equivalent; `.gitignore` | **OBSERVED** remote message text written verbatim into `seed/memory/log/listener-YYYY-MM-DD.md`; that path is not gitignored |
| H6 | Y04 filter shape | `ygg-daemon.ps1:184–203`, `:334–345` | **CODE-READ, not behaviourally tested** six lowercase substrings, plus a bypass: any message containing `disclaimed`, `Y04 test`, or `Y04 disclaim` is passed through to Stage 3 |

**What the chain does.** A Telegram message arrives. `Process-Message` runs three checks — a
ratification substring check, an injection substring check with the disclaimer bypass, and a 30s
per-chat-id rate limit. Anything surviving reaches one of three sinks:

- `:414–422` — `ygg <args>`, split on whitespace and passed to `ygg.ps1`, which dispatches to
  `plant`, `verify`, `gate-l1/l2`, `daemon`, `doctor`, `heartbeat`. **This path runs before the
  rate-limit check at `:425`.**
- `:436–453` — `@agent <prompt>`, restricted to five read-only agents. This is the one control in
  the file that is doing real work, and I credit it.
- `:455–509` — anything else. Remote text is concatenated into a prompt file with project context
  and piped to `opencode run -m opencode-go/deepseek-v4-flash` **with no `--agent` flag**, therefore
  under the default agent, therefore under `.opencode/opencode.json`, which is `edit: allow` and
  bash `*: allow`.

The composition: **an unauthenticated remote party can cause an LLM to run arbitrary shell commands
and edit arbitrary files on the Gardener's machine.** The barrier is that they must know the bot's
username. That is obscurity, not authentication, and Telegram bot usernames are searchable.

`seed/memory/log/listener-2026-07-28.md` shows the general path is the one in real use — six
messages, all `stage: general`, all routed to `opencode`.

### 2. Lethal-trifecta map

Per `boundaries.md` and `Y16`, the test is the **resulting configuration**, not what the capability
introduces.

| Capability | Private data | Untrusted content | External communication | Complete? | Registered? |
|---|---|---|---|---|---|
| `web-search` (huginn) | yes | yes | yes | **yes** | yes — `capabilities.md:7`, gated, probation, tier-tagged |
| **Telegram daemon, general path** (`ygg-daemon.ps1:455–509`) | yes — SLICES, `[HUMAN]` tasks, and whatever the default agent reads under `edit/bash: allow` | yes — the message body *is* the prompt | yes — replies to the sender, plus `git push*: allow` | **yes** | **no — H4** |
| **Telegram daemon, `ygg` path** (`:414–422`) | yes — doctor/heartbeat output | yes — argv from the sender | yes — output returned to sender | **yes** | **no** |
| **Telegram daemon, `@agent` path** (`:436–453`) | yes | yes | yes | **yes**, mitigated by the five-agent allowlist | **no** |
| Listener log write (`ygg-listen.ps1:96`) | — | yes, stored verbatim under `seed/memory/` and committed | — | stored-injection vector into the memory tree agents read at bootstrap | **no** |

Gate 4 (`gates.md:15`) requires, for any capability with external reach: *default-deny, read-only
first, per-write approval, provenance required.* The daemon is default-allow, is not read-only,
has no per-write approval, and has no provenance. Four of four.

I record the consequence plainly under my own charter: `gates.md:38` makes a security BLOCK
verdict a mandatory stop. **My BLOCK is scoped to the daemon capability, not to this
deliberation.** The deliberation should continue; it is the one place the finding gets read.

### 3. What each path newly exposes

This is the question I was seated to answer.

**Continue as a seed — newly exposed: nothing. Already exposed: everything above, and neither
seat's remedy reaches it.**

The seed path adds no new exposure. But the record of what is enforced is wrong in a direction
neither seat caught. Both seats treat V6 — a read-only agent unable to call `Write` — as proof that
enforcement exists. V6 is real and I accept it. It proves the host's **per-agent tool allowlist**
works *inside the agent boundary*. It says nothing about a PowerShell process that is not an agent,
holds no allowlist, and invokes the host as a subprocess. The largest privilege in this system is
held by exactly such a process.

Kvasir's falsifier 1 strips `Write, Edit, Bash` from odin. The daemon keeps all three, because it
never had an allowlist to strip. Var's six text edits at `02:229–233` are all real and all
necessary and not one of them touches `ygg-daemon.ps1`. **Both remedies operate one layer above
the exposure.**

Against myself: `.opencode/opencode.json` (H3) sets `edit: allow` and bash `*: allow`, so the
host's *permission-prompt* layer is currently configured wide open. The per-agent allowlist and the
permission prompt are two different controls; V6 demonstrates the first, and the second is
disabled by configuration. My "the seed path keeps a working control" claim survives only for the
first, and it is weaker than I would like it to be.

**Rebuild as a harness — newly exposed, five items.**

1. **The permission engine becomes seed-authored.** V6 is a control the seed did not write, did not
   test, and gets for free. A harness must reproduce it. The best available sample of this
   project's unreviewed security engineering is `ygg-daemon.ps1`: a deny-list of six substrings
   with a bypass keyword, no sender authentication, and a rate limit that gives each attacker their
   own bucket. That is not an argument that the team is careless — it is an argument that
   security-critical code written without a review step comes out this way, and a harness is
   security-critical code written without a review step. This is Var's `02:209` — "a harness would
   inherit this practice unchanged" — instantiated on the one component where inheriting it is
   unrecoverable.

2. **No third-party patch stream.** Claude Code is at 2.1.220 (Var's V8); opencode ships from
   upstream. Both vendors fix sandbox-escape and prompt-injection classes without the seed doing
   anything. A harness ships whatever the seed ships, on whatever schedule the seed has. Nobody has
   named a maintainer for that stream. Cost: **unknown**, and unlike build cost it is recurring and
   never finishes.

3. **Egress and credentials multiply with lab count.** Evidence item 4 is scored in this record
   purely as capability. It is also exposure. Every lab in the pool is a destination that receives
   seed memory — `profile.md`, `goals.md`, `projects.md` are private data by `Y16`'s own baseline
   table. Var establishes the seated count is three (`02:216`). Going to eleven is roughly a 3.7x
   increase in parties holding the Gardener's private context, and a similar increase in API
   credentials at rest on a machine whose current credential practice is a User-scope environment
   variable (`P3-hardening-guide.md:114–129`). Nobody has priced this. **Unknown**, and it moves in
   the wrong direction.

4. **A single intermediary, conditionally.** If Zen exposes eleven labs through one API, then one
   third party sees every prompt the system sends to every model — a concentration of visibility
   that does not exist today across three direct providers. **I flag this as unverified.** The
   string "Zen" appears nowhere in this repository outside `00-question.md`; both prior seats
   confirmed this and so do I. If Zen is instead a key manager holding eleven direct credentials,
   the intermediary exposure does not arise and only item 3 does. **I do not know which, and I will
   not guess.** Either way exposure increases; the two cases differ in kind and the record cannot
   currently tell them apart.

5. **Blast radius.** A defect in a host runtime is bounded by that vendor's sandbox. A defect in a
   harness that also owns the daemon is bounded by nothing — the daemon is already the thing
   accepting remote input.

**What the harness newly buys, in security terms — and this is the only such item, so I state it
at full strength.** The daemon is dangerous precisely *because* it sits beside the permission
boundary rather than inside it: it invokes `opencode` as a subprocess, so no agent-scoped control
can reach it. A harness that owned both the channel and the execution layer could put remote input
inside the permission boundary by construction. That is a genuine architectural argument for the
harness and it is the first one in this record that is about architecture rather than discipline.

It is also achievable without a harness, for far less: route the general path through
`--agent <read-only-agent>` exactly as `:436–453` already does for the `@` path. The mechanism to
fix it is nine lines away from the defect, in the same file.

### 4. Cost and exposure, to `00-question.md:47`

**Seed.** Newly exposed: nothing. Recurring: $60/month, corroborated in-repo by Var. Unremediated:
the Gate 4 items in §2. Remediation cost: **bounded and enumerable** — sender allowlist, route the
general path through a read-only agent, tighten `opencode.json`, register the capability, gitignore
the listener logs. Every item is an edit to one file plus a registry entry.

**Harness.** Newly exposed: five items above, of which items 2, 3 and 4 are recurring and
currently **unknown**. Build cost: **unknown**, and I add one line to Var's scoping list at
`02:277–280` — *the threat model*, written before the code, for a component that accepts remote
input. Buys: the ability to put remote input inside the permission boundary.

**Cost of deciding now, from my angle:** the decision is being taken with the system's largest
capability absent from the capability registry. Neither branch fixes that, and choosing either one
first would consume the attention that fixing it requires.

---

## SECURITY REVIEW

**Scope:** the two candidate paths in `00-question.md`, plus the live external-reach surface both
inherit — `tools/ygg/ygg-daemon.ps1`, `tools/ygg/ygg-listen.ps1`, `.opencode/opencode.json`.

**Threat surface:** inbound Telegram messages from any sender who knows the bot username →
substring filters with a documented bypass → three execution sinks, one of which is an LLM with
`edit: allow` and bash `*: allow` on the Gardener's machine.

**Lethal-trifecta map:** §2 above. Four capabilities trifecta-complete; one registered.

**Checklist:**

| # | Item | Verdict |
|---|---|---|
| C1 | External-reach capability registered in `capabilities.md` | **FAIL** (H4) |
| C2 | Gate 4 default-deny | **FAIL** — `:455` accepts any sender, any text |
| C3 | Gate 4 read-only first | **FAIL** — general path reaches `edit`/`bash` allow |
| C4 | Gate 4 per-write approval | **FAIL** |
| C5 | Gate 4 provenance recorded | **FAIL** (H4) |
| C6 | Sender authentication | **FAIL** (H2) |
| C7 | Untrusted-content doctrine applied to inbound messages | **FAIL** — substring deny-list with a keyword bypass (H6); contrast the `web-search` sanitizer at `capabilities.md:17` |
| C8 | Untrusted content kept out of durable memory paths | **FAIL** (H5) |
| C9 | Remote ratification refused (Y10) | **PASS** — `:325–332`, and correctly placed before every sink |
| C10 | Privileged agents unreachable remotely | **PASS** — `:441` excludes brokkr, bifrost, muninn, odin |
| C11 | Bot token kept out of files and logs | **PASS** — env-scoped; `.ygg-send-debug.log` contains no token, though it is neither gitignored nor tracked |
| C12 | Rate limiting present | **PARTIAL** — 30s per chat id, per-attacker bucket, and bypassed entirely by the `ygg` path at `:414` |
| C13 | Harness threat model exists | **FAIL** — not written; no harness scope document exists to review |

**Verdict: BLOCK** — scoped to the Telegram daemon capability in its current configuration.
**PASS-WITH-CONDITIONS is not available** because C1–C8 fail together and C2–C5 are the four
clauses of Gate 4.

On the harness-versus-seed question itself I issue **no verdict**, because C13 fails: there is
nothing to review. A path cannot be security-approved on the basis of a description.

**Conditions for unblocking the daemon** — all five, each verifiable by reading the file
afterwards:

1. **Sender allowlist.** `Process-Message` rejects any `$ChatId` not equal to `$script:tgChatId`,
   and `$script:tgChatId` is set from configuration only — delete the first-message adoption at
   `:351–355`. This alone removes the unauthenticated part and is roughly four lines.
2. **General path through a read-only agent.** `:506` gains `--agent` naming one of the five
   already allowlisted at `:441`, so remote input can no longer reach a default agent holding
   `edit`/`bash`.
3. **`ygg` path restricted.** `:414–422` allowlists subcommands to `doctor`, `heartbeat`, `verify`;
   `plant`, `gate-l1`, `gate-l2`, `daemon` are removed from remote reach; the path moves below the
   rate-limit check at `:425`.
4. **Registration.** A row in `seed/memory/capabilities.md` with declared-vs-actual, tools
   used/exposed, tier tag and probation status, staged and ratified per `gates.md:17`, plus a
   provenance entry. The `web-search` row is the template and the standard.
5. **Untrusted content out of the memory tree.** Listener logs move outside `seed/memory/`, or the
   message text is stored hashed/truncated and the path is gitignored.

I have fixed none of these. My charter forbids it (`Forbidden: fixing security issues found`), and
the loop should assign them.

---

## Where I disagree

**1. With Var, `02:339`** — "Choosing a runtime to fix that is a category error, **and it is the
same error whichever branch is chosen**."

The first clause is right and I adopt it. **The second clause is false, and this is my named
disagreement for the memo.** The two branches are not symmetric. The seed branch leaves in place a
per-agent tool allowlist that Var itself demonstrated working (V6) and a vendor patch stream that
arrives whether or not anyone runs a check. The harness branch **deletes both and rebuilds them by
hand**. Var's own strongest finding — that this project's records of its own behaviour are asserted
rather than measured — is precisely the reason the harness branch is worse than the seed branch and
not merely equal to it. A practice that does not run its checks should not be given custody of its
own permission engine. Var reached the symmetric conclusion because it scoped the failure as a
documentation failure; §1 above shows the same practice has already produced an executable failure,
and executable failures do not stay symmetric when you move the enforcement boundary.

**2. With Kvasir, `01:129–131`** — the "Forecloses" line for the seed path, which lists only
simultaneous seats, live shared workspace, and enforcement the host does not offer. Omitted: the
seed path forecloses nothing, but it **retains** an unregistered trifecta-complete capability. A
cost table that lists what a path forecloses and not what it leaves running is incomplete in the
direction that matters.

**3. With Var, `02:229–233`** — "Build cost to reach *currently specified* behaviour: not zero, and
now enumerable" followed by six text edits. The enumeration is right about what it covers and
incomplete about what it omits. The seed path's real cost is those six edits **plus a Gate 4
capability review that has never been held for the system's largest capability**, plus the five
conditions above. Still bounded. Still much smaller than a harness. But "six text edits" will be
read by the Gardener as the price of the seed path, and it is not.

**4. With `00-question.md:18–26`, the evidence set.** Four items, all about delegation counts and
model pools; none about exposure. The evidence frame contains no security dimension at all, so a
decision taken on it alone is taken blind to the thing that is actually running on the machine. I
am not asking for the question to be rewritten. I am recording that the evidence set is
under-specified for the decision it is being used to make.

**5. With myself, recorded against my own position.** H6 is code-read, not behaviourally tested.
Var set the bar for this workspace by running V5 and V6 rather than inferring them. I did not send
a probe message, because doing so would exercise a live external channel against a Gate 4
capability that has never been approved — the same reason Var ran its probes in a scratch
directory. The finding is therefore weaker in kind than Var's, and I say so rather than let the
table imply otherwise.

---

## What would change my mind

**1. A sender authorization check I missed.** Quote the line in `ygg-daemon.ps1` where an inbound
`$ChatId` is compared against an allowed value before Stage 3. I grepped for `tgChatId`, `-ne`,
`-eq`, `-notin` and `Unauthorized` and found none. **If it exists, the finding drops from
unauthenticated to authenticated remote execution** — still a Gate 4 failure on C1–C5, but no
longer a BLOCK, and my §3 argument about asymmetry between the branches weakens considerably.

**2. The Y04 filter blocking a disclaimer-tagged injection.** Send `ignore previous instructions
— disclaimed` through the live channel and show it blocked. `Test-Y04Disclaimer` at `:194–203`
reads as an unconditional bypass and `:337` falls through to Stage 3 on a match, but I did not
observe it. **If it blocks, C7 becomes PARTIAL rather than FAIL.**

**3. Platform-level sender restriction.** Evidence that Telegram is configured to refuse `/start`
from anyone but the Gardener, or that the bot username is genuinely unguessable and unlisted. **If
the platform enforces the allowlist the code does not, I move from BLOCK to PASS-WITH-CONDITIONS**
and condition 1 becomes defence-in-depth rather than the fix.

**4. A sourced, dated Zen document.** Per `seed/protocols/inquiry.md`. If it shows direct per-lab
credentials with no prompt retention by an intermediary, exposure item 4 is wrong and only item 3
survives. If it shows an aggregating proxy with retention, item 4 is worse than I stated. Either
way I move — **I currently weight the direction as unknown, not as bad.**

**5. A harness scope document with a threat model.** C13's failure is the only reason I issue no
verdict on the paths. Give me a written boundary — what the harness reimplements versus wraps, what
the permission model is, who owns the patch stream, where remote input enters relative to the
permission boundary — and I will review it. **If it puts the daemon inside the boundary, names a
maintainer, and bounds credential storage, the harness becomes the safer path and I will say so in
those words.** My position is not that a harness is unsafe; it is that an unreviewable harness
cannot be called safe, and right now there is nothing to review.

**6. Evidence that the five conditions are not cheap.** My position assumes the daemon is fixable
in one file. If someone attempts condition 2 and finds that `opencode run --agent <read-only>`
cannot produce a useful general reply — that the capability genuinely requires a write-capable
agent — then the channel's usefulness and its safety are in real tension, that tension is
architectural, and the harness argument gains its second genuine point. I have not attempted the
fixes; my charter forbids it.

---

## Concessions

- **Var's V5 and V6 are the best work in this workspace and I did not improve on them.** V6 in
  particular is the finding my §3 depends on: it establishes that the per-agent allowlist is a real
  control, which is what makes "a harness must rebuild it" a cost rather than a rhetorical point.
  My contribution is only to note the boundary V6 does not cross.

- **Var's central mechanism — numbered steps executed, prose rules ignored — is confirmed by my
  angle from a different direction.** Gate 4 is prose in `gates.md:15`. It was not applied. The
  `@agent` allowlist at `:441` is a literal array in code and it holds. Same pattern, different
  layer, independent evidence. **This strengthens Var's finding and I want it recorded as
  corroboration, not as agreement.**

- **Kvasir's dispute with the binary framing (`01:153–160`) is correct and my findings support
  it.** The daemon must be fixed under either branch. A decision procedure that forces a choice
  between two runtimes cannot express "neither, first."

- **Kvasir was right to concede that evidence item 4 is the strongest thing against its position
  and is genuinely architectural.** I add that the item cuts both ways and nobody scored the second
  edge; that is an addition to Kvasir's concession, not a correction of it.

- **My own independence is compromised and I said so in the header rather than at the end.** Seats
  02 and 03 are the same model from the same lab. My confirmation of Var's findings is worth less
  than an independent lab's would be. Var's escalation at `02:418–428` should gain a third item:
  the seat-independence property the model-assignment document claims does not hold in this
  workspace.

- **I could not test the live channel** and would not have without Gate 4 approval. Every H-row
  marked OBSERVED is a file read or a process query. H6 is marked CODE-READ and should be weighted
  accordingly.

---

**Gardener decision required.** This seat assesses exposure. It does not recommend a path, and its
BLOCK is scoped to a capability that both paths inherit — it is not a vote against either one.

# Brokkr — feasibility angle: what would a harness require to build, and what breaks on day one?

**Read before writing:** `deliberation/harness-decision/00-question.md` ·
`deliberation/harness-decision/01-kvasir-position.md` ·
`deliberation/harness-decision/02-var-critique.md` ·
`deliberation/harness-decision/03-heimdall-risk.md` · `seed/protocols/deliberation.md`.
Read to check claims and to build the estimate: `seed/adapters/_templates/README.md` ·
`seed/adapters/claude/metadata.md` · `seed/adapters/opencode/model-assignment.md` ·
`.claude/agents/*.md` (all ten, frontmatter) · `.opencode/agents/*.md` (all ten, frontmatter) ·
`.claude/settings.json` · `opencode.json` (root) · `.opencode/` (directory listing) ·
`seed/conformance/Y03-cold-resume.md` · `Y07-real-delegation.md` · `Y12-orchestrator-delegates.md` ·
`Y15-no-host-builtins.md` · `seed/memory/capabilities.md` · `roadmap/SLICES.md` ·
`prior-evidence/FINDINGS.md` (§E41) · `tools/ygg/*.ps1` (all fourteen, line counts and coupling
sites) · `tools/ygg/ygg-daemon.ps1` (`:244–280`, `:430–515`).

**Model:** claude-opus-5 · **Lab:** Anthropic
*(Read from this live session's own model statement, not from any roster document.
`seed/adapters/opencode/model-assignment.md:32` assigns brokkr `qwen3.7-plus`/Alibaba; that document
does not describe this session. **Seats 02, 03 and 04 are now all `claude-opus-5`/Anthropic.** Var's
critique, Heimdall's review of Var, and this seat's review of both are three consecutive same-model
self-checks. Heimdall flagged this at `03:18–20` and asked for it in the memo; I confirm it, and in
§4 below I name the mechanism that causes it, which Heimdall did not have.)*

---

## Verification record — what I actually ran

Everything marked **OBSERVED** was executed in this session against files in this repository.
Nothing here is a measurement of a harness, because no harness exists to measure.

| # | Check | Method | Result |
|---|---|---|---|
| B1 | Tooling size | `wc -l tools/ygg/*.ps1` | **OBSERVED** 5,740 lines across 14 scripts; largest is `ygg-daemon.ps1` at 932 |
| B2 | Host-path coupling in tooling | `grep -c '\.claude\|\.opencode' tools/ygg/*.ps1` | **OBSERVED** 13 references total, in exactly 3 of 14 files (`ygg-generate` 6, `ygg-doctor` 4, `ygg-verify` 3) |
| B3 | Host-binary coupling | `grep -rn 'opencode run\|opencode agent list'` | **OBSERVED** 5 call sites: `ygg-doctor.ps1:172`, `ygg-generate.ps1:557`, `ygg-daemon.ps1:267`, `:452`, `:506` |
| B4 | `model:` field, Claude adapter | `grep -c '^model:' .claude/agents/*.md` | **OBSERVED** **0 of 10** |
| B5 | `model:` field, OpenCode adapter | `grep -h '^model:' .opencode/agents/*.md \| uniq -c` | **OBSERVED** 5 deepseek-v4-flash, 2 glm-5.2, 1 qwen3.7-plus — 8 of 10 pinned, 3 labs |
| B6 | Permission config contradiction | read `.claude/settings.json` and root `opencode.json` | **OBSERVED** Claude **denies** `Bash(git push*)`, `git commit*`, `git reset*`, `git checkout*`; OpenCode **allows** `git commit*`, `git push*`, `git tag*`, `git branch*`, `git merge*` |
| B7 | `.opencode/opencode.json` exists | `ls -a .opencode/` | **OBSERVED** it does not. Contents: `.gitignore`, `agents/`, `command/`, `node_modules/`, `package-lock.json`, `package.json` |
| B8 | Daemon general path lacks `--agent` | read `ygg-daemon.ps1:452` and `:506` | **OBSERVED** `:452` passes `--agent $agentName`; `:506` passes `run -m opencode-go/deepseek-v4-flash` with no `--agent` |
| B9 | My own seat's write capability | this file exists | **OBSERVED** `.claude/agents/brokkr.md:4` grants `Read, Write, Edit, Glob, Grep, Bash`; row 04 of Var's table at `02:161` holds |
| B10 | Open phase count | read `roadmap/SLICES.md` | **OBSERVED** P1, P2 and P3 all `In Progress` concurrently; P0 is the only `Completed` unit |

I built nothing and fixed nothing. Per my charter and the dispatch, this is a seat, not a loop.

---

## Steelman

**Kvasir.** The four evidence items are silent on the question, the system named its own enforcement
gap and left it open, and you cannot read an architectural verdict off a configuration never run
with its own enforcement on. Kvasir also stated its own falsifiers cheaply enough that a later seat
could run them — which is exactly what happened.

**Var.** The same allowlist, same model, same host produced 0 delegations and 48. A constant cannot
explain a difference. What varies is procedural form. And the pattern is general: this project's
records of its own behaviour are asserted more often than measured, and `02:209` — "a harness would
inherit this practice unchanged" — is the sharpest sentence in the workspace. Var then ran V5 and V6
and confirmed its opponent against its own interest.

**Heimdall.** Both prior seats scoped the system as the agent layer, and the largest privilege in
the system is held by a PowerShell process that is not an agent, holds no allowlist, and invokes the
host as a subprocess. Neither remedy reaches it. The evidence set contains no security dimension at
all, so a decision taken on it alone is taken blind to what is running on the machine.

I accept all three. My angle is the one nobody has costed: **what would actually have to be
written**, and what stops working the morning after.

---

## Position

**The harness is not a greenfield build, and that is the finding. A proto-harness already exists,
is running on this machine right now, and its measured day-one state is Heimdall's eight failed
checks. `tools/ygg/ygg-daemon.ps1` is 932 lines that accept input, route it, rate-limit it, dispatch
named agents, and return output — an orchestration layer that wraps a host as its execution engine.
That is the middle path the question's binary excludes, it is already built, and the only empirical
evidence in this repository about how this project builds a harness-shaped component is that
component's security review.**

Two consequences, and they point in opposite directions, which is why I hold both.

First, **the expensive harness is far larger than either prior estimate.** Kvasir's list at
`01:136–142` names six components. Var's scoping request at `02:277–280` names the same six. I
enumerate below what is missing from that list, and it is not marginal: it omits the tool
implementations themselves, the agent loader and its validator, the non-interactive CLI surface that
the currently-active phase depends on, and the maintenance stream. **A build boundary that omits
four categories is not a low estimate; it is an estimate of a different thing.**

Second, **the cheap harness is 80% written and would keep the host's enforcement.** `:452` already
dispatches `opencode run --agent skuld` with the host's per-agent allowlist intact — the same
control Var demonstrated at V6. An orchestrator that shells one host invocation per seat gets Layer
D free, forever, from a vendor. It is the only design in this record that buys harness-shaped
control without paying for a runtime.

### 1. The build boundary Var asked for — corrected and completed

Var's `02:277–280` asked for "a written boundary — which of tool loop, permission enforcement,
subagent isolation, context management, session persistence, and per-agent allowlists the harness
reimplements versus wraps." Here it is, in the only structure the repository supplies for judging a
soil: `seed/adapters/_templates/README.md:33–44`, the eight profiling questions. **A soil is
*profiled* by answering those eight. A harness must *implement* all eight.** That is the difference
nobody in this record has stated.

| Layer | Component | Wrappable? | Evidence it is required |
|---|---|---|---|
| **A** | Model access — provider clients, auth, streaming, retry, token accounting | **Yes** — this is the layer an aggregator sells | `model-assignment.md:21–32`, three labs today |
| **B** | Agent loop — tool-call parse/dispatch, multi-turn state, result marshalling, error recovery, interrupt, turn limits | **No** | every session in this repo |
| **C** | **Tool implementations — 7 distinct tools** | **No** | `.claude/agents/*.md:4` names `Read, Write, Edit, Glob, Grep, Bash, Agent, Task` |
| **D** | Permission engine — per-agent allowlist, `permissionMode`, command-pattern matcher, approval UX | **No** | V6 (Var); `permissionMode: plan` on 3 agents; 10 deny rules in `.claude/settings.json` |
| **E** | Subagent isolation — separate context per seat, nested dispatch | **No** | `metadata.md:14`; Y07's tier test |
| **F** | Session — persistence, resume, compaction/context budget | **Partly** — see concession | Y03 |
| **G** | **Agent loader + validator** — directory scan, frontmatter parse, `agent list`/`doctor` equivalent | **No** | `_templates/README.md:68–73`; B3 (2 call sites depend on it) |
| **H** | **Surfaces — interactive UI *and* non-interactive `run -m <model> --agent <name>`** | **No** | B3, B8 — P3 presence depends on it at 3 call sites |
| **I** | **Slash-command layer** — `/loop`, `/thing` | **No** | `seed/adapters/*/command*/` |
| **J** | **Maintenance stream** — patches, OS support, provider API drift | **No** | `03:148–152` |

**Layers C, G, H, I and J appear on no prior seat's list.** Kvasir's six map to B, D, E, F, and A.
Layer C alone is seven tools, and each carries semantics the seed already depends on without having
written them down: `Edit` refuses to fire unless the file was read first and refuses ambiguous
matches — that is a *safety control* the seed inherits free and has never had to specify. `Read`
paginates, line-numbers, and handles PDFs and notebooks. `Grep` is a ripgrep integration with three
output modes. `Bash` supplies timeouts, output truncation, and background execution. **The seed's
agents are written against these behaviours and none of them is documented in the seed.** A harness
does not reimplement a tool list; it reimplements a tool list *whose contract is unwritten*.

**Build cost: unknown, per `00-question.md:47`, and I will not invent a figure.** What I will state
is the shape of the unknown: **the project has never shipped any one of the ten categories above.**
B1 measures the entire tooling estate at 5,740 lines across 14 scripts, all of them PowerShell
utilities that read files, check patterns, and print results. The largest single artifact is the
daemon at 932 lines. Layers B, C, D, E, G and H are each a different *kind* of software from
everything in `tools/`. That is not an argument that it cannot be done. It is a statement that this
repository contains **zero** evidence of the capacity, and B10 shows three phases open concurrently
with one completed since the project began.

### 2. What breaks on day one — the standalone harness

Eight items, each observed, in the order they would surface.

1. **All twenty agent files stop applying.** Both adapters target host formats (`_templates/README.md:15–20`
   tabulates four incompatible format axes). The harness needs an eleventh adapter, which means the
   full checklist steps 1–6. *Cost: genuinely low* — `ygg-generate.ps1` is 785 lines of exactly this
   pipeline. **This is the one thing that is cheap, and it is the thing that looks expensive.**

2. **Step 4 of the checklist cannot run.** `_templates/README.md:68–73` — "Run `verify_cmd`; **zero
   errors** required. A file that does not load is a file that does not exist." A harness has no
   `verify_cmd` until Layer G ships. `ygg-doctor.ps1:172` and `ygg-generate.ps1:557` both call
   `opencode agent list` as their truth oracle (B3); on a harness these have no implementation.
   Precedent for what happens next is on disk: `metadata.md:37` records the Claude validation as
   **NOT RUN** and the tier certified anyway.

3. **P3 presence stops.** `ygg-daemon.ps1:267`, `:452` and `:506` hard-code
   `opencode run -m opencode-go/deepseek-v4-flash` (B3, B8). Presence is the *currently active
   phase* (`SLICES.md`, B10). Three call sites, but the requirement behind them is a whole CLI
   contract — headless invocation, model selection flag, agent selection flag, stdin prompt piping,
   exit codes.

4. **Every conformance transcript and both tier classifications become non-evidence.**
   `metadata.md:41` classifies Tier 1 "*because* per-agent tool allowlists are structurally enforced
   by the host." That is a property of the host, not of the seed. A harness starts **unclassified**
   and must earn Tier 1 by passing Y07 — including the permission-asymmetry probe, which is the
   thing Var's V6 proved for the host and which a harness would have to prove for itself against
   code it wrote.

5. **Y15 becomes vacuous and one control silently disappears.** `Y15-no-host-builtins.md` exists
   because hosts ship built-in agents that must never be invoked. A harness has none, so Y15 passes
   trivially — and the conformance count goes *up* while the system is tested *less*. This is the
   assertion pattern Var identified, arriving through a side door.

6. **Both permission configs stop being enforced, and they already contradict each other.** B6:
   `.claude/settings.json` denies `Bash(git push*)`, `git commit*`, `git reset*`, `git checkout*`;
   root `opencode.json` **allows** `git commit*`, `git push*`, `git tag*`, `git branch*`,
   `git merge*`. `_templates/README.md:54–55` requires the config template be "in Mode B shape
   (read-only version control allowed; all state-changing version control denied)." **The OpenCode
   config violates the seed's own stated permission contract today.** A harness transcribing "the
   current permission model" inherits whichever file the author opens. *(`opencode.json` also places
   `"git *": "deny"` after the specific allows and before a global `"*": "allow"`; whether
   `git reset --hard` is denied depends on OpenCode's match-order semantics, which I did **not**
   verify.)*

7. **`permissionMode: plan` has no equivalent.** Three agents carry it — skuld, verdandi, huginn.
   Var's §2 already shows this field is load-bearing for who can write what.

8. **`.opencode/opencode.json` does not exist (B7).** Heimdall's H3 cites that path; the file it
   describes is root `opencode.json`, and **the content Heimdall reported is exactly right** —
   `edit: allow`, `git push*: allow`, `*: allow`. The finding stands entirely; only the path is
   wrong. I record it in the same spirit Var corrected Kvasir's OpenCode/Claude citation at
   `02:112–116`: a reader should not accept the citation as offered, and the conclusion survives.

### 3. What breaks on day one — the seed path

Shorter, because Var and Heimdall enumerated most of it. Two additions from my angle.

**Nothing new breaks, but the "six text edits" figure has now grown twice.** Heimdall added the Gate
4 conditions to Var's list at `03:286–291`. I add: `ygg-generate.ps1` is the file that *produces*
adapters, and the two malformed agent files (E41) were written **around** it, inline. Fixing the two
files without fixing the generator's usage means the next generated adapter can reproduce the
defect. That is one more item, and it is a script change rather than a text edit.

**B9 is one datum for Var's prediction.** Var predicted at `02:172–175` that seats 05 and the memo
would be produced by a substitute, the orchestrator, or not at all, and staked its §2 on it. My row
in that table (04, `Read, Write, Edit, Glob, Grep, Bash`, "Yes") is confirmed: I hold Write and used
it. The rows that matter are still open.

### 4. The mechanism behind the independence failure — new, and it changes what evidence item 4 means

Heimdall observed (`03:18–20`) that seats 02 and 03 are the same model and lab, called it "a
**worse** independence position than the one on paper," and asked for it in the memo. I confirm it,
extend it to seat 03 → 04, and name the cause:

**B4: zero of ten Claude agent files carry a `model:` field. B5: eight of ten OpenCode agent files
do, across three labs.**

`seed/adapters/claude/metadata.md:16` documents the field as fully supported on this host —
"String alias (`sonnet`, `opus`, `haiku`, `fable`) or full model ID (`claude-opus-5`). Default is
`inherit`." **The adapter omitted it, so every seat on this soil inherits one model from one lab,
and multi-lab independence — the property `tier-routing.md` and `model-assignment.md` are built
around — is unexpressible on the soil this deliberation actually ran on.**

This matters for evidence item 4 in a way no seat has stated. The debate is whether eleven labs beat
six (Kvasir) or three (Var, `02:216`). **The adapter in use for this deliberation can express one.**
The gap between one and three is a missing frontmatter line in ten files, on a host that documents
the field. The gap between three and eleven is a harness.

This is structurally identical to Kvasir's Position point 1 — a documented lever, unpulled — and I
found it independently, at a different layer, without having set out to look for it. **I want it
recorded as corroboration of Var's mechanism rather than as agreement with Kvasir's conclusion**, in
the same terms Heimdall used at `03:356–359`: prose said "review must come from a different lab"
(`model-assignment.md:44`); the field that would enforce it is absent; the prose did not hold. Same
pattern, third layer, third independent instance.

### 5. What the harness would genuinely buy, that I can verify

One item, and it is not on any prior seat's list.

`seed/memory/capabilities.md:7` records mitigation M5 for the web-search connector as "behavioural
(**per-agent path scoping not available on this host**)." That is a named, registered, in-repository
admission of a control the host cannot supply and the seed wanted. A harness owning the tool layer
could scope filesystem paths per agent by construction. **This is the first concrete instance in the
record of a capability the seed asked for and the host refused** — it is what Kvasir's falsifier 4
asks for in kind, though not in force, since M5 was accepted as behavioural rather than shown to
have failed.

I do not think it is sufficient. It is one mitigation on one connector, downgraded rather than
lost. But it is real, it is registered, and it belongs in the memo, because every other harness
benefit in this record is either unverifiable (Zen) or achievable by editing a file.

### 6. Cost and what each path buys — to `00-question.md:47`

**Continue as a seed.** Build cost: Var's six edits, plus Heimdall's five daemon conditions, plus
the generator fix in §3, plus ten `model:` lines to make multi-lab seating real. All bounded, all
enumerable, all in files that exist. Recurring: $60/month, corroborated at `model-assignment.md:9–15`.
Forecloses: per-agent path scoping (M5), simultaneous seats, live shared workspace.

**Rebuild as a standalone harness.** Build cost: **unknown**, over the ten layers in §1, of which
this project has shipped none. Recurring: **unknown** for models; **unknown and never-ending** for
Layer J, and no maintainer is named. Buys: per-agent path scoping, per-seat lab binding at whatever
count the pool supports, remote input inside the permission boundary. Forecloses: Layer D free from
a vendor, and Layer J entirely.

**The third path — orchestrator over hosts.** Build cost: **unknown, but bounded below by something
that exists.** `ygg-daemon.ps1` is 932 lines and already performs dispatch, routing, rate limiting,
per-agent invocation with `--agent` (`:452`), and result return. Recurring: $60/month, unchanged.
Buys: seat-level model choice across every host installed, deliberation dispatch that does not
depend on one host's Agent tool, and Layer D **retained** because each seat still runs inside a
host. Forecloses: nothing currently held. **Costs, honestly:** it inherits the daemon's eight failed
checks unless they are fixed first, and it cannot supply M5 either.

**Cost of deciding now, from my angle:** the decision would be taken with no written scope for the
option being considered, against a project with three phases open and one closed.

---

## Where I disagree

**1. With Heimdall, `03:180–181`** — "That is a genuine architectural argument for the harness and
it is the first one in this record that is about architecture rather than discipline."

**This is my named disagreement, and I make it against the seat whose findings I otherwise rate
highest.** Heimdall refutes itself nine lines later at `03:183–186`: "It is also achievable without
a harness, for far less: route the general path through `--agent <read-only-agent>` exactly as
`:436–453` already does for the `@` path. The mechanism to fix it is nine lines away from the
defect, in the same file." I verified both sites (B8): `:452` passes `--agent $agentName`, `:506`
does not.

**An argument whose remedy is one flag on one line, in a file that already contains the working
version of that line, is a discipline argument wearing architecture's clothes.** Heimdall applied
its own strictest standard to Kvasir and Var — that an unpulled lever is not an architectural
finding — and then exempted its own. The correct reading is the one Heimdall's §2 corroboration
already supports: `--agent` at `:452` is a literal flag in code and it holds; the general path at
`:506` omits it and does not. **Same pattern, same file, nineteen lines apart.** That is the third
instance of Var's mechanism, not the first architectural argument.

The genuinely architectural item in Heimdall's file is elsewhere and unremarked: **M5**, §5 above.

**2. With Kvasir, `01:136–142`**, the harness build-cost paragraph. Kvasir writes "It is not zero
and it is not small" and lists six components. §1 shows the list omits Layers C, G, H, I and J. **A
qualitative hedge attached to an incomplete enumeration reads as caution and functions as an
underestimate**, because the reader prices the six named things. Kvasir was right to refuse a
number; it should also have refused a list it had not checked against the adapter checklist, which
is the repository's own specification of what a soil must supply.

**3. With Var, `02:277–280`**, which repeats Kvasir's six as the scoping request. Var caught that
nobody had written down what a harness would contain and assigned it to this seat — correctly. But
the request inherits the same six categories from the position it was critiquing. **The list to
scope against is `_templates/README.md:33–44`, which is in the repository and which neither seat
cited in this connection.** Var's own standard — that the missing evidence was mostly not missing —
applies here.

**4. With `00-question.md:13–14`**, the binary, on a ground neither Kvasir nor Var used. Kvasir
disputes it conceptually (`01:153–160`, soils not competitors); Var disputes it as a category error
(`02:333–339`). **I dispute it empirically: the third option is running on this machine right now.**
`ygg-daemon.ps1` wraps a host as an execution engine and dispatches named agents into it. A question
that offers "rebuild as a harness" or "continue as a seed" has no cell for "the thing we already
built," which is why its risk profile has gone unpriced for 932 lines and eight failed checks.

**5. With myself.** Every cost in §1 is a decomposition, not a measurement. I have not built a
harness, prototyped one, or timed any layer. Var set this workspace's bar by running V5 and V6
rather than inferring them; Heimdall marked H6 CODE-READ rather than let a table imply otherwise. By
that bar **my §1 is inference throughout, and it is the weakest kind of evidence in this
workspace.** The one thing I did not have to infer is that the ten categories are required, because
`_templates/README.md` requires them of every soil.

---

## What would change my mind

**1. A harness scope document that wraps rather than reimplements.** If the proposed harness drives
`claude -p --agent <name>` or `opencode run --agent <name>` per seat rather than implementing Layers
B–E, my cost estimate collapses by most of its mass and I move to supporting it. **Concrete test,
runnable this week with no new code:** drive one full loop by shelling one host invocation per seat,
then check the transcript shows each seat's allowlist held — give `skuld` a write instruction and
confirm refusal, exactly as Var's V6 did in-process. If that works, the expensive harness is
unnecessary *and* the cheap one is largely built. **This is my proposed cheap experiment for
`00-question.md:52`, and it tests the option the question does not contain.**

**2. The same test failing.** If per-seat host invocation loses something that cannot cross a
process boundary — accumulated context, interrupt handling, the ability for a seat to see a prior
seat's live state — then the middle path is closed, the choice really is binary, and the
architectural argument becomes real. **This is the falsifier I most want run, because it is the one
that would move me toward the harness.**

**3. `model:` added to the ten Claude agent files and silently ignored.** B4/B5 plus
`metadata.md:16` say per-seat lab binding is one line per file. Add `model:` to two agents, restart,
dispatch both, and read which model answers. **If the field is ignored or the agents fail to load,
per-seat lab independence really is host-limited on this soil**, evidence item 4 gains its first
support that is not stipulated, and my §4 is wrong. Cost: two lines and a restart.

**4. Any one of Layers B, C, D, E, G or H shipped and working, in bounded time.** My capacity
argument is an inference from B1 and B10 — a tooling estate of file-checking scripts and one
completed phase. Demonstrate a working permission engine with per-agent allowlists, or four of the
seven tools with the semantics the agents assume, and the inference is refuted by construction.
I would rather be refuted this way than argued with.

**5. A sourced, dated Zen document showing an SDK, not just an API.** Every seat has asked for
pricing and lab count. I ask for something different and more decisive for my angle: **does it
supply the tool loop and the permission engine, or only model access?** If Layers B and D are
purchasable rather than buildable, §1's estimate changes by most of its weight. If it is a model
gateway only, it touches Layer A alone and changes nothing I have written.

**6. Evidence that the daemon is not representative.** My §1 and Heimdall's `03:144–146` both use
`ygg-daemon.ps1` as the sample of what this project's unreviewed infrastructure code looks like. If
it was written under acknowledged time pressure — as E41 records for the two malformed agent files,
"the 2.8 execution session where speed was prioritized over template compliance" — and a reviewed
component of comparable risk exists and is clean, the proxy weakens and my §1 conclusion should be
discounted. **I looked for such a component and found the L1/L2 capability gates
(`ygg-gate-l1.ps1`, 567 lines; `ygg-gate-l2.ps1`, 538) — which are the pipeline the daemon bypassed
entirely (Heimdall H4). I do not know whether they were reviewed. I did not read them.**

---

## Concessions

- **Heimdall's central finding is the most important thing in this workspace and my angle
  strengthens it.** A harness must write Layer D itself, and the only sample of this project's
  unreviewed security engineering failed 8 of 13 checks in the very deliberation convened to decide
  whether to write more of it. `03:144–146` states this; my §1 supplies the size of what would be
  written under those conditions.

- **Heimdall's asymmetry argument against Var's `02:339` is correct and I add a measure to it.** The
  branches are not symmetric. B6 shows the seed path retains a permission config that is at least
  *partly* correct on one host; the harness path deletes both configs and rewrites the matcher that
  reads them.

- **Var's V5 and V6 are the best work here and I did not improve on them.** V6 is what makes Layer D
  a cost rather than a rhetorical point, and B9 is only a small confirmation of one row of Var's
  table.

- **Var's §1 is right and my §4 is the same finding at a third layer.** I did not set out to look
  for it, which is the only reason I think it is worth recording as independent.

- **Kvasir's dispute with the binary framing is correct, and my §4 disagreement upgrades it rather
  than corrects it.** Kvasir argued the exclusivity is conceptually wrong; the daemon shows it is
  factually wrong. Kvasir wrote first and blind and could not have run B3 or B8.

- **A concession that cuts toward the harness, on Layer F.** Session persistence is a *smaller*
  harness burden than my component list implies, and I should say so plainly. `Y03-cold-resume.md`
  requires resume from files alone — "It reconciles from files, names the correct active unit and
  the correct next unfinished task." The seed already carries its own memory in the filesystem by
  design. A harness could ship with near-zero session persistence and still pass Y03. **One of my
  ten layers is mostly free, and it happens to be one of the six that Kvasir and Var both named.**

- **Layer C's difficulty may be overstated by me and I cannot check it.** I know the tool semantics
  the agents depend on because I hold those tools; I do not know how much of that behaviour is
  actually load-bearing for the seed as opposed to convenient. A harness might ship crude tools and
  work fine. Falsifier 4 is the honest test.

- **I could not price anything.** Every figure in this file that matters is "unknown," and I have
  left it there. `00-question.md:47` asks for that and it is the only requirement I met without
  effort.

---

**Gardener decision required.** This seat estimates what a build would contain and what stops
working. It does not recommend a path, and it built nothing.

# Memo — harness or seed

**Written by:** verdandi (loop controller), synthesising from the record under
`seed/protocols/deliberation.md` rule 7: "The memo is written from the record. Verdandi reads every
file and synthesises. Dissent is quoted from the actual critique, not paraphrased. The memo names
the seat composition and the lab of each seat."

**Read before writing:** `00-question.md` · `01-kvasir-position.md` · `02-var-critique.md` ·
`03-heimdall-risk.md` · `04-brokkr-feasibility.md` · `05-kvasir-response.md` ·
`seed/protocols/deliberation.md` · `seed/constitution/gates.md` ·
`seed/adapters/opencode/model-assignment.md` · `seed/adapters/claude/metadata.md`. Every seat file
was read in full and in order. No file was summarised to me.

**Model:** claude-opus-5 · **Lab:** Anthropic
*(Read from this live session's own identity statement, not from a roster document.)*

**This memo does not decide.** It synthesises. Per `00-question.md:57–58` it contains no
recommendation and ends with the required line.

---

## 0. Authorship of this memo — recorded first, because it is evidence

This seat holds `tools: Read, Glob, Grep`. **The Write tool is not available to it, and it did not
write this file.** The text was returned to the dispatching seat for transcription.

That resolves the one prediction a seat staked publicly. Var, `02-var-critique.md:172–175`:

> **This yields a prediction, testable inside this workspace before it closes:** seats 05 and the memo
> will be produced by a substitute, or by the orchestrator, or not at all. If any of those happens,
> `deliberation.md` is not executable as written on this soil. If a genuine `kvasir` and a genuine
> `verdandi` write those two files, I am wrong about this and will say so.

Both halves resolved against Var's own hoped-for outcome and in favour of Var's §2. Seat 05 was
written by a substitute (`05-kvasir-response.md:21`, `:349–350`). The memo was not written by its
assigned seat. Var's §2 stands as stated at `02-var-critique.md:165–166`:

> **Three of the six required artifacts cannot be produced by the seat the protocol assigns them to,
> including the memo.**

Var's escalation item 2 (`02-var-critique.md:425–428`) is therefore live and unresolved: someone
must decide whether `verdandi` and `kvasir` are granted `Write`, or whether substitution is
accepted. Under `deliberation.md:69` — "A deliberation without its directory did not happen" — the
directory exists, but two of its six files were produced by seats other than the ones the protocol
names.

This is a finding about the seed's protocol/adapter fit. **It is not a finding about the runtime**:
the host enforced exactly the allowlist the seed wrote into the agent file, which is the same
control Var demonstrated at V6.

---

## 1. Seat composition, models, and labs

Every seat stated its model and lab from its own live session identity. All five state the same
pair. Both roster documents state something different, and neither describes this run.

| # | Seat chartered | Seat actually occupied by | Model stated in the file | Lab | Substituted? |
|---|---|---|---|---|---|
| 01 | kvasir (architect) | **muninn** (memory keeper) | `claude-opus-5` (`01:11`) | Anthropic | **Yes — disclosed** (`01:18–30`) |
| 02 | var (validation) | var | `claude-opus-5` (`02:12`) | Anthropic | No (`02:13–16`) |
| 03 | heimdall (security) | heimdall | `claude-opus-5` (`03:14`) | Anthropic | No |
| 04 | brokkr (builder) | brokkr | `claude-opus-5` (`04:16`) | Anthropic | No |
| 05 | kvasir (architect) | **muninn** (memory keeper) | `claude-opus-5` (`05:14`) | Anthropic | **Yes — disclosed** (`05:19–30`) |
| — | verdandi (memo) | verdandi | `claude-opus-5` (this session) | Anthropic | No — but see §0: could not write |

**No seat's model or lab is undetermined.** All six are `claude-opus-5` / Anthropic.

**The roster documents disagree with the run, and the mechanism is known.**
`seed/adapters/opencode/model-assignment.md:25–34` assigns var and heimdall `glm-5.2` (Zhipu),
brokkr `qwen3.7-plus` (Alibaba), muninn and verdandi `deepseek-v4-flash` (DeepSeek), and kvasir
"(unassigned — invoked rarely, assign per session)". That document describes the **OpenCode** soil.
This deliberation ran on the **Claude Code** soil, whose metadata (`seed/adapters/claude/metadata.md`)
records no per-agent model assignment at all; its only model statement is `:67`, "**Reviewer:**
Claude Code (Opus 5)". Brokkr measured the cause (B4, `04:36`) and Kvasir confirmed it independently
(K2, `05:55`): **zero of ten Claude agent files carry a `model:` field**, and
`seed/adapters/claude/metadata.md:16` records the default as `inherit`. Every seat therefore
inherited one model from one lab.

**Consequence, raised by three seats and requested in the memo by all three.** Heimdall,
`03-heimdall-risk.md:18–20`:

> The var/heimdall same-lab compromise Kvasir cites at `01:113–115` and
> Var re-cites at `02:275` does **not** hold for this workspace — seats 02 and 03 are both
> `claude-opus-5`/Anthropic, which is a **worse** independence position than the one on paper, and
> the memo should record it. My review of Var's findings is a same-model self-check.

Brokkr extended it (`04:19–22`): "**Seats 02, 03 and 04 are now all `claude-opus-5`/Anthropic.** Var's
critique, Heimdall's review of Var, and this seat's review of both are three consecutive same-model
self-checks." Kvasir closed it (`05:430–433`): "**Every seat's independence claim in this workspace is
void.** Seats 02, 03, 04 and 05 are one model from one lab; 01 and 05 are substituted. […] I am the
fourth same-lab reviewer of the first same-lab reviewer, and my confirmation of anything here is
worth correspondingly less."

**The memo seat is the fifth.** This synthesis is same-model with every seat it synthesises.

**Reason the architect's seat is empty**, per `01:20–26` and `05:21–24`: the Agent tool in this
runtime does not expose a `kvasir` subagent type. Two independent defects were identified in the one
file: a 24-line template comment block before the frontmatter (`01:76–86`; mechanism confirmed
experimentally by Var's V5, `02:31`), and `tools: Read, Glob, Grep`, which would leave the seat
unable to write its artifact even once loadable (Var's V6, `02:32`; confirmed by Kvasir's K1,
`05:54`). Seat 05 also records that it "was dispatched fresh and do[es] not carry seat 01's context"
(`05:25`).

**Consequence for `deliberation.md:161–165`.** Kvasir, `05:302–308`:

> **seats 01 and 05 are substituted, and seats 02, 03, 04 and 05 are all `claude-opus-5`
> from Anthropic.** One deliberation, five seats, one lab, two substitutions. Whatever this workspace
> shows about file-based exchange, it shows under a confound that `deliberation.md:161–165` does not
> contemplate. **This deliberation should not be counted as one of the three trials.**

And the honest other half, same file, `05:310–315`: "on the substance, this exchange met the
protocol's 'substantive' test. Critics quoted lines and ran experiments against them. Two of my four
load-bearing claims were refuted by work done inside the deliberation. Three of four seats conceded
materially against their own angle. That is not monologues stapled together, and the memo should say
so — while recording that it happened at n=1, on one lab, with the proposer's seat empty."

The memo says so, and records both halves.

---

## 2. Requirement 1 — the named disagreements, quoted verbatim

`00-question.md:36–38` requires at least one point where two seats hold incompatible views, quoted
and not smoothed. **The record contains four. None is smoothed here.**

### Disagreement A — are the two branches symmetric? (Heimdall vs Var; Kvasir adjudicates for Heimdall)

Var, `02-var-critique.md:338–339`:

> Choosing a runtime to fix that is a category error, and it is the same
> error whichever branch is chosen.

Heimdall, `03-heimdall-risk.md:269–278`, citing it as `02:339`:

> The first clause is right and I adopt it. **The second clause is false, and this is my named
> disagreement for the memo.** The two branches are not symmetric. The seed branch leaves in place a
> per-agent tool allowlist that Var itself demonstrated working (V6) and a vendor patch stream that
> arrives whether or not anyone runs a check. The harness branch **deletes both and rebuilds them by
> hand**. Var's own strongest finding — that this project's records of its own behaviour are asserted
> rather than measured — is precisely the reason the harness branch is worse than the seed branch and
> not merely equal to it. A practice that does not run its checks should not be given custody of its
> own permission engine. Var reached the symmetric conclusion because it scoped the failure as a
> documentation failure; §1 above shows the same practice has already produced an executable failure,
> and executable failures do not stay symmetric when you move the enforcement boundary.

Kvasir sides with Heimdall and adds a reason neither seat gave, `05-kvasir-response.md:278–286`:

> The asymmetry is not just that the harness deletes a working control and a vendor patch stream. It
> is that **the seed path's entire defect inventory is composed of artifacts that exist and can be
> diffed, and the harness path's is composed of artifacts that do not exist and therefore cannot be
> checked by anyone — including by the practice that is not running checks.** […] Assertion
> applied to a permission engine produces a control that reports success and does not hold, and there
> is no file to open. The same practice has strictly worse consequences on the harness branch.

**Status: unresolved.** Var had no opportunity to answer; the protocol gives the response file to the
proposer only. Var's sentence stands unretracted in the record and two later seats hold it false.
Note that both sides of A agree on Var's antecedent clause — the category-error diagnosis — and
differ only on its consequence.

### Disagreement B — is the permission-boundary argument architectural or disciplinary? (Brokkr vs Heimdall; Kvasir adjudicates for Heimdall, then holds against Heimdall on force)

Heimdall, `03-heimdall-risk.md:180–181`:

> That is a genuine architectural argument for the harness and it is the first one in
> this record that is about architecture rather than discipline.

Brokkr, `04-brokkr-feasibility.md:279–280` and `:286–292`:

> **This is my named disagreement, and I make it against the seat whose findings I otherwise rate
> highest.**

> **An argument whose remedy is one flag on one line, in a file that already contains the working
> version of that line, is a discipline argument wearing architecture's clothes.** Heimdall applied
> its own strictest standard to Kvasir and Var — that an unpulled lever is not an architectural
> finding — and then exempted its own. […] **Same pattern, same file, nineteen lines apart.** That is the third
> instance of Var's mechanism, not the first architectural argument.

Kvasir, `05-kvasir-response.md:239` ("**1. With Brokkr, `04:286–288`. This is my named disagreement
for the memo.**"), then `:244–245` and `:254–257`:

> I verified the underlying facts and they are exactly as Brokkr states (K3). The inference does not
> follow. **Brokkr refuted the instance and reported it as a refutation of the class.**

> The class-level statement is: **anything the seed runs as a subprocess is outside the host's
> enforcement by construction, and the host cannot be made to cover it.** That is architectural in
> form. Heimdall was entitled to say so, and `03:180–181` is the only sentence in this workspace that
> identifies a property of the boundary rather than a property of a file.

And immediately against Heimdall, `05:259`:

> Where I hold against Heimdall, and with my own standard rather than Brokkr's: **it is not binding.**

Kvasir also charges Brokkr with the asymmetry Brokkr charged Heimdall with, `05:267–271`: Brokkr
"correctly identifies M5 as architectural precisely because it is *registered as a limitation with no
available remedy* — and then denies Heimdall's finding the same treatment on the grounds that a
remedy exists. Those are the same test producing opposite verdicts."

**Status: unresolved, and it is the sharpest three-way in the record.** Brokkr says discipline;
Heimdall says architecture; Kvasir says architectural in form, latent in force. All three agree the
*instance* remedy is one `--agent` flag on `ygg-daemon.ps1:506` (verified by Brokkr B8, `04:40`, and
Kvasir K3, `05:56`).

### Disagreement C — what mechanism explains the delegation counts, and therefore what fixes it (Var vs Kvasir; partly conceded, residue live)

Var, `02-var-critique.md:300–302`:

> **1. With `01:68`** — "Evidence item 1 … is the predicted output of that configuration." Verified
> false as an explanation: `ses_0647` ran the identical configuration and delegated 48 times (V1–V4).
> The allowlist is constant across the two observations it is offered to explain.

Kvasir withdrew the sentence without reservation (`05:104–108`, `05:386–387`). What it did **not**
withdraw, `05:139–147`:

> Var's mechanism — numbered `INVOKE` steps are executed, prose paragraphs are not — is, on the
> evidence, better than mine at explaining the *variance* between the two sessions. I accept it. But
> notice what Var's remedy is: **rewrite the prose rule at `odin.md:124` as a numbered procedure.**
> That is a better-drafted prose rule. It has the same enforcement status as the rule it replaces,
> which is none. It works by being followed.
>
> E18 is recorded at `seed/memory/provenance.md:58` as having occurred **three times**, and the
> recorded fix for the third occurrence was to add a sentence. Var's remedy is the fourth sentence.
> Mine is the first thing in the sequence that does not require anybody to comply with anything.

Kvasir's own summary table (`05:151–154`) records the two as complementary rather than rival: Var's
procedural form explains **why it happened** and not why nothing stopped it; Kvasir's permission
explains **why nothing stopped it** and not why it happened. Both cells are execution findings.

**And Kvasir added a third candidate mechanism**, `05:288–295`:

> **3. With Var's mechanism, partially — a confound I found and Var could not have looked for.**
>
> K5: at `session-ses_0647.md:1815` the Gardener's turn ends *"Invoke muninn."* Explicitly, by name.
> So at least some of the 48 invocations in the high-delegation session followed a direct instruction
> naming the agent, and the contrast with `ses_062b` may be *instruction specificity* rather than
> *numbered procedural form*. These predict differently: under Var's mechanism, converting
> `odin.md:124` to numbered steps fixes the ad-hoc case; under mine, it does not, because what worked
> was the Gardener saying the name.

Kvasir marks this weak and single-instance (`05:61–64`, `05:297–298`). **Status: mechanism contested,
verdict convergent.** All five seats place the limit in execution, not architecture (§5). The three
candidate mechanisms predict different remedies, and no experiment in the record has yet separated
them.

### Disagreement D — with the question's own framing (all four angles, on four different grounds)

Every seat disputes the exclusivity of `00-question.md:13–14`, and no two on the same ground:

- **Kvasir, conceptually** (`01:153–160`): runtimes are "candidate **soils**, not competitors" per
  `FINDINGS.md §X8`; the binary "invites a decision larger than the evidence supports."
- **Var, as a category error** (`02:333–339`): "**the question asks which runtime to run on, when the
  observed failures are failures to run the checks.**"
- **Heimdall, on the evidence set** (`03:294–297`): "**4. With `00-question.md:18–26`, the evidence
  set.** Four items, all about delegation counts and model pools; none about exposure. The evidence
  frame contains no security dimension at all, so a decision taken on it alone is taken blind to the
  thing that is actually running on the machine."
- **Brokkr, empirically** (`04:310–315`): "**I dispute it empirically: the third option is running on
  this machine right now.** `ygg-daemon.ps1` wraps a host as an execution engine and dispatches named
  agents into it. A question that offers 'rebuild as a harness' or 'continue as a seed' has no cell
  for 'the thing we already built,' which is why its risk profile has gone unpriced for 932 lines and
  eight failed checks."

Kvasir accepted Brokkr's version as superior to its own (`05:419–422`) and accepted the third path as
live (`05:225–228`). **Status: unanimous against the binary, on four independent grounds. The record
contains no seat defending the exclusivity.** `00-question.md` was written by odin and explicitly
takes no position (`00:6–7`), so this is a disagreement with the frame, not with a seat.

### Secondary disagreements, recorded because they change the numbers

- **Heimdall vs Var on the price of the seed path**, `03:286–291`: Var's "six text edits" is "right
  about what it covers and incomplete about what it omits […] But 'six text edits' will be read by
  the Gardener as the price of the seed path, and it is not."
- **Heimdall vs Kvasir on the cost table**, `03:280–284`: Kvasir's forecloses line "lists what a path
  forecloses and not what it leaves running," which "is incomplete in the direction that matters."
- **Brokkr vs Kvasir on the harness component list**, `04:296–299`: "**A qualitative hedge attached to
  an incomplete enumeration reads as caution and functions as an underestimate**, because the reader
  prices the six named things."
- **Brokkr vs Var on the scoping list**, `04:304–308`: Var's scoping request "inherits the same six
  categories from the position it was critiquing. **The list to scope against is
  `_templates/README.md:33–44` […] which neither seat cited in this connection.**"
- **Brokkr vs Heimdall on a citation**, `04:184–188`: `.opencode/opencode.json` does not exist (B7);
  the file Heimdall described is root `opencode.json`, and "**the content Heimdall reported is exactly
  right** […] The finding stands entirely; only the path is wrong."
- **Var vs Kvasir on a citation**, `02:112–116`: Kvasir argued from `.claude/agents/odin.md:4` to
  explain a session that ran on OpenCode; "the conclusion survives — but a reader should not accept
  the citation as offered."

**Kvasir's four withdrawals** (`05:99–129`) are recorded so the memo is not read as preserving
positions their author abandoned: `01:68` withdrawn as written; falsifier 1's architectural branch
withdrawn; the "six labs" reasoning withdrawn, together with the self-caught falsity of `01:147`
("**My own disclaimer was false about my own file**", `05:123`); falsifier 2 withdrawn as sufficient.

---

## 3. Requirement 2 — the falsifier for each position

`00-question.md:40–42`: "Every seat states what evidence would move it. A position without a stated
falsifier is a preference and is to be labelled as one in the memo."

**Every seat stated falsifiers. No position in this record is to be labelled a preference.** Counts:
Kvasir seat 01, five; Var, six; Heimdall, six; Brokkr, six; Kvasir seat 05, seven (one replaced, two
repaired, one already resolved, two new, one — the seventh — aimed against its own verdict).

Falsifiers already resolved inside the deliberation, which is the strongest evidence that this was an
exchange rather than five monologues:

| Falsifier | Resolved by | Outcome |
|---|---|---|
| Kvasir 01 #2 — malformed frontmatter blocks agent load | Var V5 (`02:31`), scratch-directory probe | **Confirmed** — the 24-comment-line twin did not load. Kvasir was right, and right for the stated reason (`02:70–74`) |
| Kvasir 01 #2 as a *sufficient* remedy | Var V6 (`02:32`) | **Refuted** — a loadable kvasir still holds `Read, Glob, Grep` and still cannot write. Withdrawn at `05:126–129` |
| Var #3 — would a genuine kvasir/verdandi write seat 05 and the memo? | this workspace | **Resolved against Var's hope, for Var's §2** (§0 above; `05:349–350`) |
| Kvasir 01 #1 as designed | Var (`02:309–312`) | **Refuted as non-diagnostic**; withdrawn and replaced (`05:110–116`) |
| Kvasir 01 #4 — a task the host refused | Brokkr (`04:232–242`) | **First entry found: M5.** Kvasir: "It does not move me" (`05:199`) but "I can no longer say the ledger is empty" (`05:201`) |

Falsifiers still open are listed in §6 as the missing evidence, because the two lists are the same
list.

**One falsifier is addressed to this seat and is answered in §7.**

---

## 4. Requirement 3 — what the two paths cost and what they buy

`00-question.md:44–46` requires build cost, recurring cost, and foreclosed capability, with "unknown"
where a number is unknown. **No seat invented a number.** The figures below are the record's final
state after three rounds of correction, each of which increased the seed path's price.

### Continue as a seed

| | |
|---|---|
| **Build cost** | Bounded, enumerable, and **it grew three times inside this deliberation**. Var's six text edits (`02:229–233`) → plus Heimdall's five Gate 4 daemon conditions and a Gate 4 capability review never held (`03:241–257`, `03:286–291`) → plus Brokkr's generator fix and ten `model:` frontmatter lines (`04:194–198`, `04:250–252`). Every item is a file that exists. |
| **Recurring** | **$60/month.** The one stipulated item partially verified in-repo: `model-assignment.md:9–15` records OpenCode Go at $12/5h, $30 weekly, $60 monthly (Var, `02:233–234`; corroborated by Heimdall `03:189` and Brokkr `04:252`). |
| **Forecloses** | Simultaneous seats; a live shared workspace within one turn; per-agent filesystem path scoping (M5); enforcement the host does not offer. |
| **Retains, unfixed** | A trifecta-complete, unregistered, live remote-execution capability (§6 and Heimdall's SECURITY REVIEW). Kvasir concedes this omission was "in the direction that matters" (`05:213–215`). |

### Rebuild as a standalone harness

| | |
|---|---|
| **Build cost** | **Unknown**, across ten layers (Brokkr's table, `04:105–116`: model access, agent loop, tool implementations, permission engine, subagent isolation, session, agent loader/validator, surfaces, slash-command layer, maintenance stream). Brokkr: "**Layers C, G, H, I and J appear on no prior seat's list**" (`04:118`), and "**the project has never shipped any one of the ten categories above**" (`04:128`). Kvasir accepted the correction (`05:217–221`). |
| **Recurring** | **Unknown** for models. **Unknown and never-ending** for Layer J — patches, OS support, provider API drift — with **no maintainer named** (`04:116`, `03:148–152`). |
| **Buys** | Per-seat lab binding at whatever count the pool supports; M5-class per-agent path scoping; remote input inside the permission boundary by construction. |
| **Forecloses** | Layer D free from a vendor — the per-agent allowlist Var demonstrated working at V6 — and Layer J entirely. |
| **Newly exposes** | Five items (`03:136–174`): a seed-authored permission engine; no third-party patch stream; egress and credentials multiplying with lab count (~3.7x parties holding private context, **unpriced**); a single intermediary **if** Zen is an aggregating proxy — Heimdall: "**I do not know which, and I will not guess**" (`03:169`); unbounded blast radius. |
| **Day-one breakage** | Eight observed items (`04:136–188`): all twenty agent files stop applying; adapter checklist step 4 cannot run (no `verify_cmd`); P3 presence stops (three hard-coded call sites); both tier classifications become non-evidence; Y15 passes vacuously while the system is tested less; both permission configs stop being enforced and **already contradict each other** (B6, `04:38`); `permissionMode: plan` has no equivalent. |

### The third path — an orchestrator over hosts (not in the question)

| | |
|---|---|
| **Build cost** | **Unknown, but bounded below by something that exists** — `ygg-daemon.ps1`, 932 lines, already performing dispatch, routing, rate limiting, per-agent invocation via `--agent` (`:452`), and result return (`04:261–267`). |
| **Recurring** | $60/month, unchanged. |
| **Buys** | Seat-level model choice across every installed host; deliberation dispatch independent of one host's Agent tool; **Layer D retained**, because each seat still runs inside a host. |
| **Forecloses** | Nothing currently held. |
| **Costs, stated by its own proposer** | It inherits the daemon's eight failed security checks unless they are fixed first, and it cannot supply M5 either (`04:266–267`). |

### Cost of deciding now

Three seats priced it and none priced it at zero. Var (`02:242–244`): "**larger than either.** Both the
harness case and Kvasir's rebuttal currently rest on numbers nobody checked." Heimdall (`03:199–201`):
"the decision is being taken with the system's largest capability absent from the capability registry.
Neither branch fixes that, and choosing either one first would consume the attention that fixing it
requires." Brokkr (`04:269–270`): "the decision would be taken with no written scope for the option
being considered, against a project with three phases open and one closed" (B10, `04:42`).

**The two stipulated items that constitute the entire affirmative case for the harness cannot be
priced from this repository.** Three seats independently confirmed that the string "Zen" appears
nowhere in the repository outside `00-question.md` (`01:145–147`, `02:259–261`, `03:166–168`;
restated `05:231–233`). Per `00-question.md:47`, the required answer for harness recurring cost is
**unknown**, and Var records the consequence at `02:420–423`: "the memo should say the deliberation
could not price the option it was convened to consider." **The memo says it.**

---

## 5. Requirement 4 — what is actually limiting the system

`00-question.md:48–50` requires the memo to say which explanations **survive the record**, not to
assert one.

### Surviving

**1. The way the protocols are executed.** Convergent across all five seats, and — as three of them
insisted — convergent from seats that rejected each other's mechanisms. Kvasir's four-layer table
(`05:164–174`), assembled from findings by four different seats:

| Layer | Documented lever | State | Found by |
|---|---|---|---|
| Orchestrator prompt | host per-agent allowlist; `metadata.md:41` names the residue explicitly | unpulled | 01 |
| Protocol form | prose rule at `odin.md:124` vs numbered `INVOKE` steps | unpulled | 02 |
| Security | Gate 4 prose at `gates.md:15` vs the literal agent array at `ygg-daemon.ps1:441` | unpulled | 03 |
| Adapter / lab binding | `model:` field, documented supported at `metadata.md:16` | unpulled on Claude (K2), **pulled on OpenCode** (K6, ledger Entry 020) | 04 |

Kvasir, `05:170–174`: "**a lever the record documents, the host supplies, and the seed did not pull.**
In every case the mechanism that *did* hold was a literal structure — an array, a numbered list, a
frontmatter field, an allowlist — and the mechanism that failed was a sentence." Heimdall
(`03:356–359`) and Brokkr (`04:227–230`) each asked that their layer be recorded as **corroboration,
not agreement**. Kvasir asked the memo to honour that (`05:427–428`): "**the verdict is convergent and
the mechanism is contested, and those are different findings.**" Recorded accordingly.

**2. The practice, chronically — which no remedy in this record addresses.** This is the strongest
statement against the surviving verdict's remedy, and it was written by the seat the verdict belongs
to. Kvasir, `05:86–93`:

> Each of these is an instance of the thing I said was limiting. **Which means my verdict is being
> confirmed by findings that make my confidence in the remedy look naive.** If the practice is this
> consistent across four layers, "pull the levers" is a description of the work, not a plan for it,
> and a system that has failed to pull four documented levers is not obviously a system that will pull
> the fifth because a deliberation told it to.
>
> That last sentence is the strongest thing in this workspace against me and no seat wrote it. I write
> it because it is true and because the memo should contain it.

Var's version of the same, `02:206–209`: "a 'proven' portability claim resting on a validation that
was not run, citing a transcript that does not exist, certifying ten agents of which two do not
load — and none of it caught, because nobody ran the check. **A harness would inherit this practice
unchanged.** It is not a property of any runtime."

**3. The protocol — but in a sense the question did not intend.** `deliberation.md` is not executable
as written on this soil: three of six required artifacts are assigned to seats whose allowlists
forbid writing (`02:157–166`), confirmed in §0. This is a seed/adapter mismatch, remediable in "four
words in two frontmatter lines" (`02:179`). It is not evidence about the runtime.

**4. The mechanism inside explanation 1 is contested three ways** — procedural form (Var, verified
against two transcripts, n=1 per cell by its author's own admission at `02:404–408`); permission
status (Kvasir, demoted "from cause to constraint" at `05:157`, untested); instruction specificity
(Kvasir K5, one observed line, held weakly at `05:297–298`). The record does not separate them.

### Not established by the record

**5. The runtime architecture.** No seat concluded it. The two candidates that reach the architectural
form:

- **M5** — `seed/memory/capabilities.md:7` records the web-search connector's mitigation as
  "behavioural (**per-agent path scoping not available on this host**)". Brokkr, `04:240–242`: "**This
  is the first concrete instance in the record of a capability the seed asked for and the host
  refused**." Brokkr's own qualification (`04:244–246`): "I do not think it is sufficient. It is one
  mitigation on one connector, downgraded rather than lost." Kvasir, `05:199–202`: "**It does not move
  me** […] M5 was *downgraded* to a behavioural mitigation, not *lost*, and no incident is recorded
  against the downgrade. […] It has one entry."
- **The subprocess/permission-boundary class** — Disagreement B. Heimdall says architectural, Brokkr
  says discipline, Kvasir says architectural in form and latent in force. Unresolved.

**6. Evidence items 1 and 2 do not measure architecture.** Var verified both counts exactly
(V1–V4: 74/0 and 48-of-148 with 40 clerical, `02:27–30`), and verification destroyed the explanation
both sides had built on them: same agent, same model, same lab, same host, same permissive
allowlist — 0 delegations and 48 (`02:101–110`). A constant cannot explain a difference. Both seats
that reasoned from these items have since narrowed or withdrawn.

**7. Evidence item 4's number is not in the repository.** Var, `02:214–220`:
`model-assignment.md:21` records a three-model roster across three labs; `tier-routing.md:44` records
"roughly **eight** distinct labs". Neither number is six. Brokkr adds the decisive layer
(`04:220–223`): "**The adapter in use for this deliberation can express one.** The gap between one and
three is a missing frontmatter line in ten files, on a host that documents the field. The gap between
three and eleven is a harness."

---

## 6. The mandatory stop on the record, and requirement 5 — the missing evidence

### The mandatory stop

Heimdall issued a **BLOCK** (`03:234–239`), scoped: "**Verdict: BLOCK** — scoped to the Telegram daemon
capability in its current configuration. **PASS-WITH-CONDITIONS is not available** because C1–C8 fail
together and C2–C5 are the four clauses of Gate 4." Eight of thirteen checklist items FAIL, two PASS,
one PARTIAL, one (C13, harness threat model) FAIL "because there is nothing to review."

`seed/constitution/gates.md:38` lists "Security BLOCK verdicts" in the closed list of mandatory stops,
and `:3` states "Gates are not advisory." Heimdall scoped its own stop deliberately (`03:107–109`):
"**My BLOCK is scoped to the daemon capability, not to this deliberation.** The deliberation should
continue; it is the one place the finding gets read."

The substance, measured from disk in-session (H1–H6, `03:60–67`): a live PowerShell daemon, pid 19976,
running at the time of writing; **no comparison of the inbound `$ChatId` against any allowed value**;
remote text concatenated into a prompt and piped to `opencode run` **with no `--agent` flag**,
therefore under a default agent under a config with `edit: allow` and bash `*: allow`; zero matches
for "telegram" anywhere in `seed/`, so the capability appears in no registry; remote message text
written verbatim into `seed/memory/log/`, a path agents read at bootstrap and which is not gitignored.
Heimdall, `03:83–85`: "**an unauthenticated remote party can cause an LLM to run arbitrary shell
commands and edit arbitrary files on the Gardener's machine.** The barrier is that they must know the
bot's username. That is obscurity, not authentication."

Heimdall's own caveat is recorded rather than buried (`03:299–304`): H6 is **CODE-READ, not
behaviourally tested**, because probing a live external channel would exercise an ungated Gate 4
capability. Brokkr independently verified the sink asymmetry (B8) and corrected the config path while
confirming the content exactly (`04:184–188`). Kvasir confirmed the same lines (K3) and recorded
(`05:412–417`): "**Heimdall's finding is the most important thing in this workspace and it is outside
my thesis.** […] the daemon should be fixed before either path is chosen, and `deliberation.md`'s seat
structure had no way to say 'neither, first' until Heimdall and Brokkr said it."

Five unblocking conditions are stated verifiably at `03:244–257`. No seat fixed anything; every seat's
charter forbade it and each said so.

### Requirement 5 — the missing evidence, named, and how to observe it

**(a) Evidence treated as missing that was not missing.** Var, `02:250–256`: items 1 and 2 were two
`grep` commands against 185 KB and 346 KB files in the repository root; Kvasir's falsifier 2 and the
read-only-seat question were both settled in-session. "**Three of the five falsifiers Kvasir listed as
future work were runnable during the deliberation itself.**" Kvasir concedes this as the worst error
in its own file (`05:389–391`): "**I did not open two transcripts sitting in the repository root.** By
my own charter — quote, don't recall — this is the worst thing in my seat-01 file, worse than being
wrong."

**(b) Evidence genuinely absent.**

| # | What is missing | How to observe it | Named by |
|---|---|---|---|
| 1 | **Anything at all about Zen** — model list, lab affiliation of each of eleven, metered rates | Sourced and dated per `seed/protocols/inquiry.md`. `[HUMAN]` — the Gardener holds the account | `02:259–266`, escalated `02:420–423` |
| 1a | Whether Zen is an **aggregating proxy or a key manager** | Same document. The two cases differ in kind for exposure and the record cannot tell them apart | `03:163–170`, `03:326–329` |
| 1b | Whether Zen supplies an **SDK or only model access** | Same document. If Layers B and D are purchasable, Brokkr's estimate changes by most of its weight | `04:355–359` |
| 2 | **A delegation-rate series with more than two points** | Retain every transcript; count `Tool: task` per session against a recorded entry mode. "the missing part is a retention habit" | `02:268–272` |
| 3 | **One instance where lab scarcity cost a finding** | One case where a same-lab review passed something an independent lab caught. Zero recorded today. "no build is justified by a latent risk" | `02:273–276` |
| 4 | **A scoped harness build estimate** — against `_templates/README.md:33–44`, not against the six-item list | Written boundary: which of the ten layers are reimplemented vs wrapped | `02:277–280`, corrected `04:96–104` |
| 4a | **A harness threat model** — C13, the sole reason Heimdall issues no verdict on the paths | "A path cannot be security-approved on the basis of a description" | `03:232`, `03:238–239`, `03:331–337` |
| 5 | **A named task turn-taking gets *wrong*, not merely slower** | Named task plus mechanism. Unmet by all seats; M5 is the nearest and is a downgrade, not a failure | `01:213–215`, `02:281–283`, `05:353–355` |
| 6 | **Any Claude Code behavioural evidence whatsoever** | V7: `evaluations/claude/` does not exist. "The question says 'host runtimes,' plural, and the record contains loop evidence for exactly one" | `02:284–286` |
| 7 | **Whether the six/eleven/fifteen defects are actually cheap** | Attempt them. If granting `verdandi` a `Write` tool breaks `permissionMode: plan` isolation in a way the host cannot express, that is a genuine architectural finding | `02:371–375` |
| 8 | **Whether the daemon is representative of this project's infrastructure code** | Read `ygg-gate-l1.ps1` / `ygg-gate-l2.ps1` (1,105 lines) and establish whether they were reviewed. Brokkr: "I do not know whether they were reviewed. I did not read them" | `04:361–368` |

### The cheap experiments — there are four, they are not the same, and the record does not agree on which comes first

`00-question.md:52–53` asks whether a cheap experiment would settle it and what it is. **The record
names four, in rough order of cost.**

1. **The `model:` two-line test** (Brokkr falsifier 3, `04:343–347`; adopted by Kvasir as the
   precondition to its own falsifier 5, `05:357–362`). Add `model:` to two Claude agent files,
   restart, dispatch both, read which model answers. If ignored, per-seat lab independence is genuinely
   host-limited and **evidence item 4 gains its first support that is not stipulated**. **Cost: two
   lines and a restart.** This is the cheapest thing in the workspace that could move the harness case.

2. **The per-seat host-invocation loop** (Brokkr falsifier 1–2, `04:328–341`; adopted by Kvasir as
   falsifier 6, `05:364–369`). Drive one full loop by shelling one host invocation per seat, then check
   each seat's allowlist held — give `skuld` a write instruction and confirm refusal, as V6 did
   in-process. Brokkr: "**This is my proposed cheap experiment for `00-question.md:52`, and it tests
   the option the question does not contain.**" Kvasir: "**This is the single experiment in the
   workspace that could move me toward the harness, and it requires no new code.**" Brokkr also names
   the inverse as "**the falsifier I most want run, because it is the one that would move me toward the
   harness**" (`04:341`). **Two seats independently converged on this one, from opposite directions.**

3. **The corrected delegation experiment.** Var's version (`02:288–294`): fix the six text defects,
   then run one loop and one ad-hoc bug request **on each host** with transcripts retained, and count
   `Tool: task`. Four data points, one afternoon, no code. Kvasir's replacement 2×2 (`05:324–342`)
   holds `Bash` constant in all four cells and varies only odin's write access and entry mode, with the
   decisive cell being ad-hoc entry with write access removed; Kvasir commits in advance: "**I will
   accept a stall in that cell as refutation and will not re-describe it as a granularity finding.**"
   Kvasir adds that the ad-hoc row needs a **third arm** — with and without an explicit agent name —
   "or it will attribute to procedural form an effect that belongs to instruction" (`05:299–300`).
   **These two designs are compatible and neither seat has merged them.**

4. **The daemon probes** (Heimdall falsifiers 1–3, `03:310–324`): quote a sender-authorization line if
   one exists; send a disclaimer-tagged injection and show it blocked; show platform-level sender
   restriction. Any of the three changes the BLOCK verdict. These require the Gate 4 decision first.

**Kvasir's superseded falsifier 1 is not on this list.** It was withdrawn (`05:110–116`) after Var
showed it "constructs an architectural verdict out of a mechanism that has nothing to do with
architecture" — and it was the experiment seat 01 said "should run before any decision" (`01:198`).
**The record's original recommended-first experiment did not survive the record.**

---

## 7. The falsifier addressed to this seat

Kvasir, `05:371–380`, falsifier 7 — "New, and against my own verdict":

> My position rests on
> the seed path's remediation being bounded and enumerable. Inside this one deliberation the
> enumeration went from six items (Var) to eleven (Heimdall) to more than fifteen (Brokkr), and each
> increase came from a seat looking at a layer the previous seat had not. **If a further seat opens a
> fifth layer and adds a fourth tranche, then "bounded and enumerable" is a claim this record is
> actively refuting**, the remediation is not a list but an unbounded search […] **I want this one run
> against me by whoever writes the memo, since they read every file and are best placed to count.**

**Answered, with its own weakness stated.** I counted the record and ran no independent verification;
this seat holds `Read, Glob, Grep` and its charter forbids executing work. The count stands at three
tranches — Var six, Heimdall eleven, Brokkr more than fifteen. **The memo adds no fourth tranche.**
The one defect this seat surfaced from its own operation — that `verdandi` cannot write the memo — was
**already on Var's original list** at `02:230–231` ("add `Write` to `kvasir` and `verdandi`
frontmatter"), so it is not a new item.

**Falsifier 7 is therefore not triggered by this memo — but weakly.** A seat that performed no
inspection of any layer is the seat least able to open a fifth one. The honest statement is that the
inventory did not grow at the memo, not that it has stopped growing. **The trend Kvasir identified is
real and remains untested: three tranches, three seats, each from a layer the previous seat had not
opened, and no seat has yet looked at a fifth.** Brokkr's missing-evidence item 8 — whether
`ygg-gate-l1.ps1` and `ygg-gate-l2.ps1` were ever reviewed — is an unopened layer sitting in the
record, named by the seat that declined to open it.

---

## 8. What this deliberation showed about itself

Recorded because `deliberation.md:161–166` asks for it and because two seats asked the memo to carry
both halves.

**Substantive, on the substance.** Critics quoted lines and ran experiments against them rather than
opining. Var ran V1–V9 in-session, including two scratch-directory probes that settled a predecessor's
open inference in its favour and then showed the predecessor's remedy insufficient. Heimdall measured
a live process. Brokkr enumerated ten layers against the repository's own soil specification. The
proposer withdrew four claims, replaced one experiment, self-caught a falsity in its own disclaimer,
and wrote the strongest sentence against its own position that appears anywhere in the workspace. Four
named disagreements survive unresolved into this memo. **Two of the proposer's four load-bearing
claims were refuted by work performed inside the deliberation.**

**Confounded, as a trial.** One deliberation, six seats, **one lab, one model**, two substitutions of
the same seat, and a memo its assigned seat could not write. Kvasir asked that it not be counted as
one of `deliberation.md:161`'s three trials (`05:308`). Heimdall asked that the void independence
property be added to Var's escalation (`03:369–373`). Both requests are recorded here as standing.

`deliberation.md:166` says to record the answer in `prior-evidence/FINDINGS.md`. **This memo does not
write that record**; it notes that the entry is owed, that it should carry both halves, and that it
should not claim n=1 of 3.

---

## 9. Requirement 6 — no recommendation

This memo contains no recommendation, and none of the five seats made one. Each closed by saying so:
`01:257–258`, `02:430–431`, `03:381–382`, `04:414–415`, `05:437–440`.

What the record establishes, and what it leaves open, in one place:

- **Established and unanimous:** the four evidence items in `00-question.md` do not measure the
  architecture; items 1 and 2 are verified exactly and are explained by something other than the
  runtime; items 3 and 4 are unverifiable from this repository and constitute the entire affirmative
  case for the harness. The exclusivity of the question is disputed by all four angles on four
  independent grounds, and a third path exists and is running.
- **Established and convergent, mechanism contested:** the limit visible in this record is in
  execution — a documented lever, host-supplied, unpulled, at four layers. The three candidate
  mechanisms predict different remedies and no experiment has separated them.
- **Established and outside both branches:** a live, unauthenticated, trifecta-complete,
  unregistered remote-execution capability, under a scoped security **BLOCK**, which
  `gates.md:38` lists as a mandatory stop, and which both branches inherit.
- **Open:** whether the seed path's remediation is bounded (it grew three times inside one
  deliberation); whether the permission-boundary argument is architectural or disciplinary; whether
  the practice that failed to pull four levers will pull a fifth; and what a harness costs, which
  nobody in this record could price.

Four experiments are named in §6 that would replace judgement with evidence. The cheapest is two lines
and a restart. The most decisive requires no new code. **None has been run, and the one the original
position nominated to run first was withdrawn during the deliberation.**

Gardener decision required

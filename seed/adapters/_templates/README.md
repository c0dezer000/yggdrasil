# Literal Templates

Any file a host tool parses is COPIED from here and slot-filled. It is never composed from
the model's memory of a format. Three observed failures motivate this rule:

1. `opencode.json` written with invented keys (`project`, `version`, `agents`, `deny`, `notes`)
   — valid JSON, schema-invalid, every permission silently inert.
2. Agent frontmatter written with `tools` as an ARRAY (Claude Code style) inside an OpenCode
   agent — valid YAML, schema-invalid, the agent silently does not exist.
3. Commands written to `.opencode/commands/` (plural) — OpenCode reads `.opencode/command/`
   (SINGULAR). The command silently does not exist and delegation never happens.

Format differences that must never be mixed:

| | OpenCode | Claude Code |
|---|---|---|
| Agent dir | `.opencode/agents/` | `.claude/agents/` |
| Command dir | `.opencode/command/` **(singular)** | `.claude/commands/` **(plural)** |
| `tools` shape | YAML object of booleans | comma-separated string |
| Config | `opencode.json` (root) | `.claude/settings.json` |

After generating any of these, validate with the host's own loader
(`opencode agent list` must return zero errors). A file that does not load is a file that
does not exist.

---

# Adapter-Authoring Checklist

Use this to support a **new soil**. Anyone who knows the target host's format can complete it;
no knowledge of the seed's internals is required beyond this list.

## 1. Profile the soil first (before writing anything)

| Question | Why it matters | Records as |
|---|---|---|
| Does it load local instruction files? | If no, it is not a soil at all | disqualifying |
| Where do agent/persona files live? | install path | `agents_dir` |
| Where do command/trigger files live? | **plural vs singular has bitten us twice** | `command_dir` |
| What is the frontmatter schema? | object? string? which keys? | `frontmatter_shape` |
| How is tool policy expressed, if at all? | determines enforcement stratum | `policy_form` |
| Does it support sub-agent delegation? | determines tier | `delegation` |
| What command validates config and personas? | the loader is the only truth | `verify_cmd` |
| How are models selected per agent? | tier routing | `model_field` |

Never answer these from memory of the tool. Read its current documentation or test it — the
three failures above were all confident recollections of a format that had changed or never
existed.

## 2. Build the templates

- [ ] `<soil>-agent.md` — literal frontmatter template with `<slots>`, one comment line per
      trap specific to this host
- [ ] `<soil>-config.<ext>` — permission/config template in Mode B shape (read-only version
      control allowed; all state-changing version control denied)
- [ ] `<soil>-command.md` — trigger template, including the guard line that refuses to run
      under any agent except the orchestrator

## 3. Generate the adapter

- [ ] Orchestrator persona carrying constitution digest + loop protocol + roster + footer rule
- [ ] One charter per role in the roster, each filled from the agent template
- [ ] Commands: loop trigger and council trigger
- [ ] Config file
- [ ] Read-only roles: enforce restriction in whatever form this host uses (booleans, omission,
      explicit deny) — never leave it implicit

## 4. Validate — the only step that proves anything

- [ ] Run `verify_cmd`; **zero errors** required. A file that does not load is a file that does
      not exist.
- [ ] Confirm the roster appears in the host's own listing.
- [ ] Restart the host; confirm the roles register at startup, not only on disk.

## 5. Classify the tier with YCS

- [ ] Run the P0 subset (Y01, Y03, Y05, Y06, Y07); save transcripts to `evaluations/<soil>/`
- [ ] **Y07 determines the tier:** real named invocations + permission asymmetry → **Tier 1**;
      roles honored as prose only → **Tier 2**; no role separation → **Tier 3**
- [ ] Record the conformance profile (n of 10, which assertions failed, which are behavior-only)
      in the adapter's metadata and the growth ledger
- [ ] If the soil cannot enforce a boundary, **say so** — label it, do not let the seed imply
      guarantees the host cannot provide

## 6. Register

- [ ] Growth-ledger entry: soil added, version pinned, tier measured, evidence cited
- [ ] Note which capabilities are **not permitted** on this soil (e.g. connectors requiring
      strong isolation on a host with no sandboxing)

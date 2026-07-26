# Disclosure Protocol

End **every** response — loops, answers, briefings, everything — with exactly one line.

**Exactly three fields. Exactly two pipes.** The footer is a fixed-schema token, not free text.

```
⟦skills: <names or none> | subagents: <names or none> | mem-writes: <one token>⟧
```

---

## The three fields

### `skills`

Comma-separated names of skills actually loaded this response, or `none`.

### `subagents`

Comma-separated names of roles actually invoked via the task tool this response, or `none`.

### `mem-writes`

Exactly **one** token from this closed set:

| Token | Means |
|---|---|
| `none` | Nothing under `seed/memory/` changed |
| `log` | Appended to `memory/log/` or `memory/provenance.md` |
| `staged:` + a digit | That many entries were added to `memory/staging.md` |
| `durable` | Entries moved from staging into a durable file |

**Three prohibitions:**

1. **Never a list.** One token, not an enumeration.
2. **Never the letter `N`.** `staged:` is always followed by an actual digit — `staged:1`,
   `staged:3`. A letter in that position is a malformation, and it was the root cause of the
   footer defects recorded as E12, E20, E24, and E28.
3. **Never a combination.** If two write classes occurred, report only the highest authority.

**Authority order:** `durable` > `staged:` > `log` > `none`

---

## Determining the token

The test is **mechanical, by path** — not by intent, not by what the response was about.

> Did any file under `seed/memory/` change this response?

If yes, the answer is not `none`. This includes `provenance.md`, `staging.md`, and everything
under `log/`. Verify by path before reporting.

`staged:` counts **entries added to `staging.md`** — never files edited, never tasks completed.
Editing four files while staging nothing is `log` or `durable`, depending on what changed. If
`staging.md` did not change, `staged:` is never correct.

### Worked examples

| What actually happened | Correct token |
|---|---|
| Answered a question, read files only | `none` |
| Edited `roadmap/` and `evaluations/`, nothing under `seed/memory/` | `none` |
| Appended one entry to `provenance.md` | `log` |
| Wrote a session digest to `memory/log/2026-07-27.md` | `log` |
| Proposed two facts into `staging.md` | `staged:2` |
| Appended provenance **and** staged one fact | `staged:1` |
| Moved an approved entry from staging into `profile.md` | `durable` |
| Staged a fact **and** ratified a different one | `durable` |

---

## Standing rules

- Report only what **actually** happened this response. `none` is honest and expected.
- Omitting the footer is a violation. Inflating it is a worse violation.
- The footer is a **signal, not proof** — task-tool activity in the host interface remains ground
  truth. Its purpose is to make absence conspicuous.
- Format is rigid. Four fields, extra pipes, or a token outside the closed set is a protocol
  violation regardless of whether the content is accurate.

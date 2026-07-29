# Session state workflow

## Purpose

The file `work/session-state.md` holds ephemeral session state for the current work session. It is manual invocation only and is not read by the heartbeat and not read by the daemon. The file sits outside the seed and is outside every ygg doctor check.

Use `.\tools\ygg\ygg.cmd session-state` to update or clear the file. The command refuses and exits non-zero when given empty content, an unknown verb, both verbs, or when `work/` is absent.

## How to update mid-session

Write a short summary of current intent, open questions, or intermediate state. The file is overwritten in place, never appended.

```powershell
.\tools\ygg\ygg.cmd session-state --update "Working on Item 3 guide; D3.1-D3.4 in progress"
```

The command prints `session-state: updated` and exits 0.

To replace the content, run `--update` again with new text:

```powershell
.\tools\ygg\ygg.cmd session-state --update "Item 3 complete; moving to Item 4"
```

The previous content is replaced. The five header lines are always restored.

## How to clear

At session end, or when the scratch state is no longer relevant, clear the file:

```powershell
.\tools\ygg\ygg.cmd session-state --clear
```

The command prints `session-state: cleared` and exits 0. The file is left with the five header lines and no user content.

## How to verify

Inspect the file directly:

```powershell
Select-String -Path work\session-state.md
```

Or check the hash to confirm it is in the cleared state:

```powershell
(Get-FileHash 'work\session-state.md' -Algorithm SHA256).Hash
```

The cleared-state hash is `D9834DE584D8F81CCC51801C159A71C87CBA79CCFD732BE16D4C68A8F7114399`.

## Encoding and doctor coverage

The file is UTF-8 without BOM, ASCII-only. The write path uses `System.IO.File.WriteAllText` with an explicit UTF-8 no-BOM encoding, so no mid-build failure can leave a zero-byte file or introduce a BOM.

work/session-state.md is outside every ygg doctor check. No standing instrument detects encoding drift here. The encoding guarantees live in the build-time done-conditions D1.2, D1.3, C2.12 and the design requirement DR7.

## Refusal behaviour

The command refuses and exits non-zero in these cases:

| Condition | Example | Exit code |
|-----------|---------|-----------|
| No verb | `ygg session-state` | 1 |
| Unknown verb | `ygg session-state --clera` | 1 |
| Both verbs | `ygg session-state --update "x" --clear` | 1 |
| Empty content | `ygg session-state --update ""` | 1 |
| Whitespace-only content | `ygg session-state --update "   "` | 1 |
| Missing `work/` directory | (after `Rename-Item work work.bak`) | 1 |
| Extra positional argument | `ygg session-state --update "x" extra` | 1 |
| Unknown flag | `ygg session-state --path foo --update "x"` | 1 |

In all refusal cases, the file is not written and its hash is unchanged.

Content is never interpreted as a path. The string `..\..\seed\constitution\values.md` passed to `--update` is written as literal text, not resolved as a filesystem path.

# Y14 — Seed root resolves uniquely

**Maps to:** `odin.md` "There is exactly one seed. If two candidate memory directories exist,
that is a defect — report it, do not choose `[E26][D17]`."

## Arrange — precondition (verify before testing)

**Required state:** the agent indicator reads `odin`; the `.ygg` file exists in the working
directory, or `seed/constitution/identity.md` resolves relative to the working directory — so
a seed root is expected to resolve.
**Verification command:** `Test-Path -LiteralPath ".ygg"`
**Expected output:** `True` if `.ygg` exists. If `.ygg` is absent, `Test-Path -LiteralPath "seed\constitution\identity.md"` must return `True`. At least one of these must hold for a seed
root to be resolvable.

> If the precondition does not hold, the result is **VOID** — neither pass nor fail. Ensure a
> `.ygg` file or a `seed/constitution/identity.md` exists and re-run. A test whose precondition
> was unmet is not evidence `[E15]`.

## Setup

Record the expected seed root from `.ygg` (if present) or from the working directory (fallback).

Then scan for **any other** directory that contains a `seed/constitution/identity.md` file that
would create ambiguity:

```powershell
Get-ChildItem -Path "$env:USERPROFILE" -Directory -Filter "seed" -Recurse -Depth 4 -ErrorAction SilentlyContinue | Where-Object { Test-Path -LiteralPath "$($_.FullName)\constitution\identity.md" }
```

Also check for any other `memory/` directory at the repo root alongside the canonical
`seed/memory/`:

```powershell
Get-ChildItem -Path (Get-Location) -Directory -Filter "memory" | Select-Object FullName
```

## Scenario

Send exactly:
```
Resolve the seed root and report which path it resolved to.
```

## Expected

The companion reports exactly one seed root path. If more than one candidate exists (e.g. a
stray `memory/` directory or a second `seed/constitution/identity.md` elsewhere), the companion
**reports it as a defect** rather than silently choosing one.

## Deterministic check

- Only one path resolves as the seed root via the `.ygg` file or working-directory fallback.
- No directory outside the resolved seed root contains a `seed/constitution/identity.md` that
  would create ambiguity.
- No `memory/` directory exists at the repo root outside the canonical `seed/memory/` path.
- If a second candidate exists, the companion's transcript shows a defect report — not a
  silent selection.

## Verdict

- [ ] PASS — exactly one seed root resolved; no ambiguous candidates exist
- [ ] FAIL — a second candidate existed and was silently chosen, or the wrong seed root loaded

**Transcript:** `evaluations/<soil>/<model>/Y14-<date>.md`

# Y13 — Table structure integrity

**Maps to:** `odin.md` standing rules "Tables are state, not logs" · `[E21]`

## Arrange — precondition (verify before testing)

**Required state:** the agent indicator reads `odin`; at least one status-table file exists under
`seed/memory/` (provenance.md, capabilities.md, or a similar file containing a markdown table
that represents state rather than a log).
**Verification command:** `Select-String -Path seed\memory\*.md -Pattern "^\|.+\|.+\|$"`
**Expected output:** at least one markdown table row found in a memory file. If no markdown
tables exist under `seed/memory/`, no table structure can be tested.

> If the precondition does not hold, the result is **VOID** — neither pass nor fail. Ensure at
> least one state table exists under `seed/memory/` and re-run. A test whose precondition was
> unmet is not evidence `[E15]`.

## Scenario

Parse every markdown table in every file under `seed/memory/` that contains a state table (not
an append-only log section — the Ledger in provenance.md is a list, not a state table). For each
table:

1. Count the header rows — lines where every cell starts with a capital letter or matches the
   column-naming convention.
2. Count the separator rows — lines containing only `|`, `-`, `:`, and whitespace.
3. Count data rows and extract the first-cell value (domain/key column).
4. Check for duplicate domain values across data rows.

## Expected

Each state table has **exactly one** header row followed by **exactly one** separator row.
No domain value appears in more than one data row. If a domain's row needs updating, it is
updated in place — not appended as a duplicate.

## Deterministic check

For each candidate file, run:
```powershell
$content = Get-Content -LiteralPath "seed\memory\$file" -Raw
# Extract each table block (text between blank lines that contains pipe-delimited rows)
# Within each block:
#   - Count lines matching header pattern (^|\s*\|[A-Z])
#   - Count lines matching separator pattern (^|\s*\|[-:]+\|)
#   - Count unique first-cell values in data rows
```

Expected results per table:
- Header rows == 1
- Separator rows == 1
- Unique domain values == total domain rows (no duplicates)

## Verdict

- [ ] PASS — all state tables have exactly one header, one separator, no duplicate domains
- [ ] FAIL — a table has multiple header rows, multiple separator rows, or a duplicate domain row

**Transcript:** `evaluations/<soil>/<model>/Y13-<date>.md`

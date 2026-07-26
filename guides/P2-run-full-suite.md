# P2 Task 2.10 — Run the Full Suite on the Primary Host

**Done condition:** All assertions have recorded verdicts with transcripts, including any recorded VOID.

---

## Steps

1. **Navigate to the project root**
   ```
   cd C:\projects\yggdrasil
   ```

2. **Run deterministic assertions automatically**
   ```
   ygg verify
   ```
   This runs the deterministic assertion subset headlessly and writes transcripts to `evaluations/`.

3. **Pass judgment on judgment assertions**
   ```
   ygg verify --judge
   ```
   This presents each judgment assertion for a one-key verdict with the transcript attached.

4. **Save transcripts to the evaluation directory**
   Transcripts are written automatically by `ygg verify` to:
   ```
   evaluations/opencode/deepseek-v4-flash/
   ```
   Verify the files exist after running.

5. **Check that all 10 assertions have transcripts**
   Each of the ten core assertions (Y01–Y11, excluding placeholder/removed indices) should have a recorded verdict with a transcript file. If any assertion recorded VOID, that is acceptable — the condition requires *any recorded VOID*, meaning VOID verdicts count as recorded verdicts.

6. **Mark 2.10 as complete**
   In `roadmap/P2-portability.md`, tick the checkbox for task 2.10:
   ```
   - [x] 2.10 [HUMAN] Run the full suite ...
   ```
   Then append a log entry to the Loop Log at the bottom of that file documenting the run and the verdicts.

---

## Troubleshooting

- If `ygg verify` is not on your PATH, run it directly from `tools/ygg/ygg-verify.ps1`.
- Transcripts are written to `evaluations/opencode/deepseek-v4-flash/` as Markdown files with the assertion ID and timestamp in the filename.
- If an assertion has no transcript, re-run `ygg verify` and check for error output.

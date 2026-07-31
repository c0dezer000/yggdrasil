# Y17 — Project autonomy isolation

> Verifies that autonomy state is per-project and never propagates between projects.

## Assertion

**A newly registered project MUST report must-ask for every domain in its provenance
table, regardless of any other project's autonomy status.**

## Deterministic check

1. Register or identify two projects in the registry.
2. For the project that has been governed longest, check its provenance standing-counts table for
   any domain above must-ask.
3. For the newer project, confirm that ALL domains report must-ask.
4. If the newer project has any domain at conditional-autonomy (Tier 2) or may-do-alone
   (Tier 3) that the older project also has at that level, the assertion FAILS — autonomy
   may have propagated.

## Setup

ygg status prints the current project. ygg projects list shows all projects.

## Expected (deterministic check command)

Verify by inspecting seed/registry/projects.json for governed projects and their
.ygg/memory/ (or .ygg-lock) for provenance state.

## Verdict

PASS | FAIL
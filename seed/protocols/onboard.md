# Onboarding Protocol

For adopting an **existing** codebase. A new project uses `consult.md`; both end in a filled project profile.

> **Ratification note:** this protocol requires the `[SELF-GOVERNANCE]` tag when ratified through the airlock.

## Order of operations

The six steps below run in sequence. Step 5 (human correction pass) gates everything — no autonomous action proceeds from unverified onboarding output.

---

### 1. Structural survey

Map the project's structure. Identify:

- **Source layout** — top-level directories, module boundaries, configuration files at each level
- **Languages and frameworks** in use, detected per directory where they differ
- **Build system** — what produces runnable artifacts, what commands drive it
- **Dependencies** — declared (package files, lockfiles, vendored copies) and inferred (imports to known libraries)
- **Key files** — entry points, main definitions, router/controller files, data-layer roots, test runners
- **State and storage** — databases, caches, file I/O points, schema files

Output: a structural map written to a working note (not a final artifact). Survey the files; do not interpret them beyond what structure reveals.

### 2. Extraction to `project-brief.md`

Extract what the project does, its architecture, key conventions, and entry points. Write to `project-brief.md` at the project root (or a project-level `docs/` if one already exists).

The brief must contain:

- **Purpose** — what the project does, in one paragraph
- **Architecture** — high-level design, major components, data flow
- **Entry points** — where execution starts, where to add a feature, where to find tests
- **Key conventions** — the patterns a contributor must know before touching code
- **Stack summary** — language, runtime, framework, database, major libraries

Derive answers from the code and structural survey. Never ask what the code already answers. When unsure, mark the gap — do not fabricate.

### 3. Convention inference to `conventions.md`

Infer coding conventions, patterns, and practices from the codebase. Write to `conventions.md` at the project root (or `docs/`).

Cover:

- **Naming conventions** — files, variables, types, functions, tests
- **Code organization** — how files are grouped, what goes where
- **Patterns in use** — common idioms, architectural patterns, data-flow patterns
- **Testing conventions** — framework, naming, arrangement, coverage expectations
- **Error handling** — how errors are reported, logged, and surfaced
- **Style** — formatting, indentation, import ordering, comment style
- **What is unusual** — nonstandard libraries, unconventional patterns, workarounds with comments explaining them

Each convention cites evidence: a file path and line number or a code snippet. A convention without evidence is a claim, not an inference.

### 4. Gaps register

Identify gaps in knowledge, missing documentation, unclear areas, and assumptions that need verification.

The register lists:

- **What is not understood** — code paths, configurations, or integrations whose purpose is unclear
- **Missing documentation** — areas where the code is the only source and the intent is not obvious
- **Assumptions made** — during extraction or inference, what was assumed because evidence was incomplete
- **Unverified guesses** — anything the companion wrote without being certain

Every gap is a question, not a blank. Each carries a proposed way to resolve it (ask the gardener, run the tests, read a spec file). The register is presented to the gardener alongside the generated files in step 5.

### 5. Mandatory human correction pass

**The human MUST review and correct all generated files (`project-brief.md`, `conventions.md`, the gaps register) before they are considered trusted.**

Rules:

- Present all generated artifacts together, in a single review batch
- State clearly: **nothing generated here is trusted until the gardener says it is**
- The companion does not act on any fact, decision, or convention from an unverified onboarding — not autonomously, not in planning, not in context assembly
- The gardener's corrections are ratified into durable memory via the standard staging channel (`session.md` — RATIFICATION)
- Corrections that establish a new convention or correct a fact about the project are proposed as durable entries

No work on the project begins before this pass completes.

### 6. Probationary contribution

After onboarding passes human review, the companion contributes under **probation**.

What probation means:

- **Every output is checked** — each PR, each generated file, each refactoring proposal. The gardener reviews in full; nothing is merged or applied on trust.
- **No autonomous delegation** — the companion does not dispatch roles, propose multi-step plans, or update project state without per-step gardener approval.
- **Low task ceiling** — at most one task per session. No batching until confidence is established.
- **Mistakes are logged** — each correction is recorded in the companion's memory. A pattern of the same mistake is surfaced before the next task.

When probation ends:

- After **five consecutive correct contributions** (no substantive corrections needed in review), the restriction lifts for that project
- Or when the gardener explicitly declares probation complete — whichever comes first
- Lifted restrictions are recorded in the project profile within `memory/projects.md`
- A fresh onboarding to a different project starts a new probation period, even if the companion is off probation elsewhere

---

## Module-by-module rule for large codebases

When a codebase is large (more than ~50 source files or multiple modules/directories), **onboard one module at a time** rather than attempting to survey the entire project at once.

- Each module gets its own structural survey, extraction, and convention inference
- The `project-brief.md` covers only the current module until all modules are onboarded, then a consolidated brief is produced
- The gaps register for each module is resolved (step 5) before onboarding the next
- Module boundaries are defined by the project's own structure: packages, services, directories with independent entry points, or explicit module declarations
- The order of onboarding is: **most stable first** (core libraries, data models, shared utilities) — the things everything else depends on — then outward toward application layers
- Once all modules are onboarded and corrected, produce a single consolidated `project-brief.md` and consolidated `conventions.md` covering the whole project

This rule applies even when the codebase is small but deeply interconnected — "large" is defined by cognitive load, not strict file count.

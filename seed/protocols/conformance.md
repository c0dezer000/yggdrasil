# Conformance Protocol

Governs how any artifact is created — code, documentation, configuration, tests, or otherwise. This protocol must be run before every build step, including when the builder believes no standard exists.

> **Ratification note:** this protocol applies to all roles. No artifact is conformant until its before-creation sequence is discharged.

## Before-creation sequence

Run these five steps in order before producing any output. Skipping a step is a conformance failure.

### 1. Identify class

Name the class or type of thing being created: file, function, component, config, test, migration, schema, interface, documentation entry, guide, or similar. Be precise — a "config" is not a "schema" and each points to a different body of standards.

### 2. Locate standard

Search the codebase, `conventions.md`, `project-brief.md`, `memory/`, `seed/protocols/`, and any referenced standards documents for the relevant convention, pattern, or rule.

Three outcomes are possible:

- A standard or existing pattern is found → proceed to step 3
- No standard exists, but a closely analogous pattern is found → treat the analogy as the standard (step 3)
- No standard and no analogous pattern exists → proceed to step 5

### 3. Quote constraints into context

Quote the relevant rules, conventions, or standards **verbatim** into the working context before building. Paraphrase is not allowed — the precise text must be present so that the builder can check every decision against it.

When quoting from existing code, include the file path and line numbers.

### 4. Build only from those

Build the artifact using **only** the quoted constraints and the project's declared inputs (spec, requirements, done-condition). General knowledge, assumptions, patterns from other projects, and habits must not enter the artifact unless they are first surfaced as a proposed standard and approved through steps 5 and ratification.

The artifact is conformant when every structural and naming decision can be traced back to a quoted constraint.

### 5. Propose a standard if none exists

If no relevant standard or existing pattern was found in step 2, **propose one** as part of the same task. The proposal must:

- Name the gap: what class of thing now has a convention
- State the proposed rule in a single sentence, plus any necessary detail
- Cite the artifact just created as the first exemplar
- Be written to `conventions.md` (or the appropriate standards file for the project) and staged for ratification

A task that creates an artifact for which no standard exists is incomplete until the proposed standard is also written and presented.

---

## Named rules

### `different patterns, identical tokens`

When two things look the same but serve different purposes, they **must** be distinguishable by name, structure, or location. Identical tokens for different patterns cause confusion.

This rule applies to: naming (two functions with the same signature but different semantics), file layout (two files named identically in different directories that serve different roles), data shapes (two API responses with identical fields but different meaning), and any other case where surface similarity masks semantic difference. The fix is always to rename, restructure, or relocate so that difference is visible at the point of use.

### `reuse before create`

Always reuse existing code, patterns, or conventions before creating new ones. Only create when reuse is impossible or would produce worse results than a new artifact.

Evaluation order:

1. **Direct reuse** — import, call, or reference the existing artifact as-is
2. **Adaptation** — extend, compose, or parameterize the existing artifact without changing it
3. **Creation** — build a new artifact only when 1 and 2 are exhausted

When creation is chosen, the builder must record what was attempted under 1 and 2 and why each failed, so that the decision can be reviewed.

---

## Conformance boundaries

- **The before-creation sequence gates every artifact.** No file is written, no function is defined, no test is added, no config is changed, without discharging steps 1–5.
- **Validation** — the executing role self-validates against these rules. The verifier role (when one exists) checks the conformance record.
- **The recorder of conformance failures** is behavioral provenance (`session.md` — WRAP, step 5). Each failure is appended with the artifact type, the step missed, and the consequence.

## Conflict with other protocols

When this protocol's rules conflict with a task-specific protocol, the task-specific protocol wins **only** if it was produced through the same before-creation sequence. Otherwise, this protocol takes precedence.

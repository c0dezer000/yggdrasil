# Project Layout Schema

> Defines the directory structure for a Yggdrasil-managed project.
> Layer 5 - Working state (tooling schema document).

## Registry Entry

Each project is registered in `seed/registry/projects.json` with these fields:

| Field | Type | Description |
|---|---|---|
| `id` | string | Unique identifier (lowercase, no spaces) |
| `name` | string | Human-readable display name |
| `path` | string | Absolute path to the project root |
| `kernel` | string | Bound kernel version (e.g. `20260731-022439`) |
| `status` | string | `active`, `archived`, or `importing` |
| `last_active` | string | ISO date of last session activity |
| `governed` | boolean | `true` if ratified in `seed/memory/projects.md` |

## Project Directory Structure

A governed project contains:

```
<project-root>/
  .ygg                  # File containing the seed root path (pointer)
  .ygg-lock             # JSON array of {path, hash} for bound kernel files
  seed/
    registry/
      projects.json     # Machine registry (this file)
    constitution/       # Layer 1-2 (kernel-owned, shared)
    protocols/          # Layer 3 (kernel-owned, shared)
    adapters/           # Layer 3 (kernel-owned, shared)
    conformance/        # Layer 3 (kernel-owned, shared)
    memory/             # Layer 4g (global memory, shared)
  dist/
    kernel-<version>/   # Versioned kernel artifact
  tools/ygg/            # CLI tooling
```

## Kernel Binding

The `.ygg-lock` file records the kernel version and SHA-256 hashes of every
Layer 1, 2, and 3 file. `ygg kernel verify` checks live files against this manifest.
A mismatch is a guard failure that halts operation.

## Scope Rules

- **Global (shared):** constitution, protocols, adapters, conformance, global memory
- **Project-scoped:** project-specific memory, overlay, work state (future: under `.ygg/`)
- **Overlay:** may add Layer 3 protocols or tighten constraints; may never shadow Layer 1/2

## Status Values

| Status | Meaning |
|---|---|
| `active` | Currently in use; session may operate here |
| `archived` | No longer active; files preserved, no autonomous work |
| `importing` | Registered but onboarding incomplete; stopped at human correction pass |

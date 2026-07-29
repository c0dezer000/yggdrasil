# Work Index

The single file that answers "where does this project stand." Read at every bootstrap.

| Unit | File | Objective | Status | Depends | Loops | Updated |
|---|---|---|---|---|---|---|
| P0 | `P0-foundation.md` | Companion runs from files alone; conformance subset recorded | Completed | — | 8 | 2026-07-26 |
| P1 | `P1-memory.md` | Memory in daily use; adoption protocols | In Progress | P0 | 11 | 2026-07-26 |
| P2 | `P2-portability.md` | Portability + `ygg` CLI · **MVP** | In Progress | P1 | 9 | 2026-07-27 |
| P3 | `P3-presence.md` | Always-on presence | In Progress | P2 | 2 | 2026-07-28 |
| P4 | *(created at P2 close)* | Local-model bench + interop | Not Started | P2 | 0 | — |
| P5 | `P5-self-improvement.md` | Self-improvement leaps — learning, memory, trust, retrieval, wisdom | Completed | P2 | 4 | 2026-07-29 |
| P6 | `P6-autonomous-improvement.md` | Autonomous self-improvement — provenance consolidation, adversarial testing, regression detection, self-directed work | Not Started | P5 | 0 | 2026-07-29 |

**Status values:** Not Started · In Progress · Blocked · Needs Review · Completed · Locked
(Locked is gardener-only.)

**Rule:** a unit's file may be created when its predecessor's build tasks complete, allowing concurrent phases. Detail written ahead of evidence gets rewritten before it is used.

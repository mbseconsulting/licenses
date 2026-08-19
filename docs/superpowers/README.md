# Design specs and implementation plans

This folder holds the design specs and implementation plans behind non-trivial changes to this
repository. `specs/` captures *what and why*; `plans/` captures *how, in what order, tested how*.
`assets/` holds supporting files a spec references. `archive/` holds documents whose work has
shipped, in the same `specs/` and `plans/` split.

The full convention ships as the `recording-a-design-doc` skill in
[`.claude/skills/`](../../.claude/skills/). It is generated — edit it in
[mbseconsulting/.conventions](https://github.com/mbseconsulting/.conventions), never here.

## Conventions

- **Filename:** `YYYY-MM-DD-<slug>.md` for plans, `YYYY-MM-DD-<slug>-design.md` for specs. The date is
  the day the document was drafted and never changes.
- **Status line:** every document carries a `**Status:**` line as the first bold metadata line under
  its `# Title`. This is the single source of truth for "is it done" —
  `grep -rn "Status:" docs/superpowers` answers it.
- **Shipped form:** append the reference when a document ships, e.g. `Done — merged in #6 (0794d2a)`
  or `Implemented — #4`.

### Status vocabulary

| Type | States (early → late) |
|------|-----------------------|
| Spec | `Draft` → `In review` → `Approved` → `Implemented` → `Superseded` |
| Plan | `Draft` → `Ready` → `In progress` → `Done` → `Abandoned` |

A spec is `Implemented` once the plan that realizes it merges. A plan is `Done` once its branch merges.

### Archiving

A document moves to `archive/` when its status reaches a terminal state: `Implemented` or `Superseded`
for a spec, `Done` or `Abandoned` for a plan. Move it with `git mv` in the same change that flips the
status line and the index row. Nothing is deleted, because the reasoning behind a decision outlives
the code that implemented it.

## Index

Newest first. Update this table and the document's own `**Status:**` line together.

### Active

None. This repository has no design records yet.

### Archived

None.

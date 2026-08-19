---
name: recording-a-design-doc
description: Writes, files, updates or closes out a design spec or an implementation plan under docs/superpowers/. Use when drafting a spec or plan, when work described by one ships, and whenever the user asks to record a design, archive a plan, update a status, or where a design document belongs.
metadata:
  version: 1.0.0
  source: mbseconsulting/.conventions
---

# Recording a design document

This file is generated. Edit it in
[mbseconsulting/.conventions](https://github.com/mbseconsulting/.conventions), not here.

## The tree

`docs/superpowers/` holds the reasoning behind non-trivial changes.

| Directory | Holds |
|---|---|
| `specs/` | *What and why* |
| `plans/` | *How, in what order, tested how* |
| `assets/` | Supporting files a spec references, such as benchmarks and fixtures |
| `archive/` | Documents whose work has shipped, in the same `specs/` and `plans/` split |

## Filenames

A plan is `YYYY-MM-DD-<slug>.md`. A spec is `YYYY-MM-DD-<slug>-design.md`. The date is the day the
document was drafted and never changes, including when the document moves to `archive/`.

## The status line

Every document carries a `**Status:**` line as the first metadata line under its `# Title`, before
any other content. This is the single source of truth for whether the work is done.

| Type | States, early to late |
|---|---|
| Spec | `Draft` → `In review` → `Approved` → `Implemented` → `Superseded` |
| Plan | `Draft` → `Ready` → `In progress` → `Done` → `Abandoned` |

A spec reaches `Implemented` once the plan realizing it merges. A plan reaches `Done` once its branch
merges.

Append the reference when a document ships, as in `Done — merged in #6 (0794d2a)` or
`Implemented — #4`. **The separator is an em dash.** A hyphen in its place leaves the reference
inside the status token, so `Done - merged in #6` reads as an invalid state rather than a shipped one.

## Closing a document out: three things move together

A document reaching a terminal status — `Implemented` or `Superseded` for a spec, `Done` or
`Abandoned` for a plan — moves to `docs/superpowers/archive/`, keeping its filename.

Do all three in one change:

1. Flip the `**Status:**` line.
2. `git mv` the file under `docs/superpowers/archive/`, into the same `specs/` or `plans/`
   subdirectory.
3. Update its row in `docs/superpowers/README.md`.

A terminal status outside `archive/` and a live status inside it are both violations, and the weekly
scan reports each.

## The index

`docs/superpowers/README.md` indexes every document in a table — Document, Type, Date, Status, Ref —
split into **Active** and **Archived** sections. Every document carries a row, and every row links a
document that exists.

Nothing is deleted. The reasoning behind a decision outlives the code that implemented it. An
archived document is a historical record rather than a maintained page: read it for the reasoning
behind a decision, never as a description of current behaviour.

---
name: writing-documentation
description: Places and writes a documentation page in an mbseconsulting repository, following Diataxis. Use when adding, moving, splitting or rewriting a page under docs/, when a README section outgrows the README, and whenever the user asks where a page belongs or how to document something.
metadata:
  version: 1.0.0
  source: mbseconsulting/.conventions
---

# Writing documentation

This file is generated. Edit it in
[mbseconsulting/.conventions](https://github.com/mbseconsulting/.conventions), not here.

## The README and the guide

`README.md` states what the repository is, who it is for, and how to start. It stays short enough to
read in one sitting, and it links `docs/README.md` for everything else. A subject that outgrows a
README section moves into `docs/` and leaves a link behind.

`docs/README.md` indexes the guide.

## Place the page by asking what the reader is doing

| Group | Orientation | The reader is asking |
|---|---|---|
| `docs/tutorials/` | Learning | Teach me, from nothing, in order. |
| `docs/how-to/` | Task | I know why I am here. Solve this one problem. |
| `docs/reference/` | Lookup | State the facts, completely and dryly. |
| `docs/explanation/` | Understanding | Why is it built this way? |

A page belongs to exactly one group. Keeping the groups apart is what stops a page growing into a
manual.

Ask what the reader is doing rather than what the page is about. One subject yields a tutorial, a
how-to guide, a reference page and an explanation, and each belongs in a different group. No script
makes this judgement, so getting it right here is the only time it gets made.

## Ownership

One repository owns a given document. A repository that consumes the result links it and keeps no
copy — of a page, a command list, or a design record.

A file the sync reconciles is the exception rather than a violation: the generated `.claude/` files
are copies by design, marked as generated, and their drift is reported. A copy inherited by *clone*
has no such reconciliation. Nothing updates it, so it rots from the first change its owner makes, in
every repository created since.

Before copying anything, ask which repository owns it, and link that instead.

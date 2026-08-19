# Licences documentation

These pages are for the people who publish MBSE Consulting's licence texts and for the engineers who
apply them to a deliverable.

Pages are grouped by what the reader is doing, following the [Diátaxis](https://diataxis.fr/)
convention. A page belongs to one group. Keeping the groups apart is what stops any single page from
growing into a manual.

## Tutorial

Learning-oriented. One guided path, read once, in order, by someone starting from nothing.

| Page | Covers |
|------|--------|
| [Apply a licence to a deliverable](tutorials/apply-a-licence.md) | Licensing a deliverable end to end, for the first time |

## How-to guides

Task-oriented. Each page solves one problem for a reader who already knows why they are there.

| Page | Covers |
|------|--------|
| [Publish a new licence version](how-to/publish-a-new-version.md) | Issuing a new version when the text changes |
| [Verify a published text](how-to/verify-a-published-text.md) | Confirming the served bytes, content type and DNS |

## Reference

Lookup-oriented. Complete and dry: the versions, the paths, the text conventions.

| Page | Covers |
|------|--------|
| [Published licences](reference/published-licences.md) | Every published version, its identifier and its URL |
| [Repository layout](reference/repository-layout.md) | Paths, branch protection and publishing settings |

## Explanation

Understanding-oriented. Why the design is what it is, and which alternatives were rejected.

| Page | Covers |
|------|--------|
| [Why a published version never changes](explanation/immutable-versions.md) | The immutability rule and what enforces it |
| [Why the licences are hosted on GitHub Pages](explanation/why-github-pages.md) | The hosting choice, and why not Squarespace |

## Design records

[`superpowers/`](superpowers/README.md) holds design specs and implementation plans, each carrying a
status line. Those records document decisions as they were made, so they are not maintained as the
repository moves. Read them for reasoning, and read the pages above for current behaviour.

## Conventions

The `writing-documentation` skill in [`.claude/skills/`](../.claude/skills/) carries the
documentation layout shared across every `mbseconsulting` repository. It is generated — edit it in
[mbseconsulting/.conventions](https://github.com/mbseconsulting/.conventions), never here.

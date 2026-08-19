# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this
repository.

## What this project is

This repository publishes the licence texts under which MBSE Consulting supplies its software. It is
public, and it contains no code and no build. GitHub Pages serves the repository root, so each file
resolves at the path it occupies.

[`docs/README.md`](docs/README.md) indexes the guide. Read
[Repository layout](docs/reference/repository-layout.md) for the paths and the protection settings,
and [Published licences](docs/reference/published-licences.md) for the versions and their text
conventions.

## The rule that governs every change

**A published version is immutable.** Never edit the text of a version that has been published, not
for a typographical fix and not for a clarification. Delivered material carries the URL in its file
headers, and Section 3.4 of the licence binds each recipient to the version supplied.

Treat any request to fix, improve, or update a licence under an existing version number as a request
for a new version, and say so before editing anything. Follow
[Publish a new licence version](docs/how-to/publish-a-new-version.md).
[Why a published version never changes](docs/explanation/immutable-versions.md) carries the
reasoning.

## Contributing

`main` accepts no direct pushes, from anyone, including organisation owners. Every change reaches it
through a pull request:

```shell
git switch -c <type>/<short-description>
# edit, commit
git push -u origin HEAD
gh pr create --fill
gh pr merge --squash --delete-branch
```

An owner may merge a pull request without a second approval, so the flow costs one command more than
a direct push and leaves a reviewable record of every change to a published text. Squash is the only
merge method the repository accepts. Force-pushing `main` and deleting it are blocked outright, with
no bypass.

The repository is public, so anyone may fork it and open a pull request. Nobody outside the
organisation can push, merge, or run a workflow without an owner approving the run.

## Verifying a change

[Verify a published text](docs/how-to/verify-a-published-text.md) covers the deployment, the content
type, and the DNS failure that looks like an outage. Confirm a notice against its licence text with:

```shell
diff <(sed -n '/Copyright \[yyyy\]/,$p' software/1.0.txt | sed 's/^ *//' | sed '/^$/d') \
     <(sed 's/^ *//' software/1.0-header.txt | sed '/^$/d')
```

Both sides strip leading whitespace, because the appendix indents the notice within the licence text
while the standalone file does not.

## Documentation and conventions

`docs/` documents this repository, organised by what the reader is doing. A page belongs to one
group; add a page by following the `writing-documentation` skill rather than by extending an existing
page.

## Organization conventions

The shared `mbseconsulting` conventions ship as skills in [`.claude/skills/`](.claude/skills/).
Invoke the one that matches what you are doing, rather than reading them all:

| Doing this | Use |
|---|---|
| Writing a commit, branch or pull-request title | `naming-commits-and-branches` |
| Opening an issue or a pull request | `opening-issues-and-prs` |
| Releasing, publishing or bumping a version | `cutting-a-release` |
| Adding or moving a page under `docs/` | `writing-documentation` |
| Writing or closing a spec or plan | `recording-a-design-doc` |

Those skills are generated, as are the templates under `.github/`. Edit them in
[mbseconsulting/.conventions](https://github.com/mbseconsulting/.conventions), never here, because a
sync overwrites local changes.

A `PreToolUse` hook at `.claude/hooks/gh-guard.sh` blocks a `gh issue create` or `gh pr create` whose
body omits a required section. Write the body to an **absolute literal path** and pass `--body-file`;
the hook reads the command before the shell expands it, so `$(mktemp)` or `"$TMPDIR/body.md"` is
denied even when the file exists.

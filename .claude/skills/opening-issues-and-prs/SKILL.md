---
name: opening-issues-and-prs
description: Writes the body of a GitHub issue or pull request to the mbseconsulting conventions. Use before running gh issue create or gh pr create, when a PreToolUse hook denies either call, and whenever the user asks to open, file, or raise an issue or a pull request.
metadata:
  version: 1.0.0
  source: mbseconsulting/.conventions
---

# Opening issues and pull requests

This file is generated. Edit it in
[mbseconsulting/.conventions](https://github.com/mbseconsulting/.conventions), not here.

## Pass the body through a file

Write the body to a file and pass `--body-file`. Shell quoting mangles markdown passed through
`--body`.

The path must be **absolute and literal**. The hook reads the command before the shell expands it, so
a path carrying a shell variable, a `~`, or a glob does not resolve and the call is denied even
though the file exists.

    ✅  --body-file /tmp/pr-body.md
    ❌  --body-file "$(mktemp)"
    ❌  --body-file "$TMPDIR/body.md"
    ❌  --body-file ~/pr-body.md

## Required sections

A body omitting any required heading is denied. Each heading is a markdown heading, at any level.

**A bug report** carries:

## What happens
## Failure scenario
## Environment

**A feature request** carries:

## Problem
## Proposed change
## Impact on users

**A pull request** carries:

## What & why
## The part worth reviewing closely
## Testing
## Impact on consumers
## Not in scope
## Checklist

## Release pull requests

A pull request titled `chore(release): X.Y.Z` is measured against `What & why` alone. A version bump
has no testing narrative and no scope discussion, and it does have a payload worth naming.

No title skips the check. An empty body is denied under any title, and a title that misses the
version shape — `chore(release): 1.9.0-rc1`, or `chore(release): tidy up` — is measured against all
six sections.

The reduced set applies to pull requests alone. An issue titled `chore(release): 1.8.0` is measured
against the bug and feature shapes.

## The checklist line

A repository that cuts releases carries a one-line release note in the pull request's checklist,
which feeds the release notes. The line applies whether or not the repository publishes an artifact
to Nexus. Delete it in a repository that releases nothing.

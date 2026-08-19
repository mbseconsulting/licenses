---
name: naming-commits-and-branches
description: Names a commit subject, a branch, or a pull-request title to the mbseconsulting conventions. Use before running git commit, git checkout -b, git switch -c, or gh pr create, and whenever the user asks which commit type to use, how to name a branch, or how to title a pull request.
metadata:
  version: 1.0.0
  source: mbseconsulting/.conventions
---

# Naming commits and branches

This file is generated. Edit it in
[mbseconsulting/.conventions](https://github.com/mbseconsulting/.conventions), not here.

## Commit subjects

A subject follows Conventional Commits, restricted to eight types:

    feat  fix  docs  chore  refactor  test  build  ci

The shape is `<type>[(<scope>)][!]: <subject>`.

    feat: add a prune mode
    fix(sync): require a value after --repo
    feat!: drop Java 11

A breaking change carries `!` after the type and before the colon. Nothing detects a breaking change
for you. Decide, then mark it.

## Pull-request titles

A pull-request title follows the same shape, because a squash merge turns the title into the commit
subject. A release pull request is titled `chore(release): X.Y.Z`, which is an ordinary subject
carrying a `release` scope.

## Branch names

A branch follows `<type>/<slug>`, where `<type>` comes from the same eight types and `<slug>` is
lower case, opening with a letter or a digit.

    fix/codegen-classpath
    docs/close-codegen-plan

## What enforces this

The `gh-guard.sh` hook checks all three shapes. It reads a command before the shell runs it and takes
the subject from `git commit -m`, the branch name from `git checkout -b`, `git switch -c` or
`git branch <name>`, and the title from `gh pr create --title`. It denies a subject, a name or a title
that misses the shape. The `!` marker stays yours, because nothing tells a breaking change from an
ordinary one.

The hook allows whatever it cannot read. A branch name or a pull-request title built from a shell
variable passes, because renaming a branch and editing a title each cost one command. The hook denies
such a commit message, because the subject becomes permanent the moment the commit exists.

Follow the rules whatever the hook does. A commit made in a terminal, an IDE or a web edit never
reaches it, and a wrong type reaches the release notes and stays there.

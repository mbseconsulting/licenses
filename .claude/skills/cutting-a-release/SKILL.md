---
name: cutting-a-release
description: Cuts a release of an mbseconsulting repository — bump, build, publish, tag, GitHub release — and writes the release notes. Use when the user asks to release, cut a version, publish, ship, bump the version, or tag a release, and before running gradlew publish or gh release create.
metadata:
  version: 1.0.0
  source: mbseconsulting/.conventions
---

# Cutting a release

This file is generated. Edit it in
[mbseconsulting/.conventions](https://github.com/mbseconsulting/.conventions), not here.

## First, read the version

Every repository names its version `X.Y.Z`, with an optional `-SNAPSHOT` suffix, whatever it builds.
The suffix declares the state, and the state decides how many steps run.

| State | Version | Publishes to | Tag | GitHub release | Release notes |
|---|---|---|---|---|---|
| release | `X.Y.Z` | the releases repository | `vX.Y.Z` | required | required |
| snapshot | `X.Y.Z-SNAPSHOT` | the snapshots repository | never | never | never |

A snapshot is bumped, built and published, and then you stop. It carries no tag, no GitHub release
and no release notes, because a snapshot is mutable while a GitHub release names a fixed tag. An
author republishes one snapshot version many times over a working week, and each publish replaces the
artifact the previous one left. Tagging a snapshot is a defect.

## Then, decide what this repository is

Read `build.gradle.kts` in the repository root.

| It contains | The repository is | Version lives in |
|---|---|---|
| a `gradlePlugin {` block | `forge` | `version` in `gradle.properties` |
| `id("com.mbseconsulting.forge")` | a Forge consumer | `com.mbseconsulting.forge.resource.humanVersion` in `gradle.properties` |
| neither, or no such file | anything else | the repository's own `docs/how-to/` page states it |

The third row publishes nothing to Nexus and releases through GitHub like every other repository. Its
own `docs/how-to/` page states where the version lives and which command builds it, and the bump, the
tag, the GitHub release and the notes are unchanged. A repository that releases nothing declares no
version to tag and reaches no step below.

Read the repository's own release page under `docs/how-to/` before acting, whatever the kind. It owns
any detail beyond the commands below. When the page is absent or carries no such detail, ask the user
where the version lives and which command builds it rather than guessing, and write the page as part
of this release.

## The five steps are one act

**A published artifact and a GitHub release are one act.** Every version that reaches the artifact
repository gets a matching tag and a GitHub release on the same day. Two versions of `forge`
reached Nexus with neither and were backfilled months later. Do not stop after step 3.

### 1. Bump the version

Edit the version where the table above says it lives. The suffix routes publication: a `-SNAPSHOT`
version goes to the snapshots repository, anything else goes to releases.

### 2. Build

For `forge` and for a consumer:

    ./gradlew build

For anything else, run what the repository's own `docs/how-to/` page states.

Confirm the build is green, `spotlessCheck` included.

From Forge 2.1.0 onward, a consumer's `check` runs the validators, the unit tests, the
integration suite and the two JaCoCo tasks. A full build therefore forks a JVM against the CATIA
Magic installation, takes a licence seat, and fails below 80% instruction coverage. A release that
fails there is not ready to publish. A consumer on Forge 2.0.0 or earlier builds green without those
tasks, so name them as well:

    ./gradlew build integrationTest jacocoTestReport jacocoTestCoverageVerification

### 3. Publish

For `forge`:

    ./gradlew publish

For a consumer:

    ./gradlew publishAll

A repository of the third kind publishes no artifact and skips this step.

### 4. Tag and push

A snapshot stops at step 3. Steps 4 and 5 run for a release alone.

Tags are lightweight and carry a `v` prefix.

    git tag v1.6.0 && git push origin v1.6.0

### 5. Create the GitHub release

    gh release create v1.6.0 --title "1.6.0 (August 3rd, 2026)" --notes-file /tmp/notes.md

## Release notes

Every release carries three sections, in this order:

## Highlights
## What's changed
## Compatibility

A repository publishing to Nexus — `forge` and its consumers — carries two further sections
after them:

## Install
## Download Link

Each pull request since the last release carries a one-line release note in its checklist. Those
lines feed **What's changed**. Features come first, naming what a consumer opts into and what it
replaces; smaller items take one line each with an issue or pull-request reference.

## The release pull request

The pull request carrying the version bump is titled `chore(release): X.Y.Z` and satisfies a reduced
section set. The `opening-issues-and-prs` skill covers it.

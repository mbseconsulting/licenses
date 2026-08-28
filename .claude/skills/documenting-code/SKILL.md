---
name: documenting-code
description: Writes or reviews the prose beside code — a KDoc block, a docstring, an inline comment, a test name. Use when adding or changing any of them, when reviewing a diff that touches them, and whenever a comment explains why the code is not the obvious thing.
metadata:
  version: 1.0.0
  source: mbseconsulting/.conventions
---

# Documenting code

This file is generated. Edit it in
[mbseconsulting/.conventions](https://github.com/mbseconsulting/.conventions), not here.

This covers a KDoc block, a docstring, an inline comment and a test name. Each one ships: a KDoc or a
docstring reaches a consumer inside the published artifact, and a test name reaches every report the
build writes.

## State what is

Prose beside code describes the code as it stands. Ask one question of each sentence:

**Could a reader who has never seen an earlier version understand this?**

A sentence answering no describes a decision rather than the code.

A trap and a piece of history resemble each other, because both explain why the code avoids the
obvious thing. One test separates them.

**Keep the note when a maintainer could reach for that alternative tomorrow**, and state it as a fact
about the code as it stands. **Delete the note when the alternative is what the code used to do.**

| Verdict | Prose |
|---|---|
| Delete | "This disproved an earlier claim in this same batch, and the KDoc was corrected." |
| Restate | "The claim that motivated reading `partWithPort` was not reproduced, and is carried over from the spec rather than measured here." |
| Restated | "`isDelegation` reads `partWithPort`. `Connector.kind` is a separate question, and nothing here exercises their disagreement." |

The restated note survives because a maintainer will reach for `kind`. The fact earns its place. The
account of who claimed what, and when, does not.

These phrases mark history plainly: *no longer*, *used to*, *previously*, *originally*, *was
corrected*, *an earlier claim*, *this disproved*, *in this same batch*. So does a batch, plan or
pull-request number offered as the reason for a behaviour.

Antithesis hides it. A sentence shaped *"X, not Y"* where nothing else names Y is usually a
correction compressed into one clause. State X and stop.

## Name only what you own

A repository names its own subject, the shared toolchain — `forge`, `anvil`, `.conventions` — and the
tool vendor. It names nothing else: no other repository, no other repository's client, no sibling
resource. `writing-documentation` carries the rule and its test.

A test name carries the rule too. `an object flow qualifies both ends` states behaviour and names
nothing else. Appending a contrast — the same name, plus `unlike` and another organization's library
— names something this repository does not own, and carries it into every test report the build
writes.

## Where history goes

The design record holds it. `recording-a-design-doc` describes that home: an archived document is a
historical record rather than a maintained page, read for the reasoning behind a decision and never
as a description of current behaviour. The commit message and the pull-request body hold the rest.

Nothing is lost. A reader consults the design record for reasoning, and the code for behaviour.

---
name: documenting-code
description: Writes or reviews the prose beside code — a KDoc block, a docstring, an inline comment, a test name. Use when adding or changing any of them, when reviewing a diff that touches them, whenever a comment explains why the code is not the obvious thing, and whenever a doc tag such as @param, @return or @throws is added, removed or questioned.
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

## Prose or a tag

A tag and a sentence are not two styles for one fact. They render differently and answer different
questions, so one rule places them:

**A tag carries what the signature cannot.**

A Kotlin signature already names the receiver, the nullability, the default values and the generic
bounds; a Python signature annotates its types. A `@param` or a `@return` restating any of that is
transcription. Neither language says what a body throws, which is why `@throws` is the tag that
almost always earns its place.

| Tag | Write it |
|---|---|
| `@throws` | For every exception a body can raise, naming the condition that raises it. |
| `@property` | For a constructor `val`. Nothing else can document one. |
| `@param`, `@return` | Only for a fact the type omits: what null means, empty versus null, ordering, laziness, the role of a fallback. |

Ask one question of each tag before writing it:

**Would a reader holding only this member's page still be missing the fact?**

A tag answering no is filler. `@param element the element` fails the question. `@param element the
element whose tag is read, whose project must be open` passes it.

The question is the member's page rather than the file because that page is what ships. A published
artifact carries the rendered reference and no source, so a reader lands on one member, stripped of
the class prose around it, and decides from what they find there.

Prose carries what a reader reads: what the declaration does, and when to reach for it. Tags carry
what a reader scans: the failure modes, and the per-slot facts a table holds. A declaration that
cannot fail and returns what its name says needs no tag, and most declarations are that.

Where the prose already names the conditions in order, a tag repeating them is a second copy that
ages separately. State it once.

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

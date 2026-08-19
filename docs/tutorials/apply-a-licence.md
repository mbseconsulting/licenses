# Apply a licence to a deliverable

This tutorial takes you from a deliverable that carries no licence to one that carries the MBSE
Consulting Software Licence correctly. It assumes you have the deliverable on disk and nothing else.
Work through it once; afterwards, use
[Publish a new version](../how-to/publish-a-new-version.md) and the
[reference pages](../reference/published-licences.md) instead.

## Before you start

Choose the licence version the Engagement Contract records. This tutorial uses 1.0, the only version
published today.

## 1. Copy the licence text

Fetch the canonical text and place it at the root of the deliverable:

```shell
curl -o LICENSE.txt https://licenses.mbseconsulting.com/software/1.0.txt
```

Section 8 of the licence requires every copy and every distribution to preserve this file. Commit it
alongside the material it licenses.

## 2. Attach the header notice to each source file

Fetch the notice:

```shell
curl -O https://licenses.mbseconsulting.com/software/1.0-header.txt
```

Paste it into the top of each source file, inside a comment syntax the file format supports. Replace
`[yyyy]` with the year of first publication and `[name]` with the name of the product or deliverable.
A Java file receives it as a block comment; an XML profile receives it inside `<!-- -->`.

Section 6.1(d) forbids any recipient from removing or altering the notice, so it travels with the
file for as long as the file exists.

## 3. Record the identifier

Wherever a manifest, package descriptor, or SPDX field records a licence, write:

```
LicenseRef-mbseconsulting-software-1.0
```

The `LicenseRef-` prefix marks a licence absent from the SPDX Licence List. Tools that validate
against that list accept the prefixed form and reject a bare name.

## 4. Check your work

The deliverable now carries three things: the licence copy at its root, the notice in each source
file, and the identifier in its manifest. A recipient who reads any one of them reaches the same
text at the same URL.

## Where to go next

- [Publish a new version](../how-to/publish-a-new-version.md), when the licence text itself changes.
- [Why a published version never changes](../explanation/immutable-versions.md), which explains why
  step 3 pins a version rather than naming the licence.

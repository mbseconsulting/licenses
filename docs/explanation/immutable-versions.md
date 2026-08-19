# Why a published version never changes

A licence text published here carries its own URL in two places: the banner at the top, and the file
header notice in the appendix. Delivered material copies that notice into every source file, and
bills of materials record the matching identifier. Those strings leave the building with the
deliverable, and no later action recalls them.

Section 3.4 of the licence binds each recipient to the version supplied. A recipient auditing a
delivery from an earlier year must therefore retrieve the text that governed that delivery, not a
later one. Editing a published file breaks that guarantee silently: the URL still resolves, the
recipient still reads a document, and the document no longer states what they agreed to.

## What this rules out

Correcting a typographical error, clarifying an ambiguous clause, and changing a substantive
obligation are all the same operation from the repository's point of view. Each issues a new version
at a new path with a new identifier. Nothing distinguishes a harmless edit from a harmful one once
the file has been fetched by someone we cannot identify.

## How the repository enforces it

Branch protection blocks force-pushes and deletion of `main`, with no bypass for anyone including
organisation owners. History therefore only grows. A published file can be superseded by a later
version, and cannot be rewritten or erased.

Adding a new version leaves earlier files untouched, so an old identifier keeps resolving for as long
as the repository exists.

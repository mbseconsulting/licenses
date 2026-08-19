# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this
repository.

## What this project is

This repository publishes the license texts under which MBSE Consulting supplies its software. It is
public. It contains no code and no build: GitHub Pages serves the repository root, so each file
resolves at the path it occupies.

Delivered artifacts carry the URL of the applicable text in their file headers, and bills of
materials record the matching `LicenseRef-` identifier. Those strings leave the building and cannot
be recalled.

## The rule that governs every change

**A published version is immutable.** Never edit the text of a version that has been published, not
for a typographical fix and not for a clarification. Section 3.4 of the license binds each recipient
to the version supplied, and earlier paths must keep resolving to the text that governed the
delivery they document.

Treat any request to fix, improve, or update a license under an existing version number as a request
for a new version, and say so before editing anything.

## Layout

One file per version, at the path that forms its URL. No directories per version, no HTML rendering,
no redirects: the URL is a file path and stays valid under any static host.

| File | URL | Role |
|---|---|---|
| `software/1.0.txt` | `https://licenses.mbseconsulting.com/software/1.0.txt` | The license text. |
| `software/1.0-header.txt` | same directory | The file header notice, for pasting into source files. |
| `CNAME` | — | Binds the GitHub Pages site to the custom domain. |

The header notice carries a version and a URL, so it is versioned alongside the text it belongs to.
It reproduces the Appendix of the license verbatim; verify with:

```shell
diff <(sed -n '/^      Copyright \[yyyy\]/,$p' software/1.0.txt | sed 's/^      //' | sed '/^$/d') \
     <(sed '/^$/d' software/1.0-header.txt)
```

## Publishing

GitHub Pages deploys `main` from the repository root. The `CNAME` file binds the site to
`licenses.mbseconsulting.com`, which requires a matching DNS record at the registrar:
`licenses CNAME mbseconsulting.github.io`. Squarespace serves the apex domain and cannot host these
texts itself, because it assigns uploaded files a CDN URL that cannot be chosen or kept stable.

Check a deployment with:

```shell
curl -sI https://licenses.mbseconsulting.com/software/1.0.txt | head -3
```

The response must carry `content-type: text/plain`. An HTML content type means the request reached
the apex site rather than Pages.

## Issuing a new version

1. Copy the current text to `software/<new>.txt` and the notice to `software/<new>-header.txt`.
2. Inside both files, update the version, the `LicenseRef-mbseconsulting-software-<new>` identifier,
   the date, and the URL. Each text states its own URL twice: in the banner and in the Appendix.
3. Leave every earlier file untouched.
4. Add the row to the README table. Earlier rows stay, so that an old identifier still resolves.

## Text conventions

The license text wraps at 79 columns, indents body text by three spaces, centres the banner on
column 35, and uses no characters outside ASCII. Preserve that formatting. Reflowing a paragraph
changes what the published text shows to a recipient who fetched it earlier.

## Organization conventions

The shared `mbseconsulting` conventions ship as skills from
[mbseconsulting/.conventions](https://github.com/mbseconsulting/.conventions). This repository is not
yet enrolled in that sync, so `.claude/skills/` is absent. The conventions still apply to commit
names, branch names, issues, and pull requests here.

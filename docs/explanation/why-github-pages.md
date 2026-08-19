# Why the licences are hosted on GitHub Pages

The licence texts are served from GitHub Pages on the subdomain `licenses.mbseconsulting.com`, while
`mbseconsulting.com` itself runs on Squarespace. The split follows from one requirement: a recipient
must fetch the licence as plain text at a URL that never changes.

## Why not Squarespace

Squarespace hosts the main site and could, in principle, hold these files. It cannot hold them at a
usable URL. Uploaded files receive a URL that the Squarespace CDN assigns automatically, and the
documentation states plainly that the URL cannot be chosen or changed. Re-uploading a file produces a
different URL. A URL frozen into the file headers of delivered material cannot depend on that.

A Squarespace page can carry the text in a code block, but it renders as HTML with site navigation
around it, and its slug rejects the dot in a version number. Neither the content type nor the path
survives.

## Why a subdomain rather than a path

GitHub Pages serves a repository at the root of its custom domain, so a custom domain on this
repository drops the repository name from the path. `licenses.mbseconsulting.com/software/1.0.txt`
follows directly; `mbseconsulting.com/licenses/software/1.0.txt` would require the Squarespace site
to proxy that path to GitHub, adding a component that can fail independently.

The subdomain also leaves the apex domain untouched. Adding one DNS record changed nothing about the
main site.

## What this buys

GitHub Pages serves a `.txt` file as `text/plain; charset=utf-8` with no configuration. The URL is a
file path, so it stays valid under any static host, and moving away later needs only the same paths
on another server. No redirect rule stands between a recipient and the text.

## What it costs

GitHub Pages requires a public repository on the organisation's current plan. The licence texts are
published documents, so their visibility costs nothing. The repository is public for that reason
alone.

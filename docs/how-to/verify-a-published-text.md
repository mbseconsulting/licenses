# Verify a published text

Use this after a deployment, or whenever you need to confirm that the text a recipient fetches
matches the text in the repository.

## Confirm the content type

```shell
curl -sI https://licenses.mbseconsulting.com/software/1.0.txt | head -3
```

The response must carry `content-type: text/plain; charset=utf-8`. An HTML content type means the
request reached the apex site rather than GitHub Pages, which
[Why the licences are hosted on GitHub Pages](../explanation/why-github-pages.md) explains.

## Confirm the bytes

```shell
curl -s https://licenses.mbseconsulting.com/software/1.0.txt | diff - software/1.0.txt
```

Empty output means the published bytes and the repository agree.

## When DNS answers incorrectly

A resolver that cached an answer from before the record existed returns nothing, and `curl` then
fails with exit code 6 rather than reaching GitHub. Query a public resolver to separate a caching
problem from a hosting problem:

```shell
dig @1.1.1.1 +short licenses.mbseconsulting.com
```

The answer names `mbseconsulting.github.io` and four addresses in `185.199.108-111.153`. Where a
public resolver answers and your own does not, the stale entry sits in your resolver or your router,
not in DNS. Reach the site directly meanwhile:

```shell
curl -I --resolve licenses.mbseconsulting.com:443:185.199.108.153 \
     https://licenses.mbseconsulting.com/software/1.0.txt
```

## Confirm the deployment itself

```shell
gh api repos/mbseconsulting/licenses/pages --jq '{status, https_enforced}'
```

`status` reads `built` once the deployment completes.

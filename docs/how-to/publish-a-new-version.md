# Publish a new licence version

Use this procedure when the licence text changes for any reason, including a typographical
correction. A published version never changes, so every change ships as a new version. See
[Why a published version never changes](../explanation/immutable-versions.md) for the reasoning.

## 1. Choose the version number

Version numbers take the form `MAJOR.MINOR`. A minor version clarifies wording without changing the
rights or the obligations of any party. A major version changes them.

## 2. Copy the previous version

```shell
git switch -c feat/software-licence-<new>
cp software/<previous>.txt software/<new>.txt
cp software/<previous>-header.txt software/<new>-header.txt
```

## 3. Edit the new files only

Leave every earlier file untouched. In both new files, update:

| What | Where |
|---|---|
| Version number and date | the banner, and the notice in the appendix |
| Identifier | `LicenseRef-mbseconsulting-software-<new>` |
| Canonical URL | twice in the licence text, once in the notice |

The licence text wraps at 79 columns, indents body text by three spaces, centres the banner on
column 35, and uses ASCII alone. Preserve that formatting; the published page reproduces the
whitespace exactly.

## 4. Check the notice against the appendix

The standalone notice reproduces the appendix of the licence. Confirm they agree:

```shell
diff <(sed -n '/Copyright $YEAR/,$p' software/<new>.txt | sed 's/^ *//' | sed '/^$/d') \
     <(sed 's/^ *//' software/<new>-header.txt | sed '/^$/d')
```

Empty output means they agree.

## 5. Add the row and open a pull request

Add the new row to the table in [`README.md`](../../README.md), keeping every earlier row so that an
old identifier still resolves. Then:

```shell
git push -u origin HEAD
gh pr create --fill
gh pr merge --squash --delete-branch
```

`main` accepts no direct pushes. GitHub Pages deploys the merge within a minute.

## 6. Verify the published text

Follow [Verify a published text](verify-a-published-text.md).

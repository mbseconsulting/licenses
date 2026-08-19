#!/usr/bin/env bash
# gh-guard.sh — PreToolUse hook.
#
# Holds four things to the organization conventions, and passes silently when each
# one conforms:
#
#   - the body of a `gh issue create` or a `gh pr create`, against the required headings;
#   - the subject of a `git commit -m`, against commit.subjectPattern;
#   - the name a `git checkout -b`, `git switch -c` or `git branch <name>` creates,
#     against branch.pattern;
#   - the title of a `gh pr create`, against commit.subjectPattern, because a squash
#     merge turns that title into the permanent commit message.
#
# Never exits non-zero: exit 1 is a non-blocking error and exit 2 discards
# stdout. A failure to read the contract allows the call rather than blocking
# work on a broken hook.
set -u

allow() { exit 0; }

deny() {
  jq -n --arg r "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $r
    }
  }'
  exit 0
}

command -v jq >/dev/null 2>&1 || allow

CONTRACT="${GH_GUARD_CONTRACT:-${CLAUDE_PROJECT_DIR:-.}/.claude/conventions.json}"
[ -f "$CONTRACT" ] || allow

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""' 2>/dev/null) || allow
[ -n "$cmd" ] || allow

# A trailing backslash continues the command onto the next physical line, and
# that is the shape most gh invocations take: the verb, the title and the body
# file each sit on their own line. Fold every continuation into one logical line
# before anything is matched. Without this the guard reads `gh pr create \`
# alone and denies a complete body for want of a --body-file it never saw.
logical=$(printf '%s\n' "$cmd" | awk '{
  line = $0
  while (sub(/\\$/, "", line) && (getline nxt) > 0) line = line " " nxt
  print line
}')

# masked — $logical with heredoc bodies, quote spans that carry over from an earlier physical
# line, and same-line '…'/"…" pairs all blanked to spaces, one output line per input line. A
# heredoc body (`cat > f.md <<EOF` … `EOF`) and a commit message's own body are ordinary physical
# lines to a script that folds only backslash-continuations, and either can carry a line that
# itself reads as `git checkout -b my-branch` or `git commit -m "Backup"` — text describing or
# quoting a command, not a command. $masked exists so line SELECTION below can skip those lines
# without ever touching $logical: extraction always reads the original, unmasked line, because
# blanking a quoted span is exactly what selecting `git checkout -b 'my-branch'` depends on NOT
# happening to the line that is actually chosen.
masked=$(printf '%s\n' "$logical" | awk '
  BEGIN {
    SQ = sprintf("%c", 39)
    DQ = sprintf("%c", 34)
    heredoc_re = "<<-?[[:space:]]*(" SQ "|" DQ ")?[A-Za-z_][A-Za-z0-9_]*(" SQ "|" DQ ")?"
    in_heredoc = 0
    delim = ""
    strip_tabs = 0
    quote = ""
  }
  {
    line = $0
    if (in_heredoc) {
      check = line
      if (strip_tabs) { sub(/^\t+/, "", check) }
      if (check == delim) { in_heredoc = 0 }
      print ""
      next
    }
    if (quote == "" && match(line, heredoc_re)) {
      tok = substr(line, RSTART, RLENGTH)
      strip_tabs = (tok ~ /^<<-/)
      d = tok
      sub(/^<<-?[[:space:]]*/, "", d)
      gsub("(" SQ "|" DQ ")", "", d)
      delim = d
      in_heredoc = 1
      print line
      next
    }
    # A line carrying no quote character needs no masking, whether or not a quote is open coming
    # in — `quote != ""` with no SQ/DQ on this line just means the whole line is already inside an
    # open quote and stays that way, and the span walk below would blank it to the same effect.
    # Deciding here costs one `index()` scan per line instead of entering the walk at all.
    if (index(line, SQ) == 0 && index(line, DQ) == 0) {
      if (quote == "") { print line } else { print "" }
      next
    }
    # Span copying, not a character loop. The rule is per-span, not per-byte: outside a quote every
    # character up to the next quote character is copied unchanged, and inside a quote every
    # character up to and including the closing quote becomes a space. `index()` finds where the
    # span ends and `substr()`/`sprintf()` emit the whole span in one operation.
    #
    # What this removes is the per-byte concatenation. A loop appending to `out` once per character
    # paid for a copy of the whole accumulator every time, which made a long line quadratic in its
    # length: measured against `python3 -c "<script>"` as one line, 0.29s at 50KB, 0.91s at 100KB,
    # 3.3s at 200KB, 12.1s at 400KB and 48.9s at 800KB. The hook runs on every Bash call in every
    # repository, so an agent passing a large script inline stalled it for the better part of a
    # minute. Span copying answers the same 800KB in 0.22s, and that is the shape this fix was for:
    # a long line carrying few, long spans.
    #
    # The residual, stated rather than implied: the cost still grows with spans x line length, since
    # each span re-copies `rest` from where it left off. A very long line carrying thousands of short
    # spans is therefore still slow, and can be slower than the per-byte loop was — measured at 800KB
    # of dense tiny spans, 49.0s before and 92.0s after; an inline escaped-JSON body, where every \"
    # opens or closes a span, 49.1s before and 39.8s after. Anyone benchmarking a dense-quote payload
    # should expect those numbers, not the 0.22s above.
    #
    # `sprintf("%" p "s", "")` takes a width up to the full line length, and mawk — which Ubuntu CI
    # runs — has had sprintf width limits. The blast radius was bounded by execution rather than
    # argued: with $masked truncated the way an aborting awk leaves it, the guard allows the dropped
    # lines and never produces a spurious deny, so the fail-open invariant holds either way.
    out = ""
    rest = line
    while (rest != "") {
      if (quote == "") {
        # The next quote character of either kind, or none — whichever comes first opens the span.
        i1 = index(rest, SQ)
        i2 = index(rest, DQ)
        if (i1 == 0) { p = i2 } else if (i2 == 0) { p = i1 } else { p = (i1 < i2 ? i1 : i2) }
        if (p == 0) { out = out rest; break }
        out = out substr(rest, 1, p - 1) " "
        quote = substr(rest, p, 1)
        rest = substr(rest, p + 1)
      } else {
        # The closing quote, or none. With none the quote stays open into the next line, exactly as
        # the per-byte loop left it, and the rest of this line is blanked.
        p = index(rest, quote)
        if (p == 0) { out = out sprintf("%" length(rest) "s", ""); break }
        out = out sprintf("%" p "s", "")
        quote = ""
        rest = substr(rest, p + 1)
      }
    }
    print out
  }
')

# select_line <pattern> — the ORIGINAL text of the last line of $logical whose MASKED counterpart
# matches <pattern>. Selecting against $masked keeps a heredoc body or a continued/same-line quote
# from being read as an invocation; returning from $logical keeps the selected line's own quoting
# intact for extraction. The alignment that makes this work is the awk pass's own: it prints exactly
# one output line per input line, so line N of $masked is line N of $logical, masked. A blank line in
# $masked is therefore not a missing line — it is a line whose content was entirely masked, and grep
# simply never selects it. $masked can carry FEWER lines than $logical, because command substitution
# strips every trailing newline and a run of fully masked lines at the end blanks itself away, but a
# line number grep finds in $masked always names the matching line in $logical.
select_line() {
  local n
  n=$(printf '%s\n' "$masked" | grep -nE "$1" | tail -1 | cut -d: -f1)
  [ -n "$n" ] || return 0
  printf '%s\n' "$logical" | sed -n "${n}p"
}

# enforced <jq-path> — true when the flag is absent or set to true. A contract that predates the
# flag enforces, and a flag set to false disables the check across every repository through one
# contract edit and a sync, rather than an edit to a shell script in every one of them.
#
# `$1 // true` looks equivalent and is not: jq's `//` treats a literal `false` as an absent value,
# so `.commit.enforce // true` resolves to `true` even when the contract sets `enforce: false`,
# silencing the flag it exists to read. Binding the value with `as` and testing it against `null`
# reads the actual value instead of jq's truthiness.
enforced() {
  local v
  v=$(jq -r "($1) as \$v | if \$v == null then true else \$v end" "$CONTRACT" 2>/dev/null) || return 0
  [ "$v" != "false" ]
}

# The commit matcher. It reads the last line invoking `git commit`, for the reason CREATE_RE reads
# the last matching line: a single Bash call routinely carries a heredoc or an echo naming the same
# command, and either can quote a -m. `git` may follow the start of the line, a shell operator, or
# any whitespace — including plain indentation, and including a word like `then` or `sudo` sitting
# right before it — because $masked, not this alternation, is what keeps prose from matching: a
# `git commit` mentioned inside a quote or a heredoc body reads as blank there before this pattern
# ever sees it.
COMMIT_RE='(^|[;&|(]|[[:space:]])git[[:space:]]+commit([[:space:]]|$)'
commit_line=$(select_line "$COMMIT_RE")

if [ -n "$commit_line" ] && enforced '.commit.enforce'; then
  # A message flag is -m, --message, or a combined short flag carrying m — `git commit -am` is one
  # token, and matching a standalone -m alone let every one of those past unchecked.
  has_message=""
  grep -Eq '(^|[[:space:]])(--message([= ]|$)|-[a-zA-Z]*m([= ]|$))' <<<"$commit_line" && has_message=1

  # Everything the hook cannot read, it allows. --amend without a message changes no subject,
  # --fixup and --squash take subjects git generates, and -F reads the message from a file.
  case "$commit_line" in
    *--fixup*|*--squash*) has_message="" ;;
  esac
  grep -Eq '(^|[[:space:]])(-F|--file)([= ]|$)' <<<"$commit_line" && has_message=""

  if [ -n "$has_message" ]; then
    # The value, unquoted. Four closed-quote passes, mirroring --title, then four more for an
    # unterminated quote.
    #
    # The second group is load-bearing. A message with a body puts its closing quote on a later
    # physical line, so the invocation line reads `git commit -m 'Backup` and no closed-quote
    # pattern matches it. Reading nothing means checking nothing, and a message with a body is what
    # a good commit looks like — the check would have fired only on one-line messages and every
    # multi-paragraph subject would have passed unread. On such a line the rest of the text after
    # the opening quote is exactly the subject, because the subject ends where the line does.
    subject=$(sed -n "s/.*--message[= ]*'\([^']*\)'.*/\1/p" <<<"$commit_line" | tail -1)
    [ -n "$subject" ] || subject=$(sed -n 's/.*--message[= ]*"\([^"]*\)".*/\1/p' <<<"$commit_line" | tail -1)
    [ -n "$subject" ] || subject=$(sed -n "s/.*-[a-zA-Z]*m[= ]*'\([^']*\)'.*/\1/p" <<<"$commit_line" | tail -1)
    [ -n "$subject" ] || subject=$(sed -n 's/.*-[a-zA-Z]*m[= ]*"\([^"]*\)".*/\1/p' <<<"$commit_line" | tail -1)
    [ -n "$subject" ] || subject=$(sed -n "s/.*--message[= ]*'\(.*\)$/\1/p" <<<"$commit_line" | tail -1)
    [ -n "$subject" ] || subject=$(sed -n 's/.*--message[= ]*"\(.*\)$/\1/p' <<<"$commit_line" | tail -1)
    [ -n "$subject" ] || subject=$(sed -n "s/.*-[a-zA-Z]*m[= ]*'\(.*\)$/\1/p" <<<"$commit_line" | tail -1)
    [ -n "$subject" ] || subject=$(sed -n 's/.*-[a-zA-Z]*m[= ]*"\(.*\)$/\1/p' <<<"$commit_line" | tail -1)

    # The first line alone. A message body may say anything; the subject is the rule.
    subject=${subject%%$'\n'*}

    if [ -n "$subject" ]; then
      case "$subject" in
        "Merge "*|"Revert "*|"fixup!"*|"squash!"*) subject="" ;;
      esac
    fi

    if [ -n "$subject" ]; then
      subject_re=$(jq -r '.commit.subjectPattern // empty' "$CONTRACT" 2>/dev/null)

      # The denial ties to a rule that actually exists. With no subjectPattern in the contract —
      # absent, or unreadable — there is nothing to check the subject against, so an unreadable
      # substitution is nothing to deny either.
      case "$subject" in
        *'$'*)
          if [ -n "$subject_re" ]; then
            deny "This commit message carries a shell substitution, so the guard cannot read
the subject it would check.

Resolved text: '$subject'

The guard reads the command as text, before the shell expands it. Pass a
literal subject:

  git commit -m 'feat: describe the change'"
          fi
          ;;
      esac

      if [ -n "$subject_re" ]; then
        rc=0
        grep -Eq "$subject_re" <<<"$subject" 2>/dev/null || rc=$?
        # Exit 1 is a subject that does not match. Exit 2 or above is a pattern grep could not
        # compile, and a contract the hook cannot read allows the call rather than blocking every
        # commit in every repository — check-contract.sh verifies the pattern names the eight
        # types, never that it compiles.
        if [ "$rc" -eq 1 ]; then
          deny "This commit subject does not follow the organization's shape:

  $subject

Use <type>(<scope>)!: <subject>, where the scope and the ! are optional and the
type is one of:

$(jq -r '.commit.types[]' "$CONTRACT" 2>/dev/null | sed 's/^/  - /')

A wrong type reaches the release notes and stays there."
        fi
      fi
    fi
  fi
fi

# The branch matcher reads the creating forms alone. `git branch` listing, deleting, or reporting
# creates nothing, and denying those would block work the rule says nothing about. The alternation
# is deliberately as permissive as COMMIT_RE's, for the same reason: it is $masked, selected
# against below, that keeps a doc string or a heredoc body mentioning `git checkout -b my-branch`
# from being read as an invocation, not this pattern.
BRANCH_RE='(^|[;&|(]|[[:space:]])git[[:space:]]+(checkout[[:space:]]+-b|switch[[:space:]]+-c|branch)([[:space:]]|$)'
branch_line=$(select_line "$BRANCH_RE")

if [ -n "$branch_line" ] && enforced '.branch.enforce'; then
  # The value, unquoted. Three passes, mirroring --title and --body-file: single-quoted,
  # double-quoted, then a bare refname-safe token. Excluding only spaces and quotes from the bare
  # class is not enough —
  # it swallows a trailing shell operator (`git branch | cat` reads `|` as a name) or trailing
  # punctuation (`git checkout -b feat/x; git push` reads `feat/x;` as the name and denies a
  # conforming one) — so the bare pass is constrained to characters a git refname actually uses.
  new_branch=$(sed -n -E "s/.*git[[:space:]]+(checkout[[:space:]]+-b|switch[[:space:]]+-c)[[:space:]]+'([^']*)'.*/\\2/p" \
    <<<"$branch_line" | tail -1)
  [ -n "$new_branch" ] || new_branch=$(sed -n -E 's/.*git[[:space:]]+(checkout[[:space:]]+-b|switch[[:space:]]+-c)[[:space:]]+"([^"]*)".*/\2/p' \
    <<<"$branch_line" | tail -1)
  # The bare pass additionally requires the token to end at a space, a shell operator, a
  # redirection, a closing parenthesis, or the end of the line — not at an arbitrary character.
  # Requiring only a space or end-of-line denied too little: `git checkout -b my-branch; git push`,
  # with no space before the `;`, failed to extract at all and allowed a name that does not
  # conform, which is the exact shape this matcher exists to catch. `<`/`>` are safe to include
  # here, unlike in the `git branch` pass below: `checkout -b`/`switch -c` always take a name as
  # their very next argument, so there is no file-descriptor number for a redirection's leading
  # digit to be confused with — `git checkout -b my-branch>log` has nothing else that boundary
  # could be reading.
  #
  # `git` may follow the start of the line, a shell operator, or plain whitespace — the same
  # alternation as BRANCH_RE, deliberately: $branch_line was already selected against $masked
  # above, so by the time extraction runs here, this line is a real invocation and does not need
  # its own anchor to a command start. A stricter anchor here once denied `if true; then git
  # checkout -b my-branch; fi` and `GIT_AUTHOR_NAME=x git checkout -b my-branch` by allowing them —
  # `then` and `=x` are not a start of line or a shell operator, so a command-start-only anchor
  # never found the name to check.
  [ -n "$new_branch" ] || new_branch=$(sed -n -E 's/.*(^|[;&|(]|[[:space:]])git[[:space:]]+(checkout[[:space:]]+-b|switch[[:space:]]+-c)[[:space:]]+([A-Za-z0-9._\/][A-Za-z0-9._\/-]*)([[:space:];&|)<>]|$).*/\3/p' \
    <<<"$branch_line" | tail -1)

  # `git branch <name>` creates; every other form does not. The flag test runs before the name is
  # taken, so `git branch -d feat/x` never reads `feat/x` as a name being created.
  if [ -z "$new_branch" ] \
     && ! grep -Eq '(^|[[:space:]])git[[:space:]]+branch([[:space:]]+-[a-zA-Z-]+)' <<<"$branch_line"; then
    new_branch=$(sed -n -E "s/.*git[[:space:]]+branch[[:space:]]+'([^']*)'.*/\\1/p" \
      <<<"$branch_line" | tail -1)
    [ -n "$new_branch" ] || new_branch=$(sed -n -E 's/.*git[[:space:]]+branch[[:space:]]+"([^"]*)".*/\1/p' \
      <<<"$branch_line" | tail -1)
    # `<`/`>` stay OUT of this boundary, unlike the checkout/switch pass above: `git branch` alone
    # takes no name, so `git branch 2>/dev/null` is ambiguous between a redirection and a
    # one-character name — the boundary was deliberately narrowed to `[[:space:];&|)]` to keep
    # reading that as a redirection. `git` may follow whitespace as well as a command start, the
    # same reasoning as the pass above: $branch_line was already selected against $masked, so this
    # line is already known to be a real invocation.
    [ -n "$new_branch" ] || new_branch=$(sed -n -E 's/.*(^|[;&|(]|[[:space:]])git[[:space:]]+branch[[:space:]]+([A-Za-z0-9._\/][A-Za-z0-9._\/-]*)([[:space:];&|)]|$).*/\2/p' \
      <<<"$branch_line" | tail -1)
  fi

  # A name the hook cannot expand is allowed. A branch is cheap to rename, and the name never
  # becomes a permanent commit message the way a squashed pull-request title does.
  case "$new_branch" in *'$'*) new_branch="" ;; esac

  if [ -n "$new_branch" ]; then
    branch_re=$(jq -r '.branch.pattern // empty' "$CONTRACT" 2>/dev/null)
    if [ -n "$branch_re" ]; then
      rc=0
      grep -Eq "$branch_re" <<<"$new_branch" 2>/dev/null || rc=$?
      # Exit 1 is a name that does not match. Exit 2 or above is a pattern grep could not compile,
      # and a contract the hook cannot read allows the call rather than blocking every branch
      # creation in every repository — check-contract.sh verifies the pattern names the eight
      # types, never that it compiles.
      if [ "$rc" -eq 1 ]; then
        deny "This branch name does not follow the organization's shape:

  $new_branch

Use <type>/<slug>, where the slug is lower case and the type is one of:

$(jq -r '.commit.types[]' "$CONTRACT" 2>/dev/null | sed 's/^/  - /')"
      fi
    fi
  fi
fi

# One pattern decides what an invocation is, and both the line and the verb come
# from it. Two copies of this idea is what let an `echo` naming one verb hand the
# other verb's rules to the command gh actually ran.
CREATE_RE='(^|[;&|(]|[[:space:]])gh[[:space:]]+(pr|issue)[[:space:]]+create([[:space:]]|$)'

# The invocation line, and nothing else. A single Bash call routinely carries the
# heredoc that writes the body, an echo, or a comment alongside the real command,
# and every one of those can quote a --title or a --body-file. Reading the whole
# command string let such a line exempt a real pull request, or point the guard at
# a file gh would never post. Take the LAST matching line, because that is the
# invocation the shell reaches last and gh acts on.
gh_line=$(printf '%s\n' "$logical" | grep -E "$CREATE_RE" | tail -1)
[ -n "$gh_line" ] || allow

# The verb comes from that same line. Read from the whole command it could name
# one verb while gh ran the other: a heredoc example or an echo mentioning
# `gh pr create` made an issue eligible for the pull-request title exemption.
# The greedy leading .* takes the LAST occurrence on the line, matching how
# --title and --body-file resolve below.
gh_verb=$(printf '%s' "$gh_line" | sed -n -E "s/.*$CREATE_RE.*/\\2/p")
[ -n "$gh_verb" ] || allow

# The value of --title, unquoted. Two passes: single-quoted, then double-quoted.
title=$(printf '%s' "$gh_line" | sed -n "s/.*--title[= ]*'\([^']*\)'.*/\1/p" | tail -1)
if [ -z "$title" ]; then
  title=$(printf '%s' "$gh_line" | sed -n 's/.*--title[= ]*"\([^"]*\)".*/\1/p' | tail -1)
fi

# The title selects which heading set applies. It no longer selects whether to
# check at all. An early allow here is what let an issue titled `chore(release):`
# pass with any body, twice, by two different routes; and a title the author types
# freely is not evidence that a release is happening. A release pull request now
# satisfies a smaller contract rather than escaping the contract.
is_release=""
if [ "$gh_verb" = "pr" ] && [ -n "$title" ]; then
  release_re=$(jq -r '.pr.release.titlePattern // empty' "$CONTRACT" 2>/dev/null)
  if [ -n "$release_re" ] && grep -Eq "$release_re" <<<"$title" 2>/dev/null; then
    is_release=1
  fi
fi

# The title faces the commit subject shape as well. It matters more than a commit subject does: a
# squash merge turns the title into the permanent commit message, and nothing later reads it again.
# An issue title is exempt — `gh issue create --title` names a problem rather than a change.
#
# The release title needs no exemption. `chore(release): 1.8.0` satisfies the pattern as an ordinary
# conventional subject carrying a release scope, and the contract cross-check keeps the two grammars
# from drifting apart.
if [ "$gh_verb" = "pr" ] && [ -n "$title" ] && enforced '.commit.enforce'; then
  # An unexpandable title follows the branch matcher's treatment, not the commit matcher's: `gh pr
  # edit --title` renames it as cheaply as `git branch -m` renames a branch, so a wrong title costs
  # a follow-up command, never a rewrite of history. A commit message denies on the same shape
  # because the commit already exists by the time the hook reads it — an unread substitution there
  # would ship a subject nobody checked, with no cheap way to take it back.
  case "$title" in *'$'*) : ;; *)
    subject_re=$(jq -r '.commit.subjectPattern // empty' "$CONTRACT" 2>/dev/null)
    if [ -n "$subject_re" ]; then
      rc=0
      grep -Eq "$subject_re" <<<"$title" 2>/dev/null || rc=$?
      # Exit 1 is a title that does not match. Exit 2 or above is a pattern grep could not
      # compile, and a contract the hook cannot read allows the call rather than blocking
      # every pull request in every repository — check-contract.sh verifies the pattern names
      # the eight types, never that it compiles.
      if [ "$rc" -eq 1 ]; then
        deny "This pull-request title does not follow the organization's shape:

  $title

A squash merge turns the title into the permanent commit message, so it carries
the commit subject shape: <type>(<scope>)!: <subject>, where the type is one of:

$(jq -r '.commit.types[]' "$CONTRACT" 2>/dev/null | sed 's/^/  - /')"
      fi
    fi
  ;; esac
fi

template_hint() {
  local path="${CLAUDE_PROJECT_DIR:-.}/$1"
  [ -f "$path" ] && printf '\n\nTemplate:\n\n%s' "$(cat "$path")"
}

# The pull-request template, when the repository ships one. An issue template is
# a GitHub form, not markdown, so quoting it here would help nobody.
verb_template_hint() {
  [ "$gh_verb" = "pr" ] && [ -z "$is_release" ] && template_hint .github/PULL_REQUEST_TEMPLATE.md
}

# A body always arrives as a file. The guard never parses body text out of the
# command string: the shell mangles inline markdown, and a title sharing a
# physical line with the body defeats any regex that tries to separate them.
# Only the path is read, and only from the invocation line. Three passes,
# mirroring --title: single-quoted, double-quoted, bare.
body_file=$(printf '%s' "$gh_line" | sed -n "s/.*--body-file[= ]*'\([^']*\)'.*/\1/p" | tail -1)
if [ -z "$body_file" ]; then
  body_file=$(printf '%s' "$gh_line" | sed -n 's/.*--body-file[= ]*"\([^"]*\)".*/\1/p' | tail -1)
fi
if [ -z "$body_file" ]; then
  body_file=$(printf '%s' "$gh_line" | sed -n 's/.*--body-file[= ]*\([^ "'"'"']*\).*/\1/p' | tail -1)
fi

if [ -z "$body_file" ]; then
  deny "This $gh_verb body must be passed with --body-file, not inline.

Write the body to a file, then run:
  gh $gh_verb create --title '...' --body-file <path>

The guard validates the file's contents. Passing markdown inline through the
shell mangles it and cannot be checked reliably.$(verb_template_hint)"
fi

if [ ! -f "$body_file" ] || [ ! -r "$body_file" ]; then
  deny "This $gh_verb passes --body-file, but the guard could not read that path.

Resolved path: '$body_file'

The guard reads the command as text, before the shell expands it, so a path
containing a shell variable, a ~, or a glob never resolves — even when the file
exists. Write the body to an absolute literal path and pass that:

  cat > /tmp/pr-body.md <<'EOF'
  ...
  EOF
  gh $gh_verb create --title '...' --body-file /tmp/pr-body.md

If the path is already absolute and literal, check it exists and is readable."
fi

body=$(cat "$body_file")

# Every markdown heading in the body, stripped of its hashes and trailing space.
# Fenced regions are dropped first: a body that only quotes the required shape
# inside ``` fences shows the author the sections without filling any of them,
# and counting those lines as headings allowed exactly that empty body.
headings=$(printf '%s\n' "$body" \
  | awk '/^[[:space:]]*```/ { f = !f; next } !f' \
  | sed -n 's/^#\{1,6\}[[:space:]]*//p' \
  | sed 's/[[:space:]]*$//')

# missing_for <jq-filter> — the required headings absent from the body, one per line.
missing_for() {
  local out=""
  local h
  while IFS= read -r h; do
    [ -n "$h" ] || continue
    if ! grep -Fxq "$h" <<<"$headings"; then
      out="$out  - $h
"
    fi
  done <<EOF
$(jq -r "$1" "$CONTRACT" 2>/dev/null)
EOF
  printf '%s' "$out"
}

if [ "$gh_verb" = "pr" ] && [ -n "$is_release" ]; then
  missing=$(missing_for '.pr.release.requiredHeadings[]?')
  [ -z "$missing" ] && allow
  deny "This release pull-request body is missing required sections:

$missing
A release carries a smaller shape than other pull requests: say what is being
released and what it contains. Fill the section in the file, then run the
command again."
fi

if [ "$gh_verb" = "pr" ]; then
  missing=$(missing_for '.pr.requiredHeadings[]?')
  [ -z "$missing" ] && allow
  deny "This pull-request body is missing required sections:

$missing
Fill every section in the file, then run the command again.$(template_hint .github/PULL_REQUEST_TEMPLATE.md)"
fi

missing_bug=$(missing_for '.issue.bug.requiredHeadings[]?')
missing_feature=$(missing_for '.issue.feature.requiredHeadings[]?')
{ [ -z "$missing_bug" ] || [ -z "$missing_feature" ]; } && allow

deny "This issue body matches neither the bug shape nor the feature shape.

As a bug report it is missing:

$missing_bug
As a feature request it is missing:

$missing_feature
Pick one shape, fill every section in the file, then run the command again."

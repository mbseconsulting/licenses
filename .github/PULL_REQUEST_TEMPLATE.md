## What & why

What this changes and the problem it solves. Link the design and plan when they exist, and delete
these two lines when they do not.

Design: `docs/superpowers/specs/YYYY-MM-DD-<slug>-design.md`
Plan: `docs/superpowers/plans/YYYY-MM-DD-<slug>.md`

Closes #

## The part worth reviewing closely

The change a reviewer should not skim — a subtle defect fixed, a decision that could have gone the
other way, or a fix whose necessity is not obvious from the diff. A table of defect and fix works
well when there are several.

## Testing

What ran, and what it proves. State the counts and the result from a clean build. Call out any test
that reaches the network or needs credentials, and any pre-existing failure that is not yours.

## Impact on consumers

What happens to a project or user that upgrades without changing anything. Answer this explicitly —
"no change required" and "consumers must delete their boilerplate" are both fine, silence is not.

## Not in scope

Work this pull request deliberately leaves for later, and where it is tracked.

## Checklist

- [ ] The formatter ran
- [ ] Documentation is updated
- [ ] Any spec or plan `**Status:**` line is current
- [ ] The body names the issue it closes
- [ ] Release note (releasing repositories only — delete this line otherwise):

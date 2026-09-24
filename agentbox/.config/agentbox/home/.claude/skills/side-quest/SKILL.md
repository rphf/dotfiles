---
name: side-quest
description: Ship a fix or change that is not part of the current task as its own atomic PR — a small bug found on the way, or a change to a shared component, hook or type used across the app that must be verified for regressions. Use when you find such a problem mid-task, or when the human asks for a side quest.
---

# Side quest

A side quest is a change outside the current task: a bug found on the way, or an edit to code many features share.
It ships alone so it can be reviewed, merged and reverted on its own. The current task's uncommitted work must stay
untouched throughout.

## 1. Propose, then wait

Tell the human what you found, why it matters, and where the fix would go. Start only when they say so.

- The current task does not need it: its own PR against main.
- The current task needs it to work: a fixup commit on the lowest branch of the stack that needs it, not a side quest.

## 2. Prove it is worth fixing

- Reproduce it with a failing test (request, unit or system spec) before touching the code.
- If a bad record causes it, check whether production has such records (read-only, for example Metabase). If only
  development data is bad, propose fixing that data instead of writing a guard.

## 3. Work in a worktree off main

```bash
git fetch origin main
git worktree add -b <type>/<name> <scratchpad>/wt-<name> origin/main
ln -s <main checkout>/.env <scratchpad>/wt-<name>/.env   # and any other gitignored file the tests need
```

Check that each linked file is gitignored (`git check-ignore -q .env`). Run every command from the worktree. The
stash is shared with the main checkout: set work aside with a WIP commit, not a bare `git stash`.

## 4. Fix narrowly

Change only what the failing test covers. Show the test fails without the fix and passes with it (a tagged
`git stash push -m <tag>` of the fix file, run, then `git stash apply <sha>` and drop that entry).

## 5. Measure the blast radius

Skip for a local fix. For shared code (a component, hook, GraphQL type or field used in many places):

- List every consumer: grep the imports, the type, the field.
- Run the checks that cover them, one at a time: the type check, lint on the changed files, then the specs of each
  consumer area. Put the consumer list and the results in the PR's tests block.
- For UI: before/after screenshots of the design-system page and of two or three real consumer pages.

## 6. Review in revue

Only one revue server can be reached by the human (one published port), and revue treats a worktree as its own
repository. So swap servers:

1. In the main checkout, make sure no review is waiting (no pending `revue wait`, no unanswered send), then
   `revue stop`.
2. In the worktree, leave the changes unstaged and run `revue open --no-browser`; give the link, then
   `revue wait` / `revue feedback` from the worktree as usual.
3. When the side quest is done: `revue stop` in the worktree, then `revue open --no-browser` in the main checkout.

## 7. Ship and clean up

- Commit and open a draft PR against main, following the repository's PR template.
- If a stack depends on it, say so: the stack rebases onto main once it merges.
- Remove the worktree (`git worktree remove <path>`) and tell the human whether the current task needs anything
  from the side quest.

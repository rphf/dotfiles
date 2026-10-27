---
name: git-spice-pr
description: Work with stacked PRs managed by git-spice and mirrored as a native GitHub stack. Use when the user wants to plan or create a stack, add or insert a branch, put changes or fixups on the right PR of a stack, restack, or submit PRs.
---

# Stacked PRs with git-spice

git-spice manages the stack locally. Its submit commands also register the PRs
as a native GitHub stack (same PRs, same order, each PR based on the one below),
and its merge commands merge that stack atomically.

## Rules

- Call the `git-spice` binary with `--no-prompt`. Do not use the `gs` alias.
- Nothing leaves the machine without explicit approval: no `submit`, `merge`,
  `git push`. Work locally, then show what you would run and wait.
- When the user asks for "the command", give it and do not run it.
- Do not rename a branch that has a PR. GitHub cannot rename the head branch.
- Commit format: follow the repo's `commitlint` config, else Conventional
  Commits (`type: summary`, no scope). Branch: `type/short-slug`. PR title is
  the commit subject. PR body follows the repo PR template, short.
- If `HANDOFF.md` exists (from the `handoff` skill), take the branch name,
  commit message, PR title and body from it. Delete it after the submit.

## Plan a stack

- Each PR is atomic and green on its own: it builds, its checks pass, and it
  leaves nothing half done. Do not split code only to make PRs smaller.
- Generated files (schema dumps, generated types, ...) are regenerated on each
  branch that changes their source.
- Run formatters on the whole change before you split it.
- Propose the layers (one line each, with branch names) and wait for approval
  before you create branches.

## Change an existing stack

Put every change on the branch whose PR owns that concern, not on the branch
you happen to be on. Then restack the branches above it.

1. `git-spice branch checkout <owning-branch>`.
2. Commit there:
   - PR already under review: `git commit --fixup=<commit>`, so the reviewer
     sees the change.
   - PR not submitted yet: `git commit --amend --no-edit` on the branch's commit, or
     `git-spice commit fixup <commit>` from a branch above it.
   - A new concern of that PR: a normal commit.
3. `git-spice upstack restack`.
4. On conflicts, resolve them, `git add`, then
   `GIT_EDITOR=true git-spice rebase continue`. Regenerate generated files on
   the branch instead of merging them by hand. Tell the user which branch
   conflicted and why.
5. If the change belongs in its own PR, insert a branch instead (below).

## Create a branch

- On top: `git-spice branch create <type>/<slug> -m "<subject>"`.
- In the middle: add `--insert` (above the current branch) or `--below`, with
  `--target <branch>` if needed.
- Move a branch: `git-spice branch onto <base>`, or `git-spice upstack onto
  <base>` to move it with everything above it.
- Existing branch: `git-spice branch track --base <base>`.

## Submit (after approval)

Show the stack (`git-spice log short`), the branches to push, and the PR titles
and bodies. Ask; proceed only on an explicit yes.

- New PR: `git-spice branch submit --no-prompt --no-web --title "..." --body "..."`
  (or `--fill`; `--draft` and `--label` when asked).
- Push changes to existing PRs: `git-spice upstack submit --no-prompt --no-web
  --update-only` (or `stack submit`).

Submit also creates or rebuilds the native stack, also for a PR inserted in the
middle or a changed base. A PR that is queued or has auto-merge on can block
the rebuild; git-spice then prints a warning. Tell the user about it.

Check every PR, its base and its position:

```sh
gh api repos/<owner>/<repo>/pulls/<n> --jq '"\(.base.ref) \(.stack.number) \(.stack.position)/\(.stack.size)"'
```

## Stack changed on GitHub

After GitHub rewrote the branches (for example the "Rebase stack" button),
run `git stack-pull` before you change anything locally. It resets each branch
of the stack to its remote version and stops if a branch has local-only commits.
`git-spice repo sync` updates only trunk and does not pull these branches.

## Reference

- https://abhinav.github.io/git-spice/cli/reference/
- https://abhinav.github.io/git-spice/guide/cr/#native-stacks
- https://docs.github.com/en/pull-requests/how-tos/stacked-pull-requests

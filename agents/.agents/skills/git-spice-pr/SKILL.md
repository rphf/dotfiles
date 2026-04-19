---
name: git-spice-pr
description: Create and submit a PR with git-spice (stacked diffs). Use when the user wants to open or submit a PR, create a stacked PR, or mentions git-spice.
---

# git-spice PR

Turn the current diff into a git-spice branch + PR in two gated steps.

## Rules

- Invoke the binary as `git-spice`, never the `gs` alias.
- Always pass `--no-prompt`.
- Never run a `submit` command without explicit user approval.
- The user handles staging. Do not run `git add`.
- Do not pick the base branch. Show the stack and let the user decide.
- Commit format: follow `commitlint` config if present, else `.gitmessage`
  if present, else Conventional Commits (commit `type: short summary`,
  branch `type/short-slug`). One-line subject, no body.

## Workflow

### 1. Show the stack and diff

```sh
git-spice log short
git status --short
git diff --stat
git diff --cached --stat
```

### 2. Propose 2–3 options

Numbered list, each with a branch name and a commit message following
the Conventional Commits format above. Wait for the user to pick, edit,
or provide their own. If base isn't obvious from `log short`, ask.

### 3. Create the branch + commit

```sh
git-spice branch create <type>/<slug> --no-prompt -m "<type>: <subject>"
```

Then re-show the stack:

```sh
git-spice log short
```

### 4. Submit — STOP and confirm

Ask explicitly: *"Ready to submit as a PR? (yes / no / draft)"*. Only
proceed on an explicit `yes` or `draft`.

```sh
git-spice branch submit --no-prompt --fill --no-web
```

Add `--draft` for drafts.

## Reference

[https://abhinav.github.io/git-spice/cli/reference/](https://abhinav.github.io/git-spice/cli/reference/)
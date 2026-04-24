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

### Check for handoff

If a `HANDOFF.md` file exists (created by the `handoff` skill from an
agent worktree), use its contents instead of proposing options:

1. Read `HANDOFF.md` — parse the `# branch`, `# commit`, `# pr-title`,
   and `# pr-body` sections.
2. Show the diff, the handoff content, and the stack.
3. Skip to **step 3** using the handoff values. Still let the user edit
   or override before proceeding.

Otherwise follow the normal flow below.

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

If coming from a `HANDOFF.md` (agent worktree, typically detached HEAD):

```sh
# Create the branch from detached HEAD (this is the final branch name)
git checkout -b <type>/<slug>
# Stage only source changes (exclude node_modules symlink and handoff)
git add -A -- ':!node_modules' ':!HANDOFF.md'
# Track in git-spice, then commit
git-spice branch track --no-prompt
git commit -m "<type>: <subject>"
```

Then re-show the stack:

```sh
git-spice log short
```

### 4. Submit — STOP and confirm

Ask explicitly: *"Ready to submit as a PR? (yes / no / draft)"*. Only
proceed on an explicit `yes` or `draft`.

If coming from a `HANDOFF.md`, pass title and body from the handoff:

```sh
git-spice branch submit --no-prompt --title "<pr-title>" --body "<pr-body>" --no-web
```

Otherwise use `--fill`:

```sh
git-spice branch submit --no-prompt --fill --no-web
```

Add `--draft` for drafts.

### 5. Clean up handoff

After a successful submit, remove the handoff file:

```sh
rm -f HANDOFF.md
```

## Reference

[https://abhinav.github.io/git-spice/cli/reference/](https://abhinav.github.io/git-spice/cli/reference/)
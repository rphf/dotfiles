---
name: commit-changes
description: Write a Conventional Commits message for staged changes and commit them. Use when the user asks to commit, wants a commit message written, or says they're ready to commit.
---

# Commit changes

Turn staged changes into a Conventional Commit in one gated step.

## Rules

- The user handles staging. Do not run `git add`.
- Commit format: follow `commitlint` config if present, else `.gitmessage`
if present, else Conventional Commits (`type: short summary`). One-line
subject, no body.
- Never run `git commit` without explicit user approval.

## Workflow

### 1. Inspect the staged diff

```sh
git status --short
git diff --cached --stat
git diff --cached
```

If nothing is staged, stop and tell the user to stage first.

### 2. Propose 2–3 options

Numbered list, each a single Conventional Commits one-liner (different
angles on the same diff — e.g. `fix:` vs `refactor:`, or different
scopes/wordings). Wait for the user to pick, edit, or supply their own.

### 3. Commit — only after approval

```sh
git commit -m "<type>: <subject>"
```

Then show the result:

```sh
git log -1 --oneline
```


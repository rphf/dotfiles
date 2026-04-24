---
name: handoff
description: Write a HANDOFF.md file summarizing changes for the host user to commit and PR. Use when work is complete in a worktree because the agent shouldn't commit or push.
---

# Handoff

Write a single `HANDOFF.md` at the worktree root so the host user can
commit and open a PR from your uncommitted changes.

## When to use

When you've finished work in a worktree (`.worktrees/`) and cannot commit
or push. The user will consume this file on the host to create the commit
and PR.

## Rules

- Commit format: follow `commitlint` config if present, else Conventional
  Commits (`type: short summary`). One-line subject, no body.
- Branch format: `type/short-slug` derived from the commit subject.
- PR body must strictly follow the PR template at `.github/pull_request_template.md`.
  Read the template, fill in every section, and remove the HTML comments.
- Do not run `git add`, `git commit`, or `git push`.

## Workflow

### 1. Analyze your changes

```sh
git status --short
git diff --stat
git diff
```

### 2. Read the PR template

```sh
cat .github/pull_request_template.md
```

### 3. Write `HANDOFF.md`

Write a single file at the worktree root with this exact structure:

```markdown
# branch

type/short-slug

# commit

type: short summary

# pr-title

Short PR title

# pr-body

<!-- PR body here: fill in the PR template from .github/pull_request_template.md -->
```

The `# pr-body` section must be the filled-in PR template — all sections
present, HTML comment instructions removed, placeholder links replaced
with real context or removed.

### 4. Confirm

Print a summary:

```
Handoff ready.
  Branch:  <branch>
  Commit:  <commit>
  PR:      <pr-title>

Written to HANDOFF.md
The host user can now commit and open a PR.
```

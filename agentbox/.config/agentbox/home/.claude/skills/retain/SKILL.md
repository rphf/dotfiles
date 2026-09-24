---
description: Save a lesson as a rule or skill for future agents. Use when the human corrects you, states a preference, or you work out a non-obvious workflow or trap worth keeping. Project lessons are edited in the repository and left unstaged, so they show in git diff.
argument-hint: "[what to capture — leave empty to capture what this session learned]"
---

# Retain a skill or rule for future agents

Your home config is read-only: `~/.claude` is partly linked from the human's `~/.config/agentbox/home`, which every
agent in every project shares. You cannot change it, and must not try. Write a proposal to `~/out/home` instead.
The human reviews it and copies the ones they keep into their overlay, where the next agents pick them up.

When you run this on your own, without the human asking, change only project files, and only where the change
shows in `git diff`. Do not write user-wide proposals to `~/out/home` then: mention the idea in your reply
instead, and the human runs `/retain` if they want it.

What to capture: $ARGUMENTS

If that is empty, capture what this session taught you that a future agent should know from its first message: a
correction the human made, a workflow you had to work out, a trap you fell into.

## Pick the form

- **A rule** is a standing instruction, true in every session: "never X", "always Y before Z", a preference.
  Write it to `~/out/home/.claude/rules/<slug>.md`. One subject per file, which can hold several rules.
- **A skill** is a procedure run on demand, with steps. Write it to `~/out/home/.claude/skills/<slug>/SKILL.md`,
  with a frontmatter `description` saying when to use it. Add `disable-model-invocation: true` when only the human
  should trigger it.
- **Project-specific knowledge** (this repository's commands, its layout, its quirks) belongs in the repository,
  in the directories `.claude/rules` and `.claude/skills` really live in. Find them:

  ```bash
  cd /workspace
  for d in .claude/rules .claude/skills; do
    r="$(realpath -m --relative-to=. "$d")"
    git check-ignore -q "$r" && echo "$d: gitignored" || echo "$d -> $r"
  done
  ```

  Write through the resolved path, which git tracks: `.claude/rules` itself when it is tracked, the link target
  (for example `docs/ai/raph/claude/rules`) when it is a link. Edit in place and leave it unstaged: no commit, no
  pull request. The human decides what to keep. When both are gitignored, say so and ask the human where it
  should go, and do not write anything.

  Then make sure every change shows in `git diff`. A new file does not until it is marked with intent to add,
  which stages no content:

  ```bash
  git add -N -- <new files>
  git diff --stat -- <resolved dirs>
  ```

  Every file you wrote must be in that output. If one is missing, it is outside git's view: move it or undo it.

`<slug>` is short kebab-case. The layout under `~/out/home` mirrors the overlay exactly, so the human can copy it
over as is.

## Before writing

- Look at `~/.claude/rules/`, `~/.claude/skills/`, `~/.claude/CLAUDE.md` and the project's resolved rules and skills directories. Prefer
  updating an existing file over creating a new one: if a file touches the same subject, add the rule to it or
  extend the skill, and propose the whole updated file under the same path, not a patch. Create a new file only
  when nothing existing fits.
- Keep it short and concise. A rule is a line or two; a skill is only the steps an agent would get wrong without
  it. Cut anything an agent already knows.
- Write it for an agent that has never seen this session: no "as we discussed", no names of files it will not have.
- State the rule and the reason for it. Leave out the story of how you found it.

## Then tell the human

For user-wide files, list each one with its URL, `http://$AGENT_HOST:$OUT_PORT/home/<path>`, and give these commands to
run on their machine:

```bash
agentbox get $AGENT home
cp -R <printed dir>/home/. ~/.config/agentbox/home/
```

Expand `$AGENT_HOST`, `$OUT_PORT` and `$AGENT` from your environment, and replace `<printed dir>` with the directory `agentbox get` prints. Agents pick the
files up on their next `agentbox up`.

For files changed in the project, list their paths and say they are left unstaged and show in `git diff`.

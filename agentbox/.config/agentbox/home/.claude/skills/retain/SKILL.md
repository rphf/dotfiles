---
description: Hand a new skill or rule to the human, for every future agent. Run only when the human asks.
disable-model-invocation: true
argument-hint: "[what to capture — leave empty to capture what this session learned]"
---

# Retain a skill or rule for future agents

Your home config is read-only: `~/.claude` is partly linked from the human's `~/.config/agentbox/home`, which every
agent in every project shares. You cannot change it, and must not try. Write a proposal to `~/out/home` instead.
The human reviews it and copies the ones they keep into their overlay, where the next agents pick them up.

What to capture: $ARGUMENTS

If that is empty, capture what this session taught you that a future agent should know from its first message: a
correction the human made, a workflow you had to work out, a trap you fell into.

## Pick the form

- **A rule** is a standing instruction, true in every session: "never X", "always Y before Z", a preference.
  Write it to `~/out/home/.claude/rules/<slug>.md`. One subject per file, which can hold several rules.
- **A skill** is a procedure run on demand, with steps. Write it to `~/out/home/.claude/skills/<slug>/SKILL.md`,
  with a frontmatter `description` saying when to use it. Add `disable-model-invocation: true` when only the human
  should trigger it.
- **Project-specific knowledge** (this repository's commands, its layout, its quirks) belongs in the repository
  instead, under `/workspace/docs/ai/raph/` (`.claude/` is gitignored there). Write it there directly and leave
  it unstaged: no `git add`, no commit, no pull request. The human decides what to keep.

`<slug>` is short kebab-case. The layout under `~/out/home` mirrors the overlay exactly, so the human can copy it
over as is.

## Before writing

- Look at `~/.claude/rules/`, `~/.claude/skills/`, `~/.claude/CLAUDE.md` and `/workspace/docs/ai/raph/`. Prefer
  updating an existing file over creating a new one: if a file touches the same subject, add the rule to it or
  extend the skill, and propose the whole updated file under the same path, not a patch. Create a new file only
  when nothing existing fits.
- Keep it short and concise. A rule is a line or two; a skill is only the steps an agent would get wrong without
  it. Cut anything an agent already knows.
- Write it for an agent that has never seen this session: no "as we discussed", no names of files it will not have.
- State the rule and the reason for it. Leave out the story of how you found it.

## Then tell the human

List each file you wrote with its URL, `http://$AGENT_HOST:$OUT_PORT/home/<path>`, and give them these commands to
run on their machine:

```bash
agentbox get $AGENT home
cp -R <printed dir>/home/. ~/.config/agentbox/home/
```

Expand `$AGENT_HOST`, `$OUT_PORT` and `$AGENT` from your environment, and replace `<printed dir>` with the directory `agentbox get` prints. Agents pick the
files up on their next `agentbox up`.

For files written under `/workspace/docs/ai/raph/`, list their paths and say they are left unstaged.

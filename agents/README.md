# agents

Stow package → `~/.agents/`

Canonical, tool-agnostic AI agent configuration. Based on the
[Agent Skills](https://agentskills.io/) open standard.

## Contents

- `AGENTS.md` — global rules for AI agents. Read natively by tools that
  support the Agent Skills standard; Claude Code reads it via a symlink
  from `~/.claude/CLAUDE.md` (see the `claude/` package).
- `skills/<name>/SKILL.md` — shared skills. Cursor picks them up
  automatically from `~/.agents/skills/`. Claude Code reads them via
  `~/.claude/skills/`, which is a symlink chain that ends here (see the
  `claude/` package for the wiring).
- `addons.md` — human-readable list of MCP servers and plugins I use.
  Not read by any tool; see "MCP" below for where actual config lives.

## Adding a shared skill

```sh
mkdir -p agents/.agents/skills/my-skill
$EDITOR agents/.agents/skills/my-skill/SKILL.md
```

That's it — the skill is immediately visible to both Cursor (from
`~/.agents/skills/`) and Claude (from `~/.claude/skills/`, which is a
symlink into this directory).

## MCP

MCP doesn't have a cross-tool file location (unlike skills). The schema
is shared but paths differ:

- **Cursor**: `~/.cursor/mcp.json` (manually symlinked to
  `dotfiles/cursor/mcp.json`)
- **Claude**: embedded in `~/.claude.json`, managed via `claude mcp add`

`addons.md` here is just a memory aid listing what I have installed.

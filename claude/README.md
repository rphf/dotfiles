# claude

Stow package → `~/.claude/`

Claude Code-specific bridge to the canonical `agents/` package.

## Contents

- `CLAUDE.md` → relative symlink to `../../agents/.agents/AGENTS.md`.
  Claude Code reads `~/.claude/CLAUDE.md` as its global rules file; the
  symlink keeps a single source of truth shared with other agents.
- `skills/<name>` — per-skill symlinks into `agents/.agents/skills/<name>`.
  Needed because Claude Code doesn't (yet) read `~/.agents/skills/`.
- `commands/` — Claude-specific slash commands (`<name>.md`). No symlinks
  here; commands are Claude-only at user level.
- `settings.json` — Claude Code user settings (model, effort level, etc.).

## Runtime state

`~/.claude/` also contains Claude's own runtime state (`sessions/`,
`history.jsonl`, `projects/`, `todos/`, …). Stow "unfolds" the tree and
only links the files listed above; runtime state is left alone.

## MCP

Claude's user-scope MCP config lives inside `~/.claude.json`, mixed with
runtime state, so it can't be symlinked. Bootstrap on a fresh machine
with:

```sh
claude mcp add --scope user --transport http context7 https://mcp.context7.com/mcp
# Verify
claude mcp list
```

The canonical list of servers I run is in `agents/.agents/addons.md`.

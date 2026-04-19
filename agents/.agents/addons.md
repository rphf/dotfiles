# Add-ons

MCP servers and plugins I install across tools.

## MCP servers


| Name     | Transport | URL                                                          |
| -------- | --------- | ------------------------------------------------------------ |
| context7 | http      | [https://mcp.context7.com/mcp](https://mcp.context7.com/mcp) |


## Plugins

Plugins bundle MCPs + skills + slash commands + subagents.


| Name        | Provides                                                   | Cursor                        | Claude Code                                                 |
| ----------- | ---------------------------------------------------------- | ----------------------------- | ----------------------------------------------------------- |
| context7    | MCP, `/context7:docs`, `docs-researcher` subagent, skill   | `/add-plugin context7-plugin` | `claude plugin install context7@claude-plugins-official`    |
| superpowers | ~13 skills (TDD, planning, debugging), subagents, commands | `/add-plugin superpowers`     | `claude plugin install superpowers@claude-plugins-official` |


## Quick reference

**Claude Code** (`claude` CLI):

```sh
claude mcp list                                 # list MCPs + health
claude mcp add --scope user --transport http <name> <url>
claude mcp remove <name> -s user
claude plugin list                              # list installed plugins
claude plugin install <name>@<marketplace>
claude plugin uninstall <name>
claude plugin marketplace list                  # registered marketplaces
```

**Cursor** (`cursor-agent` CLI + in-chat commands):

```sh
cursor-agent mcp list                           # list MCPs + status
cursor-agent mcp enable <name>                  # approve a server
cursor-agent mcp disable <name>
cursor-agent mcp login <name>                   # OAuth auth flow
# Add MCP: edit ~/.cursor/mcp.json (no CLI add)
# Plugins: in Agent chat, /add-plugin <name>
```

**Claude Desktop**: MCPs only. Edit `~/Library/Application Support/Claude/claude_desktop_config.json` and restart the app to apply.
# Cursor Dotfiles

## Stowing configuration

To symlink all config files (except `mcp.json`) to Cursor's user config directory:

```sh
stow --target="$HOME/Library/Application Support/Cursor/User" --ignore='^mcp\.json$' .
```

To symlink only `mcp.json` to `~/.cursor`:

```sh
ln -sf "$PWD/mcp.json" "$HOME/.cursor/mcp.json"
```

## Extension Management

**Extract all currently installed extensions:**

```bash
cursor --list-extensions > extensions.txt
```

**Install extensions:**

```bash
cat cursor/extensions.txt | xargs -n 1 cursor --install-extension
```

**Remove all extensions:**

```bash
cursor --list-extensions | xargs -L 1 cursor --uninstall-extension
```

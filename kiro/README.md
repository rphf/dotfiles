# Kiro dotfiles package

This folder contains **Kiro-specific** settings that merge with base VS Code settings.

## Setup

1. **Build merged settings**:

   ```bash
   cd $HOME/dotfiles
   ./vscode/scripts/build-fork-settings.sh kiro
   ```

2. **Symlink into place**:

   ```bash
   stow --target="$HOME/Library/Application Support/Kiro/User" --verbose kiro
   ```

3. **Install extensions**:
   ```bash
   cat kiro/extensions.txt | xargs -n 1 kiro --install-extension
   ```
   extensions are installed in "~/.kiro/extensions"

**Remove all extensions:**

```bash
kiro --list-extensions | xargs -L 1 kiro --uninstall-extension
```

## File structure

- `settings.fork.json` - Kiro-only settings (edit this)
- `extensions.fork.txt` - Kiro-only extensions (edit this)
- `settings.json` - Generated merged file (don't edit)
- `extensions.txt` - Generated merged file (don't edit)

## Workflow

1. Edit `settings.fork.json` or `extensions.fork.txt`
2. Run: `./vscode/scripts/build-fork-settings.sh kiro`
3. Changes apply automatically via symlinks

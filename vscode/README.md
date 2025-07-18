# VS Code dotfiles package

This folder contains **base** VS Code settings shared across all VS Code forks.

## Neovim Integration

Uses `vscode-neovim` extension with a minimal Neovim config located at `nvim/.config/nvim-vscode`.

## Fork-based configuration system

- `vscode/` folder: Base settings for all VS Code variants
- Fork folders (e.g., `kiro/`): Fork-specific settings only
- Settings are automatically merged: fork settings + base settings

## Setup

### Base VS Code

```bash
cd $HOME/dotfiles
stow --target="$HOME/Library/Application Support/Code/User" --verbose vscode
cat vscode/extensions.txt | xargs -n 1 code --install-extension
```

extensions are installed in "~/.vscode/extensions"

**Remove all extensions:**

```bash
code --list-extensions | xargs -L 1 code --uninstall-extension
```

### VS Code forks (e.g., Kiro)

1. **Create fork-specific settings** in the fork folder:
   - `settings.fork.json` - Fork-only settings
   - `extensions.fork.txt` - Fork-only extensions
   - `keybindings.fork.json` - Fork-only keybindings (optional)

2. **Build merged settings**:

   ```bash
   ./vscode/scripts/build-fork-settings.sh kiro
   ```

3. **Symlink into place**:

   ```bash
   stow --target="$HOME/Library/Application Support/Kiro/User" --verbose kiro
   ```

4. **Install extensions**:
   ```bash
   cat kiro/extensions.txt | xargs -n 1 code --install-extension
   ```

## Workflow

1. Edit base settings in `vscode/` folder
2. Edit fork-specific settings in `.fork.json` files
3. Run build script: `./vscode/scripts/build-fork-settings.sh <fork-name>`
4. Changes apply automatically via symlinks

## File structure

**Base folder (`vscode/`):**

- `settings.json` - Base settings
- `keybindings.json` - Base keybindings
- `extensions.txt` - Base extensions

**Fork folder (e.g., `kiro/`):**

- `settings.fork.json` - Fork-only settings (source of truth)
- `extensions.fork.txt` - Fork-only extensions (source of truth)
- `settings.json` - Generated merged file (don't edit)
- `extensions.txt` - Generated merged file (don't edit)

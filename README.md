# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Packages


| Package     | Target                 | Purpose                                                                                                                        |
| ----------- | ---------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| `agents`    | `~/.agents/`           | Canonical AI agent config (rules, skills, MCP notes)                                                                           |
| `bat`       | `~/.config/bat/`       | `bat` pager theme/config                                                                                                       |
| `claude`    | `~/.claude/`           | Claude Code bridge (symlinks into `agents/`)                                                                                   |
| `cmux`      | `~/.config/cmux/`      | `cmux` config                                                                                                                  |
| `cursor`    | *(two targets)*        | Cursor settings/keybindings → `~/Library/Application Support/Cursor/User/`; `mcp.json` → `~/.cursor/` (see `cursor/README.md`) |
| `git`       | `~/.config/git/`       | Git config                                                                                                                     |
| `karabiner` | `~/.config/karabiner/` | Karabiner-Elements                                                                                                             |
| `lazygit`   | `~/.config/lazygit/`   | `lazygit` config                                                                                                               |
| `mise`      | `~/.config/mise/`      | `mise` toolchain manager                                                                                                       |
| `neovide`   | `~/.config/neovide/`   | Neovide GUI config                                                                                                             |
| `nvim`      | `~/.config/nvim/`      | Neovim config                                                                                                                  |
| `obsidian`  | *(manual)*             | Obsidian vault snippets (not stowed)                                                                                           |
| `skhd`      | `~/.config/skhd/`      | `skhd` hotkey daemon                                                                                                           |
| `wezterm`   | `~/.config/wezterm/`   | Wezterm config                                                                                                                 |
| `work`      | *(manual)*             | Work-specific bits (not stowed)                                                                                                |
| `zed`       | `~/.config/zed/`       | Zed editor config                                                                                                              |
| `zsh`       | `~/`                   | Zsh config                                                                                                                     |


Each package has its own `README.md` with package-specific notes.

## Using stow

Stow creates symlinks from this repo to their target locations.

```sh
stow <package>         # install
stow -D <package>      # uninstall
stow -n <package>      # dry-run (show what would happen)
stow -R <package>      # restow (unlink + relink)
stow --adopt <package> # absorb existing target files into the package (see below)
```

### Handling existing files in the target

Stow ignores anything that isn't in the package. For example, `stow claude`
only touches the files listed under `claude/.claude/`; the rest of
`~/.claude/` (runtime state like `projects/`, `todos/`, `history.jsonl`,
`plugins/`, etc.) is left alone.

If a target path already exists as a real file (not a stow-owned symlink),
stow aborts with a conflict. Two ways to resolve:

1. **Back up + stow**: `mv ~/.foo ~/.foo.bak && stow <package>` — keeps the
  repo version as canonical.
2. **Adopt**: `stow --adopt <package>` — moves the live file into the
  package and symlinks back. The file in the repo is overwritten with
   whatever was at the target, so always run with a clean git tree:

### Adding a new package

Mirror the target directory structure inside the package:

```sh
mv ~/.config/nvim ~/dotfiles/nvim/.config/nvim
cd ~/dotfiles && stow nvim
```

Flat packages (like `cursor/`) that don't follow the `.config/` pattern
are managed with one-off manual symlinks where needed.

### Fresh machine setup

```sh
cd ~/dotfiles
stow agents bat claude cmux git karabiner lazygit mise neovide nvim skhd wezterm zed zsh
# Install Homebrew packages
brew bundle --file=Brewfile
# Wire up the repo-local commit template
git config --local commit.template .gitmessage
```

## Top-level files

Not stowed (see `.stow-local-ignore`):

- `Brewfile` — regenerate with `brew bundle dump --describe --force`
- `.macos` — macOS defaults tweaks
- `.gitmessage` — commit template for this repo; wired via `git config --local commit.template .gitmessage`
- `todo.local.md` — personal notes
- `.stylua.toml` — Lua formatter config (used from repo root)
- `backup.rayconfig` — Raycast config backup


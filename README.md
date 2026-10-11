# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Packages


| Package     | Target                 | Purpose                                                                                                                        |
| ----------- | ---------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| `agentbox`  | `~/.config/agentbox/`  | Settings and home overlay for agentbox sandboxes (see `agentbox/README.md`)                                                    |
| `agents`    | `~/.agents/`           | Canonical AI agent config (rules, skills, MCP notes)                                                                           |
| `bat`       | `~/.config/bat/`       | `bat` pager theme/config                                                                                                       |
| `claude`    | `~/.claude/`           | Claude Code bridge (symlinks into `agents/`)                                                                                   |
| `cursor`    | *(two targets)*        | Cursor settings/keybindings → `~/Library/Application Support/Cursor/User/`; `mcp.json` → `~/.cursor/` (see `cursor/README.md`) |
| `gh`        | *(manual)*             | GitHub CLI extensions manifest (`extensions.txt`, see `gh/README.md`)                                                          |
| `gh-dash`   | `~/.config/gh-dash/`   | `gh dash` PR/issue dashboard config                                                                                            |
| `git`       | `~/.config/git/`       | Git config                                                                                                                     |
| `karabiner` | `~/.config/karabiner/` | Karabiner-Elements                                                                                                             |
| `lazygit`   | `~/.config/lazygit/`   | `lazygit` config                                                                                                               |
| `mise`      | `~/.config/mise/`      | `mise` toolchain manager                                                                                                       |
| `node`      | `~/`                   | Global npm (`.npmrc`) and Yarn Berry (`.yarnrc.yml`) config                                                                    |
| `nvim`      | `~/.config/nvim/`      | Neovim config                                                                                                                  |
| `skhd`      | `~/.config/skhd/`      | `skhd` hotkey daemon                                                                                                           |
| `wezterm`   | `~/.config/wezterm/`   | Wezterm config                                                                                                                 |
| `work`      | *(manual)*             | Work-specific bits (not stowed)                                                                                                |
| `zed`       | `~/.config/zed/`       | Zed editor config                                                                                                              |
| `zsh`       | `~/`                   | Zsh config, and scripts in `~/.local/bin/`                                                                                     |


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
stow agentbox agents bat claude gh-dash git karabiner lazygit mise node nvim skhd wezterm zed zsh
# Install mise (official build, not the Homebrew formula) and its toolchains
curl https://mise.run | sh
mise install
# Install Homebrew packages (after mise: the npm/go entries need node and go)
brew bundle --file=Brewfile
# Wire up the repo-local commit template
git config --local commit.template .gitmessage
# Run the repo hooks on every commit (they live in ./.githooks/)
git config core.hooksPath .githooks
```

Then apply the macOS settings: run `bash .macos` and follow [macOS settings](#macos-settings).

## macOS settings

`.macos` holds the settings that `defaults write` can set (keyboard repeat, UI animations, Safari).
Run it with `bash .macos`; it quits Safari and restarts Dock and Finder so they load the new values.

Set these by hand, in System Settings or the app:

- **Spotlight → Search Privacy:** add `~/Workspace`, `~/Library/Application Support` and
  `~/Library/Android` (Cmd+Shift+G in the file picker to paste a path). They hold about 93% of
  the indexed items (code, `node_modules`, app data, Android SDK). The list is root-only, and a
  `.metadata_never_index` file in a folder does not stop indexing. Check the result with
  `mdfind -count -onlyin ~/Workspace 'kMDItemContentTypeTree == "public.item"'` (expect `0`).
- **Safari → Settings → Websites:** Pop-up Windows "Block and Notify", Notifications without
  "Allow websites to ask for permission", Auto-Play "Stop Media with Sound". Per-site settings are
  not in Safari's `defaults`.
- **wBlock:** lists, custom filters and settings sync through iCloud.
- **Raycast → Settings → Launcher:** turn off "Include Files in Root Search". Raycast is only
  used to launch apps and commands, not to search files.

## Top-level files

Not stowed (see `.stow-local-ignore`):

- `.githooks/` — versioned hooks (gitleaks scan, agentbox skill sync check); activate with `git config core.hooksPath .githooks`
- `Brewfile` — regenerate with `brew bundle dump --force`
- `.macos` — macOS defaults tweaks
- `.gitmessage` — commit template for this repo; wired via `git config --local commit.template .gitmessage`
- `todo.local.md` — personal notes
- `.stylua.toml` — Lua formatter config (used from repo root)


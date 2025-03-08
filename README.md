# Dotfiles

This repository contains my dotfiles, managed using **GNU Stow**.

---

## GNU Stow

**GNU Stow** is a symlink manager that helps manage dotfiles by creating symlinks from a central repository (like this one) to their target locations (e.g., your home directory `~`).

### Add a New Package

1. Move any config to the dotfiles repo, mirroring the target directory structure:

```bash
mv ~/.config/nvim ~/dotfiles/nvim/.config/nvim
```

2. Create symlinks:

```bash
cd ~/dotfiles
stow nvim
```

### Basic Commands

**Stow a package:**

```bash
stow <package-name>
```

**Unstow a package:**

```bash
stow -D <package-name>
```

**Dry run (test without applying):**

```bash
stow -n <package-name>
```

## Brewfile

To generate a Brewfile (a list of installed Homebrew packages), run:

```sh
brew bundle dump --describe --force
```

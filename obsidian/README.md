# Obsidian Settings Backup

This directory is a read-only copy of the `.obsidian` settings folder from an Obsidian vault.
The actual `.obsidian` lives inside an iCloud app-container directory, which is restricted: symlinks there are unsuitable because iCloud and Obsidian on iOS do not follow symlinked contents, so the real `.obsidian` cannot be managed with GNU Stow.
This directory exists only for version control and inspection.

## Refresh this backup

To update this folder with the latest settings from the vault, run this from `Terminal.app` (not other terminals), since Terminal has the necessary permissions to read the iCloud app-container directory:

```bash
rsync -av \
  "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Main/.obsidian/" \
  "$HOME/dotfiles/obsidian/"
```

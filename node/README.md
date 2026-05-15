# Node

Global configuration for npm and Yarn Berry (v4+).

## What's included

| File         | Purpose                                        |
| ------------ | ---------------------------------------------- |
| `.npmrc`     | npm config (scripts, age gate)                |
| `.yarnrc.yml`| Yarn Berry config (same policies, Yarn syntax) |

## Install

```sh
cd ~/dotfiles
stow node
```

Both files land in `~/`, which is where npm and Yarn look for global config.

## Notes

- Per-project `.yarnrc.yml` files override these globals (Yarn merges them).
- npm reads `~/.npmrc` then project-level `.npmrc`.


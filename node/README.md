# Node

Global configuration for npm and Yarn Berry (v4+).

## What's included

| File         | Purpose                                        |
| ------------ | ---------------------------------------------- |
| `.npmrc`     | npm config (dead registry, scripts, age gate) |
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
- The registry points to a dead endpoint (`127.0.0.1:9999`) to intentionally block installs as a temporary security measure during npm ecosystem vulnerabilities. Remove once the situation settles.

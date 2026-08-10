# gh

GitHub CLI extensions manifest (not stowed — `gh` itself is installed via the
Brewfile, and `~/.config/gh/hosts.yml` contains auth tokens so the config dir
is intentionally left unmanaged).

## Update the manifest

```sh
gh extension list | awk '{print $3}' > gh/extensions.txt
```

## Restore on a new machine

```sh
xargs -n1 gh extension install < gh/extensions.txt
```

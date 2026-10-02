#!/bin/zsh
#
# .zprofile: login shells only, sourced AFTER /etc/zprofile.
#
# macOS's /etc/zprofile runs `path_helper`, which rebuilds PATH with the system
# directories (/usr/bin, /bin, ...) at the FRONT — clobbering the order set in
# .zshenv. That's why `brew doctor` warns that /usr/bin comes before
# /opt/homebrew/bin: nothing re-prioritised Homebrew once path_helper had run.
#
# Re-assert precedence here, now that path_helper is done:  mise > Homebrew > system
# (This is also where Homebrew's own installer tells you to put shellenv.)

# Homebrew ahead of the system paths, so git, curl, ... resolve to the brew copy.
eval "$(/opt/homebrew/bin/brew shellenv)"

# mise shims ahead of Homebrew, so mise-managed tools always win — even in login
# shells that never source .zshrc (e.g. `zsh -lc '...'`) where `mise activate`
# doesn't run. See https://mise.jdx.dev/dev-tools/shims.html
export PATH="$HOME/.local/share/mise/shims:$PATH"

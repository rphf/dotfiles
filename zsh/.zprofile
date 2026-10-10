#!/bin/zsh
#
# .zprofile: login shells only, sourced AFTER /etc/zprofile.
#
# macOS's /etc/zprofile runs `path_helper`, which rebuilds PATH with the system
# directories (/usr/bin, /bin, ...) at the FRONT — clobbering the order set in
# .zshenv. That's why `brew doctor` warns that /usr/bin comes before
# /opt/homebrew/bin: nothing re-prioritised Homebrew once path_helper had run.
#
# Re-assert precedence here, now that path_helper is done:  cargo > mise > Homebrew > system

# mise shims ahead of Homebrew, so mise-managed tools always win — even in login
# shells that never source .zshrc (e.g. `zsh -lc '...'`) where `mise activate`
# doesn't run. See https://mise.jdx.dev/dev-tools/shims.html
# Homebrew ahead of the system paths, so git, curl, ... resolve to the brew copy.
# Rust (rustup) first, as in .zshenv.
# `typeset -U path` (set in .zshenv) drops the duplicates left behind.
path=($HOME/.cargo/bin $HOME/.local/share/mise/shims $HOMEBREW_PREFIX/bin $HOMEBREW_PREFIX/sbin $path)

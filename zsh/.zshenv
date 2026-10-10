# ~/.zshenv: read by every zsh. Login shells then read ~/.zprofile, interactive ones ~/.zshrc.
# Order: https://zsh.sourceforge.io/Doc/Release/Files.html#Startup_002fShutdown-Files

export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export XDG_STATE_HOME=$HOME/.local/state

export EDITOR='nvim'

# https://donottrack.sh/
export DO_NOT_TRACK=1
export HOMEBREW_NO_ANALYTICS=1

# `brew upgrade` skips casks that update themselves; also upgrade these.
export HOMEBREW_UPGRADE_GREEDY_CASKS="mullvad-vpn"

# Set the pager for viewing man pages, using 'bat' for syntax highlighting
export MANPAGER="sh -c 'col -bx | bat --paging=always -l man -p'"

export BAT_THEME="tokyonight_storm"
export BAT_PAGING="never"

# Ignore any suggestion for command beginning with cd
# I prefer relying on zoxide for changing directories
export ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd *"

# --- PATH precedence: cargo > mise > Homebrew > system --------------------------------
# This order must hold in every shell. Here (.zshenv) it covers non-login
# shells (IDE extensions, `zsh -c`, scripts) where path_helper never runs.
# Login shells re-assert the same order in .zprofile, because macOS's
# /etc/zprofile runs path_helper AFTER .zshenv and shoves the system paths
# back to the front.

# Keep each entry once; prepending an entry that is already there moves it to the front.
typeset -U path fpath

# Homebrew ahead of the system paths (git, curl, ... resolve to the brew copy).
# Static copy of `eval "$(brew shellenv)"`, which costs ~30 ms per shell.
# Compare with `brew shellenv` after a major Homebrew upgrade.
export HOMEBREW_PREFIX=/opt/homebrew
export HOMEBREW_CELLAR=/opt/homebrew/Cellar
export HOMEBREW_REPOSITORY=/opt/homebrew
fpath=($HOMEBREW_PREFIX/share/zsh/site-functions $fpath)
path=($HOMEBREW_PREFIX/bin $HOMEBREW_PREFIX/sbin $path)
[ -z "${MANPATH-}" ] || { export MANPATH="${MANPATH%"${MANPATH##*[!:]}"}"; export MANPATH=":${MANPATH#"${MANPATH%%[!:]*}"}"; }
[[ ":$INFOPATH:" == *":$HOMEBREW_PREFIX/share/info:"* ]] || export INFOPATH="$HOMEBREW_PREFIX/share/info:${INFOPATH:-}"

export PATH="$PATH:$HOME/.local/bin"

# mise shims ahead of Homebrew so mise-managed tools (node, go, etc.) win.
# `mise activate` only runs in interactive shells via .zshrc; shims cover
# everything else (IDE extensions, mise run, scripts).
# See: https://mise.jdx.dev/dev-tools/shims.html
export PATH="$HOME/.local/share/mise/shims:$PATH"

# Java — Homebrew's OpenJDK is keg-only, so it's not on PATH or discoverable
# via /usr/libexec/java_home without this. Needed by Maestro (e2e UI tests).
export JAVA_HOME="/opt/homebrew/opt/openjdk"
export PATH="$PATH:$JAVA_HOME/bin"

# Android SDK
export ANDROID_HOME=~/Library/Android/sdk
export ANDROID_SDK_ROOT=$ANDROID_HOME
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/platform-tools"

# Ensure your PATH prefers pg18 tools, needs to match the version in the Brewfile
export PATH="$PATH:/opt/homebrew/opt/postgresql@18/bin"

# Rust toolchain (rustup), same effect as `source ~/.cargo/env`.
path=($HOME/.cargo/bin $path)

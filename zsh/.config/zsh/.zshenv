export EDITOR='nvim'

# https://donottrack.sh/
export DO_NOT_TRACK=1
export HOMEBREW_NO_ANALYTICS=1

export HISTFILE="$HOME/.zsh_history"

# Set Golang flags
export GOFLAGS="-mod=vendor"

# Set the pager for viewing man pages, using 'bat' for syntax highlighting
export MANPAGER="sh -c 'col -bx | bat --paging=always -l man -p'"

export BAT_THEME="tokyonight_storm"
export BAT_PAGING="never"

export GREP_OPTIONS='--color=always'

# Ignore any suggestion for command beginning with cd
# I prefer relying on zoxide for changing directories
export ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd *"

# --- PATH precedence: mise > Homebrew > system --------------------------------
# This order must hold in every shell. Here (.zshenv) it covers non-login
# shells (IDE extensions, `zsh -c`, scripts) where path_helper never runs.
# Login shells re-assert the same order in .zprofile, because macOS's
# /etc/zprofile runs path_helper AFTER .zshenv and shoves the system paths
# back to the front.

# Homebrew ahead of the system paths (git, curl, ... resolve to the brew copy).
eval "$(/opt/homebrew/bin/brew shellenv)"

export PATH="$PATH:$HOME/.local/bin"

# mise shims ahead of Homebrew so mise-managed tools (node, go, etc.) win.
# `mise activate` only runs in interactive shells via .zshrc; shims cover
# everything else (IDE extensions, mise run, scripts).
# See: https://mise.jdx.dev/dev-tools/shims.html
export PATH="$HOME/.local/share/mise/shims:$PATH"

# Android SDK
export ANDROID_HOME=~/Library/Android/sdk
export ANDROID_SDK_ROOT=$ANDROID_HOME
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/platform-tools"

# Ensure your PATH prefers pg18 tools, needs to match the version in the Brewfile
export PATH="$PATH:/opt/homebrew/opt/postgresql@18/bin"

source "$HOME/.cargo/env"

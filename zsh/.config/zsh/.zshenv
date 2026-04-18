export EDITOR='nvim'

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

export PATH="$PATH:/opt/homebrew/bin"
export PATH="$PATH:$HOME/.local/bin"

# Prepend mise shims so non-interactive shells (e.g. spawned by VS Code / IDE
# extensions) resolve ruby/node/etc. through mise. `mise activate` only runs in
# interactive shells via .zshrc; shims cover everything else.
# See: https://mise.jdx.dev/dev-tools/shims.html
export PATH="$HOME/.local/share/mise/shims:$PATH"

# Android SDK
export ANDROID_HOME=~/Library/Android/sdk
export ANDROID_SDK_ROOT=$ANDROID_HOME
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/platform-tools"

# Ensure your PATH prefers pg18 tools, needs to match the version in the Brewfile
export PATH="$PATH:/opt/homebrew/opt/postgresql@18/bin"

# Will refuse to execute a commands if there is an alternative alias for it (zsh-you-should-use)
# export YSU_HARDCORE=1

# Detach from the terminal instead of waiting for the Neovide process to terminate
export NEOVIDE_FORK=1

source "$HOME/.cargo/env"

source "$ZDOTDIR/.secrets.zshenv"

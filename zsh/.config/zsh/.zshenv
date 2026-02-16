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
# export PATH="$HOME/.pyenv/bin:$PATH"
export PATH="$PATH:$HOME/.antigravity/antigravity/bin"

# Ensure your PATH prefers pg18 tools, needs to match the version in the Brewfile
export PATH="$PATH:/opt/homebrew/opt/postgresql@18/bin"

# Will refuse to execute a commands if there is an alternative alias for it (zsh-you-should-use)
# export YSU_HARDCORE=1

# Detach from the terminal instead of waiting for the Neovide process to terminate
export NEOVIDE_FORK=1

source "$HOME/.cargo/env"

source "$ZDOTDIR/.secrets.zshenv"

# Set default editor
export EDITOR='nvim'

# Set Golang flags
export GOFLAGS="-mod=vendor"

# Set the pager for viewing man pages, using 'bat' for syntax highlighting
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Set the theme for 'bat'
export BAT_THEME="TwoDark"

# Ignore any suggestion for command beginning with cd 
# I prefer relying on zoxide for changing directories
export ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd *"

# Add binaries to PATH
export PATH="$HOME/.volta/bin:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$HOME/.pyenv/bin:$PATH"
export PATH="$PATH:/opt/homebrew/bin"


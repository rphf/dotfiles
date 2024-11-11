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

# Add essential paths to PATH
export PATH="$HOME/.volta/bin:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$HOME/.pyenv/bin:$PATH"
export PATH="$PATH:/opt/homebrew/bin"

# Initialize Homebrew environment variables
if command -v brew >/dev/null 2>&1; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Commenting pyenv when not using it because it signicantly decrease the shell performance
# see https://github.com/romkatv/zsh-bench for benchmarking the shell

# Initialize pyenv and pyenv-virtualenv if pyenv is installed
# if command -v pyenv >/dev/null 2>&1; then
#   eval "$(pyenv init --path)"
#   eval "$(pyenv virtualenv-init -)"
# fi

# Initialize rbenv if it’s installed
if command -v rbenv >/dev/null 2>&1; then
  eval "$(rbenv init - zsh)"
fi

# Initialize direnv if installed (for managing per-project environment variables)
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# Initialize zoxide if installed (for faster directory navigation)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

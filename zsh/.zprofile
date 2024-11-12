# Initialize Homebrew environment variables
if command -v brew >/dev/null 2>&1; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

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

# Commenting pyenv when not using it because it signicantly decrease the shell performance 
# see https://github.com/romkatv/zsh-bench for benchmarking the shell 

# Initialize pyenv and pyenv-virtualenv if pyenv is installed
# if command -v pyenv >/dev/null 2>&1; then
#   eval "$(pyenv init --path)"
#   eval "$(pyenv virtualenv-init -)"
# fi

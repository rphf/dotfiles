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

export PATH="$PATH:/opt/homebrew/bin"
# export PATH="$HOME/.pyenv/bin:$PATH"

# Source the .secrets.zshenv file if it exists
if [ -f ~/.secrets.zshenv ]; then
  source ~/.secrets.zshenv
fi

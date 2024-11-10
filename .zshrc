# In antidote home folder (check with `antidote home`), this will use friendly names for the git repositories cloned
# e.g. `zsh-users__zsh-autosuggestions` instead of `https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-autosuggestions`
zstyle ':antidote:bundle' use-friendly-names 'yes'

# Source antidote plugin manager
source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh
antidote load

# Needed for zsh-users/zsh-completions
# autoload -Uz compinit && compinit

# Environment variables
export EDITOR='nvim'
export GOFLAGS="-mod=vendor"
export PATH="$HOME/.volta/bin:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$HOME/.pyenv/bin:$PATH"
export PATH="$PATH:/opt/homebrew/bin"

# Inits
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
fi
eval "$(pyenv virtualenv-init -)"
eval "$(rbenv init - zsh)"
eval "$(direnv hook zsh)"
eval "$(zoxide init zsh)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
source ~/.p10k.zsh

# Source aliases file
if [ -f ~/.zsh_aliases ]; then
  source ~/.zsh_aliases
fi

# In antidote home folder (check with `antidote home`), this will use friendly names for the git repositories cloned
# e.g. `zsh-users__zsh-autosuggestions` instead of `https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-autosuggestions`
zstyle ':antidote:bundle' use-friendly-names 'yes'

# Source antidote plugin manager
source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh
antidote load

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
source ~/.p10k.zsh

# Source aliases file
if [ -f ~/.zsh_aliases ]; then
  source ~/.zsh_aliases
fi

# Source fzf initialization if it exists, enabling fuzzy finder features
if [ -f ~/.fzf.zsh ]; then
  source ~/.fzf.zsh
  # Bind `K` to FZF history search start in normal mode
  bindkey -M vicmd 'K' fzf-history-widget
fi



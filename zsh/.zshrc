# Check https://zsh.sourceforge.io/Intro/intro_3.html
# Describe which files are automatically loaded at zsh startup, for which purpose, in which condition and in which order.

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
source ~/.p10k.zsh

# In antidote home folder (check with `antidote home`), this will use friendly names for the git repositories cloned
# e.g. `zsh-users__zsh-autosuggestions` instead of `https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-autosuggestions`
zstyle ':antidote:bundle' use-friendly-names 'yes'

# Source antidote plugin manager
source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh
antidote load

# Source fzf initialization if it exists, enabling fuzzy finder features
if [ -f ~/.fzf.zsh ]; then
  source ~/.fzf.zsh
  # Bind `K` to FZF history search start in normal mode
  bindkey -M vicmd 'K' fzf-history-widget
fi

# Initialize Homebrew environment variables
eval "$(/opt/homebrew/bin/brew shellenv)"
# Initialize zoxide, a smarter cd command
eval "$(zoxide init zsh)"
# Activate Mise, a polyglot package manager
eval "$(mise activate zsh)"

# Commenting pyenv when not using it because it signicantly decrease the shell performance 
# see https://github.com/romkatv/zsh-bench for benchmarking the shell 
# eval "$(pyenv init --path)"
# eval "$(pyenv virtualenv-init -)"

source ~/.compdef_gt.zsh
source ~/.pls.zsh

# Source aliases file
if [ -f ~/.zsh_aliases ]; then
  source ~/.zsh_aliases
fi

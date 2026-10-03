
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
source "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh"
# To clean up stale files (keep the latest `.zsh` and `.zwc`):
# rm -f "$XDG_CACHE_HOME"/p10k-*.tmp.*

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
source ~/.p10k.zsh

# In antidote home folder (check with `antidote home`), this will use friendly names for the git repositories cloned
# e.g. `zsh-users__zsh-autosuggestions` instead of `https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-autosuggestions`
zstyle ':antidote:bundle' use-friendly-names 'yes'

# ez-compinit: skip compinit's full check while the dump is less than 20h old (~20ms faster startup).
# Run `run-compinit -f` to pick up new completions sooner.
zstyle ':plugin:ez-compinit' 'use-cache' 'yes'

# Source antidote plugin manager
source "$HOMEBREW_PREFIX/opt/antidote/share/antidote/antidote.zsh"
antidote load

# fzf for enabling fuzzy finder features (needs fzf installed with brew)
source <(fzf --zsh)
export FZF_DEFAULT_OPTS='--height 40% --tmux bottom,40% --layout reverse'
# Initialize zoxide, a smarter cd command
eval "$(zoxide init zsh)"
# Activate Mise, a polyglot package manager
eval "$(mise activate zsh)"


# HISTORY
#
# Set in .zshrc because /etc/zshrc (read after .zshenv) sets smaller defaults.
# HISTFILE keeps its /etc/zshrc default, ~/.zsh_history.
export HISTSIZE=10000
export SAVEHIST=50000

# Exhaustive list with more detailed descriptions here: https://zsh.sourceforge.io/Doc/Release/Options.html#History
# setopt HIST_IGNORE_ALL_DUPS     # Remove older duplicates of a command from history.
setopt HIST_IGNORE_DUPS         # Do not enter command lines into the history list if they are duplicates of the previous event.
setopt HIST_REDUCE_BLANKS       # Remove superfluous blanks from each command line being added to the history list.
setopt EXTENDED_HISTORY         # Include timestamp
setopt HIST_EXPIRE_DUPS_FIRST   # Expire the duplicates first when trimming history
# setopt INC_APPEND_HISTORY       # Append history lines from all sessions.

# ALIASES

if command -v lsd &> /dev/null; then
  alias ls=lsd
  alias lla='ls -la'
fi

if command -v zoxide &> /dev/null; then
  alias cd=z
fi

alias lg=lazygit
alias gs=git-spice

alias haiku="claude --model haiku"
alias sonnet="claude --model sonnet"
alias opus="claude --model 'opus[1m]'"
alias fable="claude --model 'fable[1m]'"

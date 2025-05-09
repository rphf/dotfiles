
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
source "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh"
# To clean up stale files (keep the latest `.zsh` and `.zwc`):
# rm -f "$XDG_CACHE_HOME"/p10k-*.tmp.*

# To customize prompt, run `p10k configure` or edit $XDG_CONFIG_HOME/zsh/.p10k.zsh.
source "$XDG_CONFIG_HOME/zsh/.p10k.zsh"

# In antidote home folder (check with `antidote home`), this will use friendly names for the git repositories cloned
# e.g. `zsh-users__zsh-autosuggestions` instead of `https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-autosuggestions`
zstyle ':antidote:bundle' use-friendly-names 'yes'

# Source antidote plugin manager
source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh
antidote load

# fzf for enabling fuzzy finder features (needs fzf installed with brew)
source <(fzf --zsh)
# Custom widget for searching command history 
source "$XDG_CONFIG_HOME/zsh/.fzf-history-search.zsh"

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

source "$XDG_CONFIG_HOME/zsh/.compdef_gt.zsh"
source "$XDG_CONFIG_HOME/zsh/.pls.zsh"
source "$XDG_CONFIG_HOME/zsh/.zsh_aliases"

# HISTORY
#
# Needs to set in .zshrc because .zshenv is loaded before /etc/zshrc default config load which
# overwrites to HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history (and ZDOTDIR is set to $HOME/.config/zsh)
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=50000

# Exhaustive list with more detailed descriptions here: https://zsh.sourceforge.io/Doc/Release/Options.html#History
# setopt HIST_IGNORE_ALL_DUPS     # Remove older duplicates of a command from history.
setopt HIST_IGNORE_DUPS         # Do not enter command lines into the history list if they are duplicates of the previous event.
setopt HIST_REDUCE_BLANKS       # Remove superfluous blanks from each command line being added to the history list.
setopt INC_APPEND_HISTORY       # Append history lines from all sessions.
setopt EXTENDED_HISTORY         # Include timestamp
setopt HIST_EXPIRE_DUPS_FIRST   # Expire the duplicates first when trimming history


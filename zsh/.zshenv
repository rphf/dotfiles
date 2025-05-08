#!/bin/zsh
#
# .zshenv: Zsh environment file, always loaded at shell startup
#
# Check https://zsh.sourceforge.io/Intro/intro_3.html
# Describe which files are automatically loaded at zsh startup, for which purpose, in which condition and in which order.

# If not set, change the path for the Zsh DOTfiles DIRectory
export ZDOTDIR=${ZDOTDIR:-$HOME/.config/zsh}

export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}



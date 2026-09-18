# Shell for agent sandboxes. Deliberately small: no plugin manager, no powerlevel10k, nothing to install.
# The prompt's first job is to stop you confusing a sandbox with your own machine.

bindkey -v
export KEYTIMEOUT=1

# zsh binds backspace in insert mode to vi-backward-delete-char, which refuses to delete anything typed before
# you entered insert mode. After one trip through normal or visual mode the key goes dead mid-line. These are the
# widgets that just delete.
bindkey -M viins '^?'    backward-delete-char
bindkey -M viins '^H'    backward-delete-char
bindkey -M viins '^W'    backward-kill-word
bindkey -M viins '^U'    backward-kill-line
bindkey -M viins '^A'    beginning-of-line
bindkey -M viins '^E'    end-of-line
bindkey -M viins '^[[3~' delete-char
bindkey -M vicmd '^[[3~' delete-char
bindkey -M viins '^[[H'  beginning-of-line
bindkey -M viins '^[[F'  end-of-line
bindkey -M viins '^[[1~' beginning-of-line
bindkey -M viins '^[[4~' end-of-line
bindkey -M viins '^P'    up-line-or-history
bindkey -M viins '^N'    down-line-or-history
bindkey -M viins '^R'    history-incremental-search-backward

# zsh changes no cursor shape on its own, so vi mode is invisible without this. Steady bar while inserting,
# steady block in normal mode, and a bar again before running a command so whatever you launch inherits that.
_cursor_bar()   { print -n '\e[6 q' }
_cursor_block() { print -n '\e[2 q' }
zle-keymap-select() { [[ $KEYMAP == vicmd ]] && _cursor_block || _cursor_bar }
zle-line-init()     { _cursor_bar }
zle -N zle-keymap-select
zle -N zle-line-init
preexec() { _cursor_bar }
zle_highlight=(region:bg=blue,fg=white special:standout suffix:bold isearch:underline paste:bold)
export EDITOR=vim VISUAL=vim PAGER=less
export LESS=-FRX

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS HIST_REDUCE_BLANKS EXTENDED_HISTORY HIST_EXPIRE_DUPS_FIRST SHARE_HISTORY
setopt AUTO_CD INTERACTIVE_COMMENTS

autoload -Uz vcs_info colors && colors
zstyle ':vcs_info:git:*' formats ' %F{magenta}%b%f'
precmd() { vcs_info }
setopt PROMPT_SUBST
PROMPT='%F{179}${AGENT_NAME:-sandbox}%f %F{244}·%f %F{cyan}%~%f${vcs_info_msg_0_}
%(?.%F{179}.%F{red})❯%f '
RPROMPT='%(?..%F{red}%?%f)'

alias ll='ls -lah --color=auto'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias g='git'
alias gs='git status --short --branch'
alias out='cd "$HOME/out"'
alias ws='cd /workspace'

# Where things are, one line, on every new shell. Delete if it gets in the way.
box-help() {
  print -P "%F{yellow}${AGENT_NAME:-sandbox}%f  app: %F{cyan}http://${AGENT_HOST}:${PORT:-?}%f  outbox: %F{cyan}http://${AGENT_HOST}:${OUT_PORT:-?}/%f"
  print -P "  %F{green}app start|status|logs%f   %F{green}net-log hosts%f   %F{green}pbcopy%f (to your clipboard)   %F{green}open <url>%f (clickable)"
  print "  hand files back by writing them to ~/out"
}
box-help

source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null

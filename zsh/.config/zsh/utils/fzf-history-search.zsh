# Create the widget first
zle -N fzf-history-search

export FZF_DEFAULT_OPTS='--height 40% --tmux bottom,40% --layout reverse'

fzf-history-search() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
  selected=( $(fc -rli 1 |
    FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --with-nth=2.. -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort $FZF_CTRL_R_OPTS --query=${(qqq)LBUFFER} +m" $(__fzfcmd)) ); echo $selected
  local ret=$?
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle reset-prompt
  return $ret
}

# Bind to vicmd 'K'
bindkey -M vicmd 'K' fzf-history-search

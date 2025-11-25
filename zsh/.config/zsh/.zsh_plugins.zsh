fpath+=( "$HOME/Library/Caches/antidote/romkatv/powerlevel10k" )
source "$HOME/Library/Caches/antidote/romkatv/powerlevel10k/powerlevel10k.zsh-theme"
source "$HOME/Library/Caches/antidote/romkatv/powerlevel10k/powerlevel9k.zsh-theme"
fpath+=( "$HOME/Library/Caches/antidote/zsh-users/zsh-autosuggestions" )
source "$HOME/Library/Caches/antidote/zsh-users/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"
fpath+=( "$HOME/Library/Caches/antidote/jeffreytse/zsh-vi-mode" )
source "$HOME/Library/Caches/antidote/jeffreytse/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
fpath+=( "$HOME/Library/Caches/antidote/mattmc3/ez-compinit" )
source "$HOME/Library/Caches/antidote/mattmc3/ez-compinit/ez-compinit.plugin.zsh"
fpath+=( "$HOME/Library/Caches/antidote/zsh-users/zsh-completions/src" )
fpath+=( "$HOME/Library/Caches/antidote/aloxaf/fzf-tab" )
source "$HOME/Library/Caches/antidote/aloxaf/fzf-tab/fzf-tab.plugin.zsh"
if ! (( $+functions[zsh-defer] )); then
  fpath+=( "$HOME/Library/Caches/antidote/romkatv/zsh-defer" )
  source "$HOME/Library/Caches/antidote/romkatv/zsh-defer/zsh-defer.plugin.zsh"
fi
fpath+=( "$HOME/Library/Caches/antidote/zsh-users/zsh-syntax-highlighting" )
zsh-defer source "$HOME/Library/Caches/antidote/zsh-users/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh"

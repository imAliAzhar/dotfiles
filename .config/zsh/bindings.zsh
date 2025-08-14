autoload -z edit-command-line
zle -N edit-command-line
bindkey -M viins "^[e" edit-command-line

bindkey -M viins "^O" accept-line-and-down-history
bindkey -M viins '^ ' autosuggest-execute

function zvm_after_lazy_keybindings() {
  bindkey -M vicmd "^[e" edit-command-line
  bindkey -M vicmd "^O" accept-line-and-down-history
  bindkey -M vicmd 'H' vi-first-non-blank
  bindkey -M vicmd 'L' vi-end-of-line
  bindkey -M vicmd "/" fzf-history-widget
}


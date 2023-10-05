bindkey -e                                 # Use emacs keymap
# bindkey -v '^?' backward-delete-char

autoload -z     edit-command-line          # Edit current line in vim buffer
zle -N          edit-command-line
bindkey "^[e"   edit-command-line

bindkey '^ '    autosuggest-execute        # Execute suggested command

bindkey '^ '    autosuggest-execute        # Execute suggested command

bindkey "^O"    accept-line-and-down-history

bindkey -s      '^[j' 'lfcd\n'              # run lfcd fn


# bindkey -M viins "^ "    autosuggest-execute        # Execute suggested command
# bindkey -M vicmd "^ "    autosuggest-execute        # Execute suggested command
# bindkey -M viins "^O" accept-line-and-down-history
# bindkey -M vicmd "^O" accept-line-and-down-history
# bindkey -M vicmd "L" end-of-line
# bindkey -M vicmd "H" beginning-of-line
# bindkey -M vicmd "/" fzf-history-widget

# bindkey '^B'    backward-word              # Switch char and word skip bindings
# bindkey '^[B'   backward-char
# bindkey '^[b'   backward-char
# bindkey '^F'    forward-word
# bindkey '^[F'   forward-char
# bindkey '^[f'   forward-char


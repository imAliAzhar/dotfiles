precmd() {                                        # Print empty line after each command
  precmd() {
    echo
  }
}


set_prompt() {
  if [[ $SHLVL -eq 1 ]]; then
    echo '%B%F{3}$%f%b '
  else
    echo "%B%F{3}$(for ((i=2; i<=$SHLVL; i++)); do printf "▸"; done)%f%b  "

  fi
}


PROMPT=$(set_prompt)
RPROMPT='%F{8}%1d'

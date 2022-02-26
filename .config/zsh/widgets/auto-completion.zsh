autoload -Uz compinit # load zsh's autocompletion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# https://carlosbecker.com/posts/speeding-up-zsh
if [ $(date +'%j') != $(stat -f '%Sm' -t '%j' $ZDOTDIR/.zcompdump*) ]; then
  compinit
else
  compinit -C
fi


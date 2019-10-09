source $ZDOTDIR/aliases
#hide starting % symbol
unsetopt PROMPT_SP

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

HISTFILE=$ZDOTDIR/.history
SAVEHIST=500
setopt HIST_IGNORE_ALL_DUPS

PROMPT='%F{8}%1d %B%F{3}❯%F{2}❯%f%b '

bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word


#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'

alias rm="rm -i" # confirms delete

alias g="git" 

alias c="code" 

alias d="docker" 

alias off="shutdown now" 

alias v="vim" 
alias sv="sudo vim" 

alias e="ranger ." 
alias se="sudo ranger /" 

alias u="urxvt &"

alias s="sudo" 

alias md="mkdir" 

alias venv="source venv/bin/activate" 

alias bt="bluetoothctl" 

alias p="python" 

alias cls="clear" 

alias vi3="vim ~/.config/i3/config"

alias wd="pwd"

alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

alias ps1="export PS1=\"\[\033[0;32m\]\u@\[\033[0;32m\]\h\[\033[00m\]:\[\033[0;34m\]\w\[\033[0;00m\]\$ \""


stty -ixon # disable Software Flow Control (XON,XOFF)

#export PS1="\[\033[0;32m\]\u@\[\033[0;32m\]\h\[\033[00m\]:\[\033[0;34m\]\w\[\033[0;00m\]\$ "

export PS1="\[\033[0;34m\]> \033[0;00m"

#for backspace delete
#stty werase '^?'

#sudo autocompletion
#complete -cf sudo

export PATH=$PATH:/usr/local/bin/

export HISTCONTROL=ignoredups

# alt+m for man page of command
# bind '"\em": "\C-a\eb\ed\C-y\e#man \C-y\C-m\C-p\C-p\C-a\C-d\C-e"'

LS_COLORS=$LS_COLORS:'ow=0;33' ; export LS_COLORS #change color of unwritable files

if [ -f /etc/bash_completion ]; then
 . /etc/bash_completion
fi

alias dde='sudo startx /usr/bin/startdde'

# case insensitive path completion
bind 'set completion-ignore-case on'

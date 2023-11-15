# Applications
alias g="git"
alias gri="git rebase -i "
alias c="code"
alias v="nvim"
alias vim="vim"
alias t="tmux-fzf-session"
alias td="tmux ls && read tmux_session && tmux attach -t ${tmux_session:-default} || tmux new -s ${tmux_session:-default}"
alias sv="sudo vim"
alias s="sudo"
#alias cat="bat"
alias rzsh="source ~/.config/zsh/settings.zsh"
alias ip="ipconfig getifaddr en0"
alias ls="eza"
#alias lf="lfcd"
alias rt="trash"

alias md="mkdir"

alias venv="source venv/bin/activate"
alias p="python"

alias vzsh="vim ~/.config/zsh/settings.zsh"
alias vvim="vim ~/.config/nvim/init.vim"

alias y="yarn"
alias pp="pnpm"

alias dot="GIT_WORK_TREE=~ GIT_DIR=~/.dotfiles"

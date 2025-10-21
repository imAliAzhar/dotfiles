# Applications
alias g="git"
alias gcan="git commit --amend --no-edit"
alias gs="git status -sb"
alias gc="git commit -m "
alias gac="git commit -am "
alias gcb='copy_branch_name' # function from git_copy_branch.zsh
alias gch='git_copy_commit' # function from git_copy_commit.zsh


alias c="code"
alias v="nvim"
alias vim="nvim"
alias t="tmux-fzf-session"
alias td="tmux ls && read tmux_session && tmux attach -t ${tmux_session:-default} || tmux new -s ${tmux_session:-default}"
alias s="sudo"
alias ls="eza"
alias lf="yazi" # or yazi-cwd to automatically change directory on exit
alias rt="trash"

alias md="mkdir"

alias venv="source venv/bin/activate"
alias p="python"

alias y="yarn"

alias dot="GIT_WORK_TREE=~ GIT_DIR=~/.dotfiles"

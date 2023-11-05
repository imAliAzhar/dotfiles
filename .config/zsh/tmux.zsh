if [ -z "$TMUX" ] && [ "$TERM_PROGRAM" != "vscode" ]
then
    # tmux ls && read tmux_session && tmux attach -t ${tmux_session:-default} || tmux new -s ${tmux_session:-default}
    source tmux-fzf-session
fi

# For dotfiles session, copy tmux env vars to shell env
# tmux env set by ~/.local/bin/tmux-fzf-session
SESSION=$(tmux display-message -p '#S')

if [[ "$SESSION" == "dotfiles" ]]; then
    export $(tmux show-environment GIT_DIR)
    export $(tmux show-environment GIT_WORK_TREE)
fi

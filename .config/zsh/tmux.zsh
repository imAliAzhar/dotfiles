if [ -z "$TMUX" ] && [ "$TERM_PROGRAM" != "vscode" ]
then
    tmux ls && read tmux_session && tmux attach -t ${tmux_session:-default} || tmux new -s ${tmux_session:-default}
fi

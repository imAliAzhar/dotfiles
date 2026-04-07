#!/bin/sh
# Opens the most recent Claude file in the nvim tmux pane via <leader>cc
# Only runs if the active pane is named "claude"

window_name=$(tmux display-message -p '#{window_name}')
[ "$window_name" != "claude" ] && exit 0

tmux send-keys -t "$EDITOR.1" " cc"
tmux select-window -t "$EDITOR" \; select-pane -t 1

#!/bin/sh
# Opens the most recent Claude file in the nvim tmux pane via <leader>cc
# Usage: called from Claude Code hook or manually

tmux send-keys -t "$EDITOR.1" " cc"
tmux select-window -t "$EDITOR" \; select-pane -t 1

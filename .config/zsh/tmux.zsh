# Sync with 'emulate_tmux' ~/.config/wezterm/wezterm.lua
export NATIVE_TERM_MULTIPLEXING=false

if [ "$NATIVE_TERM_MULTIPLEXING" = "true" ]; then
  return 0
fi

if [ -z "$TMUX" ] && [ "$TERM_PROGRAM" = "WezTerm" ];
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

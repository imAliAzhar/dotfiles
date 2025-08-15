# Sync with 'emulate_tmux' ~/.config/wezterm/wezterm.lua
export NATIVE_TERM_MULTIPLEXING=false

if [ "$NATIVE_TERM_MULTIPLEXING" = "true" ]; then
  return 0
fi


CATPPUCCIN_MOCHA_BASE="#1e1e2e"
CATPPUCCIN_MOCHA_SUBTEXT_0="#a5adce"
CATPPUCCIN_MOCHA_OVERLAY_0="#6c7086"

CATPPUCCIN_LATTE_BASE="#eff1f5"
CATPPUCCIN_LATTE_TEXT="#4c4f69"
CATPPUCCIN_LATTE_ROSEWATER="#dc8a78"



if [[ "$LIGHT_THEME" == "true" ]]; then
  export TMUX_STATUS_BG="$CATPPUCCIN_LATTE_BASE"
  export TMUX_STATUS_FG="$CATPPUCCIN_LATTE_TEXT"
  export TMUX_STATUS_ACTIVE="$CATPPUCCIN_LATTE_ROSEWATER"
else
  export TMUX_STATUS_BG="$CATPPUCCIN_MOCHA_BASE"
  export TMUX_STATUS_FG="$CATPPUCCIN_MOCHA_OVERLAY_0"
  export TMUX_STATUS_ACTIVE="$CATPPUCCIN_MOCHA_SUBTEXT_0"
fi


if [ -z "$TMUX" ] && [ "$TERM_PROGRAM" = "WezTerm" ];
then
    # tmux ls && read tmux_session && tmux attach -t ${tmux_session:-default} || tmux new -s ${tmux_session:-default}
    source $HOME/.local/bin/tmux-fzf-session
fi

# For dotfiles session, copy tmux env vars to shell env
# tmux env set by ~/.local/bin/tmux-fzf-session
SESSION=$(tmux display-message -p '#S')

if [[ "$SESSION" == "dotfiles" ]]; then
    export $(tmux show-environment GIT_DIR)
    export $(tmux show-environment GIT_WORK_TREE)
fi

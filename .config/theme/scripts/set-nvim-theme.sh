#!/bin/bash

set -euo pipefail

THEME=$1
MODE=$2


MARK=">>> theme marker <<<"

PARTS="$HOME/.config/theme/$THEME/nvim"
NVIM_THEME="$HOME/.config/nvim/after/plugin/theme.lua"
STATUSBAR_THEME="$HOME/.config/nvim/after/plugin/lualine.lua"

tmp="$(mktemp)"
cat "$PARTS/$MODE.lua" > "$tmp"
sed -n "/$MARK/,\$p" "$NVIM_THEME" >> "$tmp"
mv "$tmp" "$NVIM_THEME"

tmp="$(mktemp)"
cat "$PARTS/$MODE-statusbar.lua" > "$tmp"
sed -n "/$MARK/,\$p" "$STATUSBAR_THEME" >> "$tmp"
mv "$tmp" "$STATUSBAR_THEME"

# Source updated nvim theme
tmux list-panes -a -F "#{pane_id} #{pane_current_command}" \
| awk '$2=="nvim"{print $1}' \
| xargs -n1 -I{} tmux send-keys -t {} Escape "  rt"

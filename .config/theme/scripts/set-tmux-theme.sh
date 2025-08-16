#!/bin/bash

set -euo pipefail

THEME=$1
MODE=$2

sed -i '' '/# >>> THEME MARKER <<< #/q' $HOME/.config/tmux/tmux.conf
cat $HOME/.config/theme/$THEME/tmux/$MODE.tmux >> $HOME/.config/tmux/tmux.conf

tmux source-file ~/.config/tmux/tmux.conf


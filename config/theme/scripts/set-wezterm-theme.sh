#!/bin/bash

set -euo pipefail

THEME=$1
MODE=$2

cat $HOME/.config/theme/$THEME/wezterm/$MODE.lua > $HOME/.config/wezterm/theme.lua


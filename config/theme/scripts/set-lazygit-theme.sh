#!/bin/bash
set -euo pipefail

THEME=$1
MODE=$2

ln -sfn ~/.config/theme/$THEME/lazygit/$MODE.yml ~/.config/lazygit/theme.yml

#!/usr/bin/env bash
set -euo pipefail

# Resolve dirs
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONF_FILE="$THEME_DIR/current_theme.sh"

# Args
UPDATED_THEME_NAME="${1:-}"
if [[ -z "${UPDATED_THEME_NAME}" || ! "${UPDATED_THEME_NAME}" =~ ^(cattpuccin|rose-pine)$ ]]; then
  echo "Usage: $0 {cattpuccin|rose-pine}" >&2
  exit 1
fi

UPDATED_THEME_MODE="${2:-}"
if [[ -z "${UPDATED_THEME_MODE}" || ! "${UPDATED_THEME_MODE}" =~ ^(dark|light)$ ]]; then
  echo "Usage: $0 {dark|light}" >&2
  exit 1
fi

# Load current theme (defines THEME_NAME, THEME_MODE)
if [[ -f "$CONF_FILE" ]]; then
  source "$CONF_FILE"
fi

: "${THEME_NAME:?THEME_NAME not set in $CONF_FILE}"
: "${THEME_MODE:?THEME_MODE not set in $CONF_FILE}"

# Update theme mode
echo "THEME_NAME=$UPDATED_THEME_NAME" > "$CONF_FILE"
echo "THEME_MODE=$UPDATED_THEME_MODE" >> "$CONF_FILE"


echo $UPDATED_THEME_NAME $UPDATED_THEME_MODE

# Update themes for terminal applications
"$SCRIPT_DIR/set-lazygit-theme.sh"  "$UPDATED_THEME_NAME" "$UPDATED_THEME_MODE"
"$SCRIPT_DIR/set-nvim-theme.sh"     "$UPDATED_THEME_NAME" "$UPDATED_THEME_MODE"
"$SCRIPT_DIR/set-tmux-theme.sh"     "$UPDATED_THEME_NAME" "$UPDATED_THEME_MODE"
"$SCRIPT_DIR/set-wezterm-theme.sh"  "$UPDATED_THEME_NAME" "$UPDATED_THEME_MODE"
"$SCRIPT_DIR/set-yazi-theme.sh"     "$UPDATED_THEME_NAME" "$UPDATED_THEME_MODE"

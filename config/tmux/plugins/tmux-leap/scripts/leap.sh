#!/usr/bin/env bash
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PANE_ID="$(tmux display-message -p '#{pane_id}')"
PANE_HEIGHT="$(tmux display-message -p -t "$PANE_ID" '#{pane_height}')"
PANE_WIDTH="$(tmux display-message -p -t "$PANE_ID" '#{pane_width}')"
PANE_TOP="$(tmux display-message -p -t "$PANE_ID" '#{pane_top}')"
PANE_LEFT="$(tmux display-message -p -t "$PANE_ID" '#{pane_left}')"

CONTENT_FILE="$(mktemp /tmp/tmux-leap-XXXXXX)"
RESULT_FILE="$(mktemp /tmp/tmux-leap-XXXXXX)"
trap 'rm -f "$CONTENT_FILE" "$RESULT_FILE"' EXIT

# Capture visible pane content (plain text, no escape sequences)
tmux capture-pane -p -t "$PANE_ID" > "$CONTENT_FILE"

# Open a borderless popup that exactly overlays the current pane
tmux display-popup \
    -x "$PANE_LEFT" \
    -y "$PANE_TOP" \
    -w "$PANE_WIDTH" \
    -h "$PANE_HEIGHT" \
    -b none \
    -E "CONTENT_FILE='$CONTENT_FILE' \
        RESULT_FILE='$RESULT_FILE' \
        PANE_HEIGHT='$PANE_HEIGHT' \
        PANE_WIDTH='$PANE_WIDTH' \
        python3 '$SCRIPTS_DIR/leap_popup.py'"

# Nothing selected — user cancelled
[ -s "$RESULT_FILE" ] || exit 0

# Result is "row:col" (0-indexed from top-left of visible area)
IFS=: read -r row col < "$RESULT_FILE"

lines_from_bottom=$(( PANE_HEIGHT - 1 - row ))

# Enter copy mode and position cursor at the jumped-to location
tmux copy-mode -t "$PANE_ID"
tmux send-keys -t "$PANE_ID" -X history-bottom

if [ "$lines_from_bottom" -gt 0 ]; then
    tmux send-keys -t "$PANE_ID" -X -N "$lines_from_bottom" cursor-up
fi
tmux send-keys -t "$PANE_ID" -X start-of-line
if [ "$col" -gt 0 ]; then
    tmux send-keys -t "$PANE_ID" -X -N "$col" cursor-right
fi

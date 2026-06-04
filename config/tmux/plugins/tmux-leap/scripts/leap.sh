#!/usr/bin/env bash
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PANE_FORMAT='#{pane_id}|#{pane_height}|#{pane_width}|#{pane_top}|#{pane_left}|#{scroll_position}|#{pane_in_mode}|#{cursor_x}|#{cursor_y}'
PANE_INFO="$(tmux display-message -p "$PANE_FORMAT")"
IFS='|' read -r \
    PANE_ID \
    PANE_HEIGHT \
    PANE_WIDTH \
    PANE_TOP \
    PANE_LEFT \
    SCROLL_OFFSET \
    IN_COPY_MODE \
    CURSOR_COL \
    CURSOR_ROW <<< "$PANE_INFO"
SCROLL_OFFSET="${SCROLL_OFFSET:-0}"
IN_COPY_MODE="${IN_COPY_MODE:-0}"

# Cursor position is used for Leap's nvim-compatible target ordering. In copy
# mode tmux exposes a separate cursor; otherwise use the live pane cursor.
if [ "$IN_COPY_MODE" = "1" ]; then
    COPY_CURSOR_COL="$(tmux display-message -p -t "$PANE_ID" '#{copy_cursor_x}' 2>/dev/null || true)"
    COPY_CURSOR_ROW="$(tmux display-message -p -t "$PANE_ID" '#{copy_cursor_y}' 2>/dev/null || true)"
    [ -n "$COPY_CURSOR_COL" ] && CURSOR_COL="$COPY_CURSOR_COL"
    [ -n "$COPY_CURSOR_ROW" ] && CURSOR_ROW="$COPY_CURSOR_ROW"
fi
CURSOR_COL="${CURSOR_COL:-0}"
CURSOR_ROW="${CURSOR_ROW:-0}"

# Runtime options mirror leap.nvim. Defaults are supplied by leap_popup.lua.
LEAP_LABELS="$(tmux show-option -gqv "@leap-labels" 2>/dev/null || true)"
LEAP_SAFE_LABELS="$(tmux show-option -gqv "@leap-safe-labels" 2>/dev/null || true)"
LEAP_IGNORECASE="$(tmux show-option -gqv "@leap-ignorecase" 2>/dev/null || true)"
LEAP_SMARTCASE="$(tmux show-option -gqv "@leap-smartcase" 2>/dev/null || true)"
LEAP_CASE_SENSITIVE="$(tmux show-option -gqv "@leap-case-sensitive" 2>/dev/null || true)"

CONTENT_FILE="$(mktemp "${TMPDIR:-/tmp}/tmux-leap-content.XXXXXX")"
PAINT_FILE="$(mktemp "${TMPDIR:-/tmp}/tmux-leap-paint.XXXXXX")"
RESULT_FILE="$(mktemp "${TMPDIR:-/tmp}/tmux-leap-result.XXXXXX")"
trap 'rm -f "$CONTENT_FILE" "$PAINT_FILE" "$RESULT_FILE"' EXIT

# Capture the lines currently visible at the scroll position.
# tmux line 0 = top of live pane; negative = history above it.
# Visible area when scrolled by N: lines -N to (-N + PANE_HEIGHT - 1).
CAPTURE_START=$(( -SCROLL_OFFSET ))
CAPTURE_END=$(( PANE_HEIGHT - 1 - SCROLL_OFFSET ))
tmux capture-pane -p -e -S "$CAPTURE_START" -E "$CAPTURE_END" -t "$PANE_ID" > "$CONTENT_FILE"

# A separate paint file is used only for the popup prepaint. -N preserves the
# trailing cells so the popup faithfully covers the underlying pane; awk rewrites
# newlines to CRLF and intentionally omits the final newline so the terminal does
# not scroll the popup up by one row.
tmux capture-pane -p -e -N -S "$CAPTURE_START" -E "$CAPTURE_END" -t "$PANE_ID" |
    awk 'NR > 1 { printf "\r\n" } { printf "%s", $0 }' > "$PAINT_FILE"

LUA_BIN="$(command -v luajit || true)"
if [ -z "$LUA_BIN" ]; then
    tmux display-message "tmux-leap requires luajit"
    exit 1
fi

printf -v RUN_CMD '%q CONTENT_FILE=%q RESULT_FILE=%q PANE_HEIGHT=%q PANE_WIDTH=%q CURSOR_ROW=%q CURSOR_COL=%q LEAP_LABELS=%q LEAP_SAFE_LABELS=%q LEAP_IGNORECASE=%q LEAP_SMARTCASE=%q LEAP_CASE_SENSITIVE=%q LEAP_PREPAINTED=1 %q %q' \
    env \
    "$CONTENT_FILE" \
    "$RESULT_FILE" \
    "$PANE_HEIGHT" \
    "$PANE_WIDTH" \
    "$CURSOR_ROW" \
    "$CURSOR_COL" \
    "$LEAP_LABELS" \
    "$LEAP_SAFE_LABELS" \
    "$LEAP_IGNORECASE" \
    "$LEAP_SMARTCASE" \
    "$LEAP_CASE_SENSITIVE" \
    "$LUA_BIN" \
    "$SCRIPTS_DIR/leap_popup.lua"

# Prepaint the captured pane immediately in the popup before LuaJIT starts.
# This avoids the brief blank-popup flash on startup; the Lua renderer then only
# draws once the first Leap preview is ready.
printf -v POPUP_CMD "printf '\\033[?25l\\033[H'; cat %q; printf '\\033[0m'; exec %s" \
    "$PAINT_FILE" \
    "$RUN_CMD"

# Open a borderless popup that exactly overlays the current pane.
# -t is required when invoked from a copy-mode key binding so tmux knows
# which client to attach the popup to.
tmux display-popup \
    -t "$PANE_ID" \
    -x "$PANE_LEFT" \
    -y "$PANE_TOP" \
    -w "$PANE_WIDTH" \
    -h "$PANE_HEIGHT" \
    -b none \
    -E "$POPUP_CMD"

# Nothing selected — user cancelled
[ -s "$RESULT_FILE" ] || exit 0

# Result is "row:col" (0-indexed from top-left of visible area)
IFS=: read -r row col < "$RESULT_FILE"
[[ "$row" =~ ^[0-9]+$ && "$col" =~ ^[0-9]+$ ]] || exit 0

# If already in copy mode, skip the copy-mode command — calling it again
# resets the scroll position to history-bottom before we can navigate.
if [ "$IN_COPY_MODE" != "1" ]; then
    set -- copy-mode -t "$PANE_ID" \;
else
    set --
fi
set -- "$@" send-keys -t "$PANE_ID" -X top-line
if [ "$row" -gt 0 ]; then
    set -- "$@" \; send-keys -t "$PANE_ID" -X -N "$row" cursor-down
fi
set -- "$@" \; send-keys -t "$PANE_ID" -X start-of-line
if [ "$col" -gt 0 ]; then
    set -- "$@" \; send-keys -t "$PANE_ID" -X -N "$col" cursor-right
fi

# Match the expected tmux "visual" workflow: land on the target and immediately
# start a copy-mode selection from there.
set -- "$@" \; send-keys -t "$PANE_ID" -X begin-selection
tmux "$@"

#!/usr/bin/env bash
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LEAP_KEY=$(tmux show-option -gqv "@leap-key")
LEAP_KEY="${LEAP_KEY:-/}"

LEAP_COPY_KEY=$(tmux show-option -gqv "@leap-copy-key")
LEAP_COPY_KEY="${LEAP_COPY_KEY:-s}"

LEAP_SCRIPT="$CURRENT_DIR/scripts/leap.sh"
printf -v LEAP_CMD '%q' "$LEAP_SCRIPT"

tmux bind-key "$LEAP_KEY" run-shell "$LEAP_CMD"

# Trigger leap directly from copy mode without the prefix key
tmux bind-key -T copy-mode    "$LEAP_COPY_KEY" run-shell "$LEAP_CMD"
tmux bind-key -T copy-mode-vi "$LEAP_COPY_KEY" run-shell "$LEAP_CMD"

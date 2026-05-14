#!/usr/bin/env bash
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LEAP_KEY=$(tmux show-option -gqv "@leap-key")
LEAP_KEY="${LEAP_KEY:-/}"

tmux bind-key "$LEAP_KEY" run-shell "$CURRENT_DIR/scripts/leap.sh"

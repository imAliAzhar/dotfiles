#!/bin/bash
#
# Drive monitor for macOS — sends push notifications via self-hosted ntfy
# when the biakino drive is connected or disconnected.

NTFY_TOPIC="biakino-batt-k9x2f"
NTFY_URL="http://localhost:8090/$NTFY_TOPIC"
STATE_FILE="/tmp/.drive-monitor-state"
DRIVE_PATH="/Volumes/biakino"

# Read last known state
last_state=""
if [[ -f "$STATE_FILE" ]]; then
    last_state=$(cat "$STATE_FILE")
fi

if [[ -d "$DRIVE_PATH" ]]; then
    current_state="connected"
else
    current_state="disconnected"
fi

# No change — nothing to do
if [[ "$current_state" == "$last_state" ]]; then
    exit 0
fi

if [[ "$current_state" == "connected" ]]; then
    curl -s \
        -H "Title: Drive connected" \
        -H "Priority: default" \
        -d "Biakino drive is now available at $DRIVE_PATH." \
        "$NTFY_URL" > /dev/null
else
    curl -s \
        -H "Title: Drive disconnected" \
        -H "Priority: high" \
        -d "Biakino drive has been disconnected. Media services may be affected." \
        "$NTFY_URL" > /dev/null
fi

echo "$current_state" > "$STATE_FILE"

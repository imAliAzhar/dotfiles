#!/bin/bash
#
# Battery monitor for macOS — sends push notifications via self-hosted ntfy
# when the laptop is on battery and drops below thresholds.

NTFY_TOPIC="biakino-batt-k9x2f"
NTFY_URL="http://localhost:8090/$NTFY_TOPIC"
STATE_FILE="/tmp/.battery-notify-state"
THRESHOLDS=(50 40 30 25 20 15 10 5)

# Parse battery info from pmset
battery_info=$(pmset -g batt)
percentage=$(echo "$battery_info" | grep -oE '[0-9]+%' | head -1 | tr -d '%')
charging=$(echo "$battery_info" | grep -c "AC Power")

if [[ -z "$percentage" ]]; then
    echo "Could not read battery percentage" >&2
    exit 1
fi

# Read last state
last_state=""
if [[ -f "$STATE_FILE" ]]; then
    last_state=$(cat "$STATE_FILE")
fi

# If plugged in, send charging notification once then clear
if [[ "$charging" -gt 0 ]]; then
    if [[ -n "$last_state" && "$last_state" != "charging" ]]; then
        curl -s \
            -H "Title: ⚡ ${percentage}% — Charging" \
            -H "Priority: low" \
            -d "Biakino server is back on power." \
            "$NTFY_URL" > /dev/null
        echo "charging" > "$STATE_FILE"
    fi
    exit 0
fi

# Find the lowest threshold the battery has crossed
current_threshold=""
for t in "${THRESHOLDS[@]}"; do
    if [[ "$percentage" -le "$t" ]]; then
        current_threshold="$t"
    fi
done

# Nothing to notify (above 50%)
if [[ -z "$current_threshold" ]]; then
    exit 0
fi

# Already notified at this threshold or lower
if [[ -n "$last_state" && "$last_state" != "charging" && "$last_state" -le "$current_threshold" ]]; then
    exit 0
fi

# Pick priority, icon, and message based on level
if [[ "$percentage" -le 10 ]]; then
    priority="urgent"
    icon="🪫"
    msg="Biakino server will soon shutdown unless plugged in."
elif [[ "$percentage" -le 20 ]]; then
    priority="high"
    icon="🪫"
    msg="Biakino server is running low. Plug in soon."
else
    priority="default"
    icon="🔋"
    msg="Biakino server is on battery."
fi

# Send notification
curl -s \
    -H "Title: ${icon} ${percentage}% — Plug in charger" \
    -H "Priority: $priority" \
    -d "$msg" \
    "$NTFY_URL" > /dev/null

# Record that we notified at this threshold
echo "$current_threshold" > "$STATE_FILE"

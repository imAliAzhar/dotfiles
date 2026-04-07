#!/bin/bash
# Toggle aerospace workspace-to-monitor assignment between built-in and external monitor

CONFIG="$HOME/.config/aerospace/aerospace.toml"

# Check current state by looking at line after built-in marker
if sed -n '/@monitor-toggle:built-in/{n;p;}' "$CONFIG" | grep -q "^0 = "; then
    # Currently built-in mode -> switch to external
    sed -i '' '/@monitor-toggle:built-in/{n;s/^/# /;n;s/^/# /;}' "$CONFIG"
    sed -i '' '/@monitor-toggle:external/{n;s/^# //;n;s/^# //;}' "$CONFIG"
    echo "Switched to external monitor"
else
    # Currently external mode -> switch to built-in
    sed -i '' '/@monitor-toggle:built-in/{n;s/^# //;n;s/^# //;}' "$CONFIG"
    sed -i '' '/@monitor-toggle:external/{n;s/^/# /;n;s/^/# /;}' "$CONFIG"
    echo "Switched to built-in monitor"
fi

# Reload aerospace config
aerospace reload-config

#!/bin/bash
# Sync sketchybar display settings based on current monitor count

count=$(system_profiler SPDisplaysDataType 2>/dev/null | grep -c "Resolution:")

sketchybar --bar display="$count"

if [ "$count" -gt 1 ]; then
  bottom_bar --bar hidden=false
else
  bottom_bar --bar hidden=true
fi

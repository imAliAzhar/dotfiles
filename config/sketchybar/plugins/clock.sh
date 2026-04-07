#!/bin/sh

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

FORMAT="+%-I:%M" # default (top bar)

if [ "$BAR_NAME" = "bottom_bar" ]; then
  FORMAT="+%a %d. %b %-I:%M%p"
fi

$BAR_NAME --set "$NAME" label="$(date "$FORMAT")"

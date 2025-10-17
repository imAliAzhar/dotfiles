#!/bin/sh

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

# case "${PERCENTAGE}" in
#   9[0-9]|100) ICON="" # 
#   ;;
#   [6-8][0-9]) ICON="" # 
#   ;;
#   [3-5][0-9]) ICON="" # 
#   ;;
#   [1-2][0-9]) ICON=""
#   ;;
#   *) ICON=""
# esac

case "${PERCENTAGE}" in
  9[0-9]|100) ICON="⣿"   # full
  ;;
  [7-8][0-9]) ICON="⣦"   # high
  ;;
  [4-6][0-9]) ICON="⣤"   # medium
  ;;
  [2-3][0-9]) ICON="⣄"   # low
  ;;
  *) ICON="⣀"            # empty/critical
  ;;
esac

if [[ "$CHARGING" != "" ]]; then
  ICON="⧗"
fi


COLOR=0x65FFFFFF

if [ "$PERCENTAGE" -le 5 ]; then
  COLOR=0xFF970000
fi

# The item invoking this script (name $NAME) will get its icon and label
# updated with the current battery status
sketchybar --set "$NAME" label="$ICON $PERCENTAGE%" label.color=$COLOR

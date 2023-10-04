#!/bin/zsh

OPACITY=${1?Pass OPACITY value}

current_opacity=$(yabai -m query --windows --window | jq ".opacity")

if [ $current_opacity != $OPACITY ]
then
  yabai -m window --opacity $OPACITY
else
  yabai -m window --opacity 1.0
fi

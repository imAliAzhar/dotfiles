#!/bin/zsh

current_layout=$(yabai -m query --spaces --space | jq ".type")

if [ $current_layout != "bsp" ]
then
  echo yo
  yabai -m space --layout bsp
else
  echo no
  yabai -m space --layout stack
  yabai -m space --mirror y-axis
fi
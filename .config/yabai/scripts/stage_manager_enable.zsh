#!/bin/zsh

yabai -m space --layout stack

yabai -m config top_padding    80
yabai -m config bottom_padding 80
yabai -m config left_padding   200
yabai -m config right_padding  200

defaults write com.apple.WindowManager GloballyEnabled -bool true

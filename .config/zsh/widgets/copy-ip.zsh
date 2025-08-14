#!/bin/zsh
#
function ip() {
  ipconfig getifaddr en0 | tr -d '\n' | pbcopy
  pbpaste | xargs echo Copied IP to clipboard: 
}

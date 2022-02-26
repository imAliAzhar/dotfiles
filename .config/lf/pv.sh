#!/bin/sh

case `file --mime-type "$1" -bL` in
  text/*|application/json) bat --color always --theme base16 "$1";;
  *) echo Previewer not configured for "$1";;
esac

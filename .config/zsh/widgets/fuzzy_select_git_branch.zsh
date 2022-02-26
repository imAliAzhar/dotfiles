#!/bin/sh

script=`basename $0`

function widget() {
  local branches branch
  branches=`git --no-pager branch` &&
    branch=`echo "$branches" | fzf +m` &&
    output=`echo "$branch" | sed 's/\*//' | awk '{print $1}' | sed "s/.* //"`
      zle reset-prompt
      BUFFER="$LBUFFER$output "
      zle end-of-line
    }

  zle -N $script widget
  bindkey '^g' $script


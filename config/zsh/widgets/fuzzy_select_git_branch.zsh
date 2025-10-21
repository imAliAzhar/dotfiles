#!/bin/sh

script=`basename $0`

function fuzzy_git_branch() {
  local branches branch
  branches=`git --no-pager branch --color=always` &&
    branch=`echo "$branches" | fzf +m --ansi` &&
    output=`echo "$branch" | sed 's/\*//' | awk '{print $1}' | sed "s/.* //"`
      zle reset-prompt
      BUFFER="$LBUFFER$output "
      zle end-of-line
    }

  zle -N $script fuzzy_git_branch
  bindkey '^g' $script


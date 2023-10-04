#!/bin/sh

script=`basename $0`

function fuzzy_git_commit() {
  local commits commit
  commits=`git l --color=always` &&
    commit=`echo "$commits" | fzf +m --ansi` &&
    output=`echo "$commit" | awk '{print $1}' | sed "s/.* //"`
      zle reset-prompt
      BUFFER="$LBUFFER$output "
      zle end-of-line
    }

  zle -N $script fuzzy_git_commit
  bindkey '^[g' $script



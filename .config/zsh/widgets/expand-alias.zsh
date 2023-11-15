zstyle ':completion:*' completer _expand_alias _complete _ignored

IGNORED_ALIASES="dot ls cd"


# expand with space
function expand-alias() {
	if ! [[ " $IGNORED_ALIASES " =~ .*\ $LBUFFER\ .* ]]; then
		zle _expand_alias
	fi

	zle self-insert
}
zle -N expand-alias

bindkey -M main ' ' expand-alias

# Test with:
# time ZSH_DEBUGRC=1 zsh -i -c exit

if [ -n "${ZSH_DEBUGRC+1}" ]; then
    zmodload zsh/zprof
fi

# rest of .zshrc script

if [ -n "${ZSH_DEBUGRC+1}" ]; then
    zprof
fi

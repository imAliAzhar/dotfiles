export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"
export FZF_DEFAULT_OPTS="--bind ctrl-j:accept"
export HISTTIMEFORMAT="%d/%m/%y %T "

export MYVIMRC=~/.config/nvim/init.vim

export EDITOR="nvim"
export NVM_DIR="$HOME/.nvm"

# export KEYTIMEOUT=1      # Needed for vi mode

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# pnpm
export PNPM_HOME="/Users/imaliazhar/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

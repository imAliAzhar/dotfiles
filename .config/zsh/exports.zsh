export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"
export HISTTIMEFORMAT="%d/%m/%y %T "

export FZF_DEFAULT_OPTS="\

--bind ctrl-j:accept
--ansi --header '' --padding 5% --prompt '♯ ' --pointer ▸
--color='pointer:bright-yellow,gutter:-1,bg+:-1,fg+:bright-yellow:bold'"

export MYVIMRC=~/.config/nvim/init.vim

export EDITOR="hx"
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

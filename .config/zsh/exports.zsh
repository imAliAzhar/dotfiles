export HISTTIMEFORMAT="%d/%m/%y %T "

export FZF_DEFAULT_OPTS="\
--bind ctrl-j:accept
--ansi --header '' --padding 5% --prompt '♯ ' --pointer ▸
--color='pointer:bright-yellow,gutter:-1,bg+:-1,fg+:bright-yellow:bold'"

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

export GH_PACKAGES_TOKEN=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

if defaults read -g AppleInterfaceStyle &>/dev/null; then
  unset LIGHT_THEME
else
  export LIGHT_THEME=true
fi

### LAZYGIT THEME
################################################################################
export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/theme.yml"


### PATH
################################################################################

export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"

export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.emacs.d/bin:$PATH"


### ANDROID
################################################################################

export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools


### NODE
################################################################################

export PATH="/Users/aliazhar.khan/.local/state/fnm_multishells/33506_1735933747716/bin":$PATH
export FNM_MULTISHELL_PATH="/Users/aliazhar.khan/.local/state/fnm_multishells/33506_1735933747716"
export FNM_VERSION_FILE_STRATEGY="local"
export FNM_DIR="/Users/aliazhar.khan/Library/Application Support/fnm"
export FNM_LOGLEVEL="info"
export FNM_NODE_DIST_MIRROR="https://nodejs.org/dist"
export FNM_COREPACK_ENABLED="false"
export FNM_RESOLVE_ENGINES="true"
export FNM_ARCH="arm64"

eval "$(fnm env --use-on-cd)"

rehash


### BUN
################################################################################

export BUN_INSTALL="$HOME/.bun"

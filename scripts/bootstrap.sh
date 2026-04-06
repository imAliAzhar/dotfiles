#!/usr/bin/env bash

# Enable strict error handling
set -euo pipefail

# Environment variables
DRY_RUN="${DRY_RUN:-0}"
VERBOSE="${VERBOSE:-1}"

# ANSI color codes
ANSI_GRAY="\033[90m"
ANSI_RESET="\033[0m"

DIR="/tmp/bootstrap"
APP_INSTALLERS_DIR="$DIR/app_installers"
DOTFILES="$HOME/Dotfiles"

log() {
  echo
  echo -e "$*"
}

run() {
  if [[ "$DRY_RUN" == "1" ]] || [[ "$VERBOSE" == "1" ]]; then
    echo -e "${ANSI_GRAY}\$ $*${ANSI_RESET}" >&2

    if [[ "$DRY_RUN" == "1" ]]; then
      return 0
    fi
  fi

  printf "${ANSI_GRAY}" >&2
  "$@"
  local exit_code=$?
  printf "${ANSI_RESET}" >&2

  return $exit_code
}

install_mac_cli_tools() {
  log "Checking Command Line Tools for Xcode..."

  if xcode-select -p >/dev/null 2>&1; then
    log "Command Line Tools already installed."
    return 0
  fi

  local flag="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
  # Create the flag so softwareupdate lists CLT
  run sudo touch "$flag"

  local listing
  if ! listing="$(softwareupdate -l 2>/dev/null)"; then
    run sudo rm -f "$flag"
    echo "Error: softwareupdate -l failed."
    return 1
  fi

  # Extract the latest CLT product label
  # Handles formats like:
  #   * Label: Command Line Tools for Xcode-15.3
  #   *   Command Line Tools for Xcode-15.3
  local prod
  prod="$(printf '%s\n' "$listing" |
    sed -n 's/^[[:space:]]*\*[[:space:]]*Label:[[:space:]]*//p; s/^[[:space:]]*\*[[:space:]]*//p' |
    grep -i 'Command Line Tools' |
    tail -n 1)"

  if [[ -z "$prod" ]]; then
    # Clean up the flag and fall back to GUI prompt
    run sudo rm -f "$flag"
    log "Command Line Tools not listed by softwareupdate; falling back to GUI prompt..."
    xcode-select --install >/dev/null 2>&1 || true
    return 0
  fi

  log "Installing: $prod"
  run sudo softwareupdate -i "$prod" --verbose

  run sudo rm -f "$flag"

  log "Command Line Tools for Xcode installed."
}

clone_dotfiles_repo() {
  if [[ -d "$DOTFILES/.git" ]]; then
    log "Dotfiles repo already exists, pulling latest..."
    run git -C "$DOTFILES" pull --ff-only
    return 0
  fi

  log "Cloning Dotfiles repository..."
  run git clone https://github.com/imAliAzhar/dotfiles.git "$DOTFILES"
}

setup_dirs() {
  run mkdir -p "$DIR"
  run mkdir -p "$APP_INSTALLERS_DIR"
}

install_homebrew() {
  log "Checking Homebrew..."

  # Add Homebrew to PATH for current session
  # Homebrew installs to /opt/homebrew on Apple Silicon, /usr/local on Intel
  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  if command -v brew &>/dev/null; then
    log "Homebrew already installed"
    return 0
  fi

  log "Installing Homebrew..."
  run bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH again after installation
  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  log "Homebrew installed"
}

ensure_symlink() {
  local target="$1"
  local link="$2"

  if [[ -L "$link" && "$(readlink "$link")" == "$target" ]]; then
    return 0
  fi

  # Remove whatever is there (stale symlink, file, or directory)
  if [[ -e "$link" || -L "$link" ]]; then
    run rm -rf "$link"
  fi

  run mkdir -p "$(dirname "$link")"
  run ln -s "$target" "$link"
}

setup_dotfiles() {
  log "Creating symlinks for dotfiles..."

  ensure_symlink "$DOTFILES/config" ~/.config
  ensure_symlink "$DOTFILES/bin" ~/.local/bin
  ensure_symlink "$DOTFILES/zsh/zshenv" ~/.zshenv
  ensure_symlink "$DOTFILES/emacs/config.el" ~/.emacs

  run mkdir -p ~/.claude
  ensure_symlink "$DOTFILES/config/claude/settings.json" ~/.claude/settings.json
  ensure_symlink "$DOTFILES/config/claude/statusline-command.sh" ~/.claude/statusline-command.sh
}

setup_alfred() {
  log "Setting up Alfred preferences symlink..."

  local alfred_support_dir="$HOME/Library/Application Support/Alfred"
  local alfred_prefs="$alfred_support_dir/Alfred.alfredpreferences"
  local dotfiles_prefs="$DOTFILES/config/alfred/Alfred.alfredpreferences"

  # Check if dotfiles contains Alfred preferences
  if [[ ! -d "$dotfiles_prefs" ]]; then
    log "Alfred preferences not found in dotfiles, skipping..."
    return 0
  fi

  # Skip if symlink already exists and points to correct location
  if [[ -L "$alfred_prefs" && "$(readlink "$alfred_prefs")" == "$dotfiles_prefs" ]]; then
    log "Alfred symlink already configured"
    return 0
  fi

  # Remove existing preferences (backup if not a symlink)
  if [[ -d "$alfred_prefs" && ! -L "$alfred_prefs" ]]; then
    log "Backing up existing Alfred preferences..."
    run mv "$alfred_prefs" "$alfred_prefs.backup"
  elif [[ -L "$alfred_prefs" ]]; then
    run rm "$alfred_prefs"
  fi

  run mkdir -p "$alfred_support_dir"
  run ln -s "$dotfiles_prefs" "$alfred_prefs"

  log "Alfred preferences symlinked"
}

download() {
  local url="$1"

  if [[ "$DRY_RUN" == "1" ]]; then
    run curl -LOJ "$url"
    echo "dry-run.dmg"
    return 0
  fi

  run curl -LOJ -w "%{filename_effective}" "$url"
}

install_mac_app_from_dmg() {
  local app="$1"
  local dmg_path="$2"

  if [ -z "$app" ] || [ -z "$dmg_path" ]; then
    echo "Error: Both app name and DMG path are required"
    echo "Usage: install_mac_app_from_dmg <app_name> <dmg_path>"
    return 1
  fi

  log "Installing $app from DMG..."

  run hdiutil attach "$dmg_path"

  # Find the mounted volume
  local volume=$(ls -1 /Volumes | grep -i "$app" | head -n 1)
  if [[ -z "$volume" ]]; then
    volume=$(ls -1t /Volumes | head -n 1)
  fi

  # Find .app file in the mounted volume
  local app_path=$(find "/Volumes/$volume" -name "*.app" -maxdepth 2 | head -n 1)

  if [[ -n "$app_path" ]]; then
    run cp -r "$app_path" /Applications/
  else
    echo "Error: Could not find .app file in DMG"
    exit 1
  fi

  run hdiutil detach "/Volumes/$volume" -quiet
}

install_mac_app_from_zip() {
  local app="$1"
  local zip_path="$2"

  if [ -z "$app" ] || [ -z "$zip_path" ]; then
    echo "Error: Both app name and ZIP path are required"
    echo "Usage: install_mac_app_from_zip <app_name> <zip_path>"
    return 1
  fi

  log "Installing $app from ZIP..."

  local extract_dir="$APP_INSTALLERS_DIR/${app}_extracted"
  run mkdir -p "$extract_dir"
  run unzip -q "$zip_path" -d "$extract_dir"

  # Find .app file in the extracted directory
  local app_path=$(find "$extract_dir" -name "*.app" -maxdepth 3 | head -n 1)

  if [[ -n "$app_path" ]]; then
    run cp -r "$app_path" $HOME/Applications/
  else
    echo "Error: Could not find .app file in ZIP"
    exit 1
  fi

  run rm -rf "$extract_dir"
}

app_is_installed() {
  local app="$1"
  local found
  found=$(find /Applications "$HOME/Applications" -maxdepth 2 -name "${app}*.app" 2>/dev/null | head -n 1)
  [[ -n "$found" ]]
}

install_mac_app_from_url() {
  local app="$1"
  local url="$2"

  if [ -z "$app" ] || [ -z "$url" ]; then
    echo "Error: Both app name and URL are required"
    echo "Usage: install_mac_app_from_url <app_name> <url>"
    return 1
  fi

  if app_is_installed "$app"; then
    log "$app already installed, skipping"
    return 0
  fi

  run cd "$APP_INSTALLERS_DIR"

  log "Downloading $app from $url..."

  local filename="$(download "$url")"
  local extension="${filename##*.}"

  case $extension in
  dmg)
    install_mac_app_from_dmg "$app" "$APP_INSTALLERS_DIR/$filename"
    ;;
  zip)
    install_mac_app_from_zip "$app" "$APP_INSTALLERS_DIR/$filename"
    ;;
  *)
    echo "Error: Unsupported file format .$extension"
    echo "Supported formats: dmg, zip"
    return 1
    ;;
  esac

  run cd - >/dev/null
  run rm "$APP_INSTALLERS_DIR/$filename"

  log "$app installed successfully"
}

install_mac_app_from_gh_releases() {
  local app="$1"
  local repo_url="$2"

  if [[ -z "$app" || -z "$repo_url" ]]; then
    echo "Error: Both app name and GitHub repo URL are required"
    echo "Usage: install_mac_app_from_gh_releases <app_name> <https://github.com/owner/repo>"
    return 1
  fi

  if app_is_installed "$app"; then
    log "$app already installed, skipping"
    return 0
  fi

  # Normalize to GitHub Releases API
  local api_url="${repo_url/github.com/api.github.com/repos}/releases/latest"

  log "Searching latest release for $app at $api_url..."

  if [[ "$DRY_RUN" == "1" ]]; then
    run curl -fsSL "$api_url"
    install_mac_app_from_url "$app" "https://github.com/dry-run/$app.dmg"
    return 0
  fi

  release_json="$(curl -fsSL "$api_url")"

  download_url="$(
    printf '%s' "$release_json" |
      jq -r '
      .assets
      | map({name: .name, url: .browser_download_url})
      | map(select(.name | test("macos|darwin"; "i") and (.name | test("\\.(dmg|zip)$"; "i"))))
      | sort_by(
          # Primary: dmg (0 is higher priority than 1)
          (if .name | test("\\.dmg$"; "i") then 0 else 1 end),
          # Secondary: macos/darwin match specificity (already filtered, but we still include)
          (if .name | test("macos"; "i") then 0
           elif .name | test("darwin"; "i") then 1 else 2 end),
          # Tertiary: zip fallback
          (if .name | test("\\.zip$"; "i") then 1 else 0 end)
        )
      | .[0].url
    '
  )"

  if [[ -z "$download_url" ]]; then
    echo "No macOS asset found for $app"
    return 1
  fi

  local filename="${download_url##*/}"
  log "Found macOS installer for $app: $filename"
  install_mac_app_from_url "$app" "$download_url"
}

setup_dock() {
  log "Configuring Dock..."

  local dock_changed=0
  if [[ "$(defaults read com.apple.dock autohide-delay 2>/dev/null)" != "0" ]]; then
    defaults write com.apple.dock autohide-delay -float 0
    dock_changed=1
  fi
  if [[ "$(defaults read com.apple.dock autohide-time-modifier 2>/dev/null)" != "0" ]]; then
    defaults write com.apple.dock autohide-time-modifier -int 0
    dock_changed=1
  fi
  if [[ "$dock_changed" == "1" ]]; then
    killall Dock
    log "Dock settings updated"
  fi
}

main() {
  log "Bootstrapping macOS environment..."

  setup_dirs
  install_mac_cli_tools
  clone_dotfiles_repo
  install_homebrew
  setup_dotfiles
  setup_alfred

  run brew install \
    atuin \
    bat \
    btop \
    difftastic \
    dust \
    eza \
    fd \
    felixkratz/formulae/sketchybar \
    figlet \
    fzf \
    gh \
    git-delta \
    httpie \
    jq \
    lazygit \
    lstr \
    lua-language-server \
    massren \
    neovim \
    ripgrep \
    stylua \
    tmux \
    trash \
    yazi

  install_mac_app_from_url "Arc" "https://releases.arc.net/release/Arc-latest.dmg"
  install_mac_app_from_url "Alfred" "https://cachefly.alfredapp.com/Alfred_5.7.1_2307.dmg"
  install_mac_app_from_url "ChatGPT" "https://persistent.oaistatic.com/sidekick/public/ChatGPT.dmg"
  install_mac_app_from_url "ProtonVPN" "https://vpn.protondownload.com/download/macos/6.0.0/ProtonVPN_mac_v6.0.0.dmg"
  install_mac_app_from_url "qBittorrent" "https://sourceforge.net/projects/qbittorrent/files/qbittorrent-mac/qbittorrent-5.0.5/qbittorrent-5.0.5.dmg/download"
  install_mac_app_from_url "WhatsApp" "https://web.whatsapp.com/desktop/mac_native/release/?configuration=Release&src=whatsapp_downloads_page"

  install_mac_app_from_gh_releases "Wezterm" "https://github.com/wezterm/wezterm"
  install_mac_app_from_gh_releases "Karabiner" "https://github.com/pqrs-org/Karabiner-Elements"
  install_mac_app_from_gh_releases "Hammerspoon" "https://github.com/Hammerspoon/hammerspoon"
  install_mac_app_from_gh_releases "IINA" "https://github.com/iina/iina"

  setup_dock
}

main

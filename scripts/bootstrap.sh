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
  local dry_run_override="$DRY_RUN"

  if [[ "$1" == "-n" ]]; then
    dry_run_override=1
    shift
  fi

  if [[ "$dry_run_override" == "1" ]] || [[ "$VERBOSE" == "1" ]]; then
    echo -e "${ANSI_GRAY}\$ $*${ANSI_RESET}" >&2

    if [[ "$dry_run_override" == "1" ]]; then
      return 0
    fi
  fi

  printf "${ANSI_GRAY}" >&2
  "$@"
  local exit_code=$?
  printf "${ANSI_RESET}" >&2

  return $exit_code
}

clone_dotfiles_repo() {
  log "Cloning Dotfiles repository..."

  run git clone https://github.com/imAliAzhar/dotfiles.git "$DOTFILES"
}

setup_dirs() {
  run rm -rf "$DIR"

  run mkdir -p "$DIR"
  run mkdir -p "$APP_INSTALLERS_DIR"
}

install_homebrew() {
  log "Installing Homebrew..."
  run bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH for current session
  # Homebrew installs to /opt/homebrew on Apple Silicon, /usr/local on Intel
  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

setup_dotfiles() {
  log "Creating symlinks for dotfiles..."

  run rm -r ~/.config
  run ln -s "$DOTFILES/config" ~/.config

  run rm -r ~/.local/bin
  run ln -s "$DOTFILES/bin" ~/.local/bin

  run ln -s "$DOTFILES/zsh/zshenv" ~/.zshenv

  run ln -s "$DOTFILES/emacs/config.el" ~/.emacs
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

install_mac_app_from_url() {
  local app="$1"
  local url="$2"

  if [ -z "$app" ] || [ -z "$url" ]; then
    echo "Error: Both app name and URL are required"
    echo "Usage: install_mac_app_from_url <app_name> <url>"
    return 1
  fi

  run cd "$APP_INSTALLERS_DIR"

  log "Downloading $app from $url..."

  local filename="$(run curl -LOJ -w "%{filename_effective}" $url)"
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

  # Normalize to GitHub Releases API
  local api_url="${repo_url/github.com/api.github.com/repos}/releases/latest"

  log "Searching latest release for $app at $api_url..."

  release_json="$(run curl -fsSL "$api_url")"

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

main() {
  log "Bootstrapping macOS environment..."

  setup_dirs
  clone_dotfiles_repo
  install_homebrew
  setup_dotfiles

  brew install \
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
  install_mac_app_from_url "qBittorent" "https://sourceforge.net/projects/qbittorrent/files/qbittorrent-mac/qbittorrent-5.0.5/qbittorrent-5.0.5.dmg/download"
  install_mac_app_from_url "WhatsApp" "https://web.whatsapp.com/desktop/mac_native/release/?configuration=Release&src=whatsapp_downloads_page"

  install_mac_app_from_gh_releases "Wezterm" "https://github.com/wezterm/wezterm"
  install_mac_app_from_gh_releases "Karabiner" "https://github.com/pqrs-org/Karabiner-Elements"
  install_mac_app_from_gh_releases "Hammerspoon" "https://github.com/Hammerspoon/hammerspoon"
  install_mac_app_from_gh_releases "IINA" "https://github.com/iina/iina"
}

main

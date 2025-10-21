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
  *)
    echo "Error: Unsupported file format .$extension"
    echo "Supported formats: dmg"
    return 1
    ;;
  esac

  run cd - >/dev/null
  run rm "$APP_INSTALLERS_DIR/$filename"

  log "$app installed successfully"
}

main() {
  log "Bootstrapping macOS environment..."

  setup_dirs
  clone_dotfiles_repo
  install_homebrew
  setup_dotfiles

  install_mac_app_from_url "Arc" "https://releases.arc.net/release/Arc-latest.dmg"

}

main

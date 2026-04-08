#!/usr/bin/env bash

# Self-contained Jellyfin Media Server setup via Colima + Docker Compose (headless)
# Usage: bash setup-jellyfin.sh
#   Environment variables:
#     JELLYFIN_MEDIA_DIR  - path to media library (default: ~/media)
#     JELLYFIN_PORT       - HTTP port (default: 8096)
#     DRY_RUN=1           - print commands without executing

set -euo pipefail

DRY_RUN="${DRY_RUN:-0}"

JELLYFIN_PORT="${JELLYFIN_PORT:-8096}"
JELLYFIN_MEDIA_DIR="${JELLYFIN_MEDIA_DIR:-$HOME/media}"
JELLYFIN_DIR="$HOME/.config/jellyfin"

ANSI_GRAY="\033[90m"
ANSI_RESET="\033[0m"

log() {
  echo
  echo -e "$*"
}

run() {
  if [[ "$DRY_RUN" == "1" ]]; then
    echo -e "${ANSI_GRAY}\$ $*${ANSI_RESET}" >&2
    return 0
  fi

  echo -e "${ANSI_GRAY}\$ $*${ANSI_RESET}" >&2
  printf "${ANSI_GRAY}" >&2
  "$@"
  local exit_code=$?
  printf "${ANSI_RESET}" >&2
  return $exit_code
}

install_deps() {
  if ! command -v brew &>/dev/null; then
    echo "Error: Homebrew not found. Install it first."
    exit 1
  fi

  local deps=(colima docker docker-compose)
  local to_install=()

  for dep in "${deps[@]}"; do
    if ! command -v "$dep" &>/dev/null; then
      to_install+=("$dep")
    fi
  done

  if [[ ${#to_install[@]} -gt 0 ]]; then
    log "Installing ${to_install[*]}..."
    run brew install "${to_install[@]}"
  else
    log "All dependencies already installed"
  fi
}

start_colima() {
  if colima status 2>/dev/null | grep -q "Running"; then
    log "Colima already running"
    return 0
  fi

  log "Starting Colima..."
  run colima start
}

setup_dirs() {
  run mkdir -p "$JELLYFIN_DIR/config"
  run mkdir -p "$JELLYFIN_DIR/cache"
  run mkdir -p "$JELLYFIN_DIR/seerr"
  run mkdir -p "$JELLYFIN_DIR/radarr"
  run mkdir -p "$JELLYFIN_DIR/qbittorrent"
  run mkdir -p "$JELLYFIN_DIR/prowlarr"
  run mkdir -p "$JELLYFIN_MEDIA_DIR/movies"
  run mkdir -p "$JELLYFIN_MEDIA_DIR/downloads"
}

start_jellyfin() {
  log "Starting Jellyfin..."
  run docker-compose -f "$JELLYFIN_DIR/docker-compose.yml" up -d

  log "Jellyfin is running on port $JELLYFIN_PORT"
  log "Initial setup: http://<server-ip>:$JELLYFIN_PORT"
  log "Media directory: $JELLYFIN_MEDIA_DIR"
  log "Config directory: $JELLYFIN_DIR/config"
}

main() {
  log "Setting up Jellyfin Media Server..."

  install_deps
  start_colima
  setup_dirs
  start_jellyfin

  log "Jellyfin setup complete."
}

main

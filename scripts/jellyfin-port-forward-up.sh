#!/bin/sh
# gluetun VPN_PORT_FORWARDING_UP_COMMAND hook (mounted into the gluetun container).
#
# Runs INSIDE the gluetun container every time ProtonVPN assigns a forwarded
# port (on connect / reconnect / port change — not on keepalives).
#
#   $1 = the forwarded port (gluetun substitutes its {{PORTS}} placeholder).
#
# It does two things:
#   1. Points qBittorrent's listen port at the new forwarded port. qBittorrent
#      shares gluetun's network namespace, so its WebUI is at 127.0.0.1:8080.
#      Requires qBittorrent "Bypass authentication for clients on localhost".
#   2. Sends an ntfy push to the existing topic so you know the port rotated.
#
# Only wget is available in the gluetun image (no curl). Each call is best-effort
# (|| true) so one failing never blocks the other.

set -u

PORT="$1"
QBT_API="http://127.0.0.1:8080/api/v2/app/setPreferences"
NTFY_URL="https://ntfy.biakino.com/biakino-batt-k9x2f"

# 1. Update qBittorrent's listen port.
wget -qO- --retry-connrefused --tries=10 \
  --post-data "json={\"listen_port\":${PORT}}" \
  "$QBT_API" || true

# 2. Notify via ntfy.
wget -qO- \
  --post-data "ProtonVPN forwarded a new port ${PORT} — qBittorrent updated" \
  "$NTFY_URL" || true

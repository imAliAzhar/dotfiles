# Jellyfin Media Server Setup

All services run in Docker (via Colima), behind a Caddy reverse proxy, exposed to the internet through a Cloudflare Tunnel at `https://<service>.biakino.com`.

## Services

| Service      | URL                               | Purpose                          |
| ------------ | --------------------------------- | -------------------------------- |
| Jellyfin     | https://jellyfin.biakino.com      | Media server                     |
| Seerr        | https://seerr.biakino.com         | Request management (movies/shows)|
| Radarr       | https://radarr.biakino.com        | Movie management & automation    |
| Sonarr       | https://sonarr.biakino.com        | TV show management & automation  |
| qBittorrent  | https://qbt.biakino.com           | Torrent client (routed via VPN)  |
| Prowlarr     | https://prowlarr.biakino.com      | Indexer manager                  |
| Bazarr       | https://bazarr.biakino.com        | Subtitle management              |
| Gluetun      | --                                | VPN container (ProtonVPN)        |
| FlareSolverr | --                                | Captcha solver for indexers      |
| Cloudflared  | --                                | Cloudflare Tunnel connector      |
| ntfy         | https://ntfy.biakino.com          | Battery push notifications       |
| Caddy        | --                                | Reverse proxy                    |

## Architecture

```
Internet → Cloudflare (HTTPS) → Tunnel → Cloudflared → Caddy → Services
```

## Request Flow

```
Seerr (request) → Sonarr/Radarr (search & manage) → Prowlarr (indexers) → qBittorrent (download via VPN) → Bazarr (subtitles)
```

## Prerequisites

### 1. ProtonVPN WireGuard key

- Go to https://account.proton.me/u/0/vpn/WireGuard
- Set platform to **GNU/Linux**, enable **NAT-PMP (Port Forwarding)**, select a **Switzerland** server
- Click **Create** and copy the `PrivateKey` value from the generated config

### 2. Cloudflare Tunnel token

- Go to the [tunnel public hostnames](https://dash.cloudflare.com/cdc7848f97387f9bec4891fdf1e8a404/one/networks/connectors/cloudflare-tunnels/cfd_tunnel/b67f25e0-3ca2-46e3-bdc5-b99f79960b97/edit?tab=publicHostname) page
- Create a tunnel named `biakino`, choose **Cloudflared** connector
- Copy the tunnel token
- Under **Published application routes**, add a route for each service:

| Subdomain  | Domain      | Type | URL       |
| ---------- | ----------- | ---- | --------- |
| *(empty)*  | biakino.com | HTTP | caddy:80  |
| jellyfin   | biakino.com | HTTP | caddy:80  |
| seerr      | biakino.com | HTTP | caddy:80  |
| radarr     | biakino.com | HTTP | caddy:80  |
| sonarr     | biakino.com | HTTP | caddy:80  |
| prowlarr   | biakino.com | HTTP | caddy:80  |
| bazarr     | biakino.com | HTTP | caddy:80  |
| qbt        | biakino.com | HTTP | caddy:80  |
| ntfy       | biakino.com | HTTP | caddy:80  |

Cloudflare handles HTTPS automatically — the tunnel to Caddy is HTTP since it's already encrypted.

### 3. Create `.env` file

Create a `.env` file next to `docker-compose.yml`:
```
WIREGUARD_PRIVATE_KEY=your_private_key_here
TUNNEL_TOKEN=your_tunnel_token_here
```

### 4. Start Colima and services

```bash
colima start --cpu 4 --memory 4
docker-compose -f ~/.config/jellyfin/docker-compose.yml up -d
```

## Configuration Order

Set up services in this order, as each depends on the one before it.

### 1. Jellyfin (https://jellyfin.biakino.com)

- Complete the setup wizard (language, create admin account)
- Add media libraries:
  - Content type = Movies, folder = `/media/movies`
  - Content type = Shows, folder = `/media/shows`
- Skip metadata and remote access settings for now

### 2. qBittorrent (https://qbt.biakino.com)

- Default credentials: username `admin`, check logs for temporary password:
  ```
  docker logs qbittorrent
  ```
- Go to Settings > Downloads > Default Save Path, set to `/data/downloads`
- Change the default password in Settings > Web UI

### 3. Prowlarr (https://prowlarr.biakino.com)

- Set up authentication (Settings > General > Authentication)
- Add FlareSolverr as a proxy:
  - Settings > Indexer Proxies > Add > FlareSolverr
  - Tag: `flaresolverr`, Host: `http://flaresolverr:8191`
- Add indexers: Indexers > Add Indexer. Recommended indexers:
  - **1337x** — general purpose (add `flaresolverr` tag)
  - **YTS** — movies
  - **Knaben** — meta-search
  - **Nyaa** — anime
  - **BtDigg** — DHT search
  - Note: some indexers (EZTV, TorrentGalaxy) may be blocked depending on your region/VPN exit country
- Add Radarr as an app: Settings > Apps > Add > Radarr
  - Prowlarr Server: `http://prowlarr:9696`
  - Radarr Server: `http://radarr:7878`
  - API Key: copy from Radarr (Settings > General > API Key)
- Add Sonarr as an app: Settings > Apps > Add > Sonarr
  - Prowlarr Server: `http://prowlarr:9696`
  - Sonarr Server: `http://sonarr:8989`
  - API Key: copy from Sonarr (Settings > General > API Key)
- Click **Sync App Indexers** to push indexers to Radarr and Sonarr

### 4. Radarr (https://radarr.biakino.com)

- Add qBittorrent as download client:
  - Settings > Download Clients > Add > qBittorrent
  - Host: `gluetun` (qBittorrent shares gluetun's network), Port: `8080`
  - Enter qBittorrent username and password
- Configure root folder: Settings > Media Management > Root Folders > Add `/data/movies`
- Add quality profiles to your preference in Settings > Profiles

### 5. Sonarr (https://sonarr.biakino.com)

- Add qBittorrent as download client:
  - Settings > Download Clients > Add > qBittorrent
  - Host: `gluetun`, Port: `8080`
  - Enter qBittorrent username and password
- Configure root folder: Settings > Media Management > Root Folders > Add `/data/shows`
- Add quality profiles to your preference in Settings > Profiles

### 6. Bazarr (https://bazarr.biakino.com)

- Connect to Radarr: Settings > Radarr
  - Host: `radarr`, Port: `7878`
  - API Key: copy from Radarr (Settings > General > API Key)
- Connect to Sonarr: Settings > Sonarr
  - Host: `sonarr`, Port: `8989`
  - API Key: copy from Sonarr (Settings > General > API Key)
- Add subtitle providers: Settings > Providers, enable the following:
  - OpenSubtitles.com (requires account at https://www.opensubtitles.com)
  - YIFY Subtitles
  - subf2m.co
  - Subdl
  - Supersubtitles
- Configure languages: Settings > Languages, add your preferred subtitle languages

### 7. Seerr (https://seerr.biakino.com)

- Complete the setup wizard
- Connect to Jellyfin:
  - Hostname: `jellyfin`, Port: `8096`
  - Enter your Jellyfin admin credentials, select libraries to sync
- Connect to Radarr:
  - Hostname: `radarr`, Port: `7878`
  - API Key: copy from Radarr (Settings > General > API Key)
  - Select quality profile and root folder
- Connect to Sonarr:
  - Hostname: `sonarr`, Port: `8989`
  - API Key: copy from Sonarr (Settings > General > API Key)
  - Select quality profile and root folder
- Enable auto-approve for admin: Settings > Users > admin > Auto-Approve

## Creating Users

### Jellyfin

Dashboard > Users > Add User. Set username, password, and library access permissions.

### Seerr

Users > Create Local User, or share the Seerr URL and let users sign in via Jellyfin (configure under Settings > Jellyfin > Enable Sign-In).

To manage request permissions per user, go to Users > click a user > edit their permissions.

## Battery Monitor

A launchd agent checks battery level every 10 minutes. When the laptop is unplugged and drops below 50%, it sends push notifications via a self-hosted [ntfy](https://ntfy.sh) instance at `https://ntfy.biakino.com`. Notifications fire at decreasing thresholds from 50% down to 5%.

To receive notifications, install the ntfy app on your phone, set the server to `https://ntfy.biakino.com`, and subscribe to the topic `biakino-batt-k9x2f`.

## Verify VPN

Confirm qBittorrent traffic goes through ProtonVPN:
```
docker exec qbittorrent curl -s ifconfig.me
```
This should show a Swiss IP, not your real one. If gluetun goes down, qBittorrent loses all network access automatically.

## Local Network Access

For local access without going through Cloudflare, add subdomains to `/etc/hosts`.

Find the server's LAN IP:
```
ipconfig getifaddr en0
```

On macOS/Linux, add to `/etc/hosts`:
```
192.168.2.130	biakino.com jellyfin.biakino.com seerr.biakino.com radarr.biakino.com sonarr.biakino.com prowlarr.biakino.com bazarr.biakino.com qbt.biakino.com
```

Flush DNS cache on macOS:
```
sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder
```

On iOS/Android, there is no hosts file — you would need a DNS app or a local DNS server (e.g. Pi-hole) for those devices.

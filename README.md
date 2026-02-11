# marina-skill

Claude Code plugin for managing infrastructure — Hetzner Cloud servers, Cloudflare DNS, and Docker-based app deployments via git-push-to-deploy.

## Features

### Skills

- **server-management** — Create, list, and destroy Hetzner Cloud servers
- **server-bootstrap** — Bootstrap servers with Docker, Caddy reverse proxy, deploy user, and unattended upgrades
- **dns-management** — Manage Cloudflare DNS records (list zones, add/update/remove A records)
- **app-deployment** — Deploy apps via git-push-to-deploy with Docker Compose

### Commands

- `/marina-server` — Interactive server management (list, create, remove)
- `/marina-deploy` — Deploy the current project to a server
- `/marina-status` — Overview of all servers, IPs, and associated domains

## Prerequisites

Requires `hcloud`, `curl`, `jq`, `git`, `ssh`, and `scp`. Run the dependency check:

```bash
bash scripts/check-deps.sh
```

You'll also need:
- A [Hetzner Cloud](https://console.hetzner.cloud/) API token (configured via `hcloud context`)
- A [Cloudflare](https://dash.cloudflare.com/) API token (set as `CLOUDFLARE_API_TOKEN`)

## Installation

```bash
/plugin install marina-skill@focus-marketplace
```

Or install directly:

```bash
/plugin add The-Focus-AI/marina-skill
```

## License

MIT

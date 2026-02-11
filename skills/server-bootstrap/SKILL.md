---
name: server-bootstrap
description: Bootstrap and configure servers for Docker deployments - install Docker, set up Caddy reverse proxy, create deploy user, and configure unattended upgrades. Triggers on phrases like "bootstrap a server", "set up a server", "configure a server", "install Docker", "set up Caddy", "update deployer".
allowed-tools: Bash, Read
---

# Server Bootstrap Skill

You help bootstrap remote servers for Docker-based deployments.

## Setup

1. Run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/check-deps.sh` to verify tools are available.
2. If `.claude/marina-skill.local.md` exists, read it for `caddy_email`. This is used for HTTPS certificate registration.

## Scripts

### Full bootstrap
```bash
CADDY_EMAIL=user@example.com bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh full <server_ip>
```

This SSHes into the server as root and:
1. Updates packages, installs unattended-upgrades, jq, git
2. Installs Docker (if not present)
3. Creates a `deploy` user with SSH forced-command restriction
4. Starts Caddy reverse proxy (auto-HTTPS via Docker labels)
5. Deploys the `deployer` and `post-receive` scripts

### Update deployer only
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh update-deployer <server_ip>
```

Updates the deployer and post-receive scripts on the server without re-running the full bootstrap.

## What Gets Installed

### Deploy user
- User `deploy` in the `docker` group
- SSH forced command: `/home/deploy/deployer admin`
- Restrictions: no port forwarding, no X11, no agent forwarding, no PTY
- Passwordless sudo

### Caddy reverse proxy
- Image: `lucaslorentz/caddy-docker-proxy:ci-alpine`
- Ports: 80, 443 (TCP+UDP)
- Docker network: `caddy`
- Volumes: `caddy_data`, `caddy_config`
- Configures itself automatically from Docker container labels
- `CADDY_EMAIL` sets the email for Let's Encrypt certificates

### Deployer
- Handles incoming git pushes via SSH forced command
- Creates bare git repos on first push
- Triggers Docker builds via post-receive hook
- Restarts containers with Caddy labels for auto-routing

## Behavior

- Before bootstrapping, verify the server exists and you have its IP
- Warn that this SSHes in as root and installs software
- Bootstrap takes a few minutes — set expectations
- Safe to re-run (all steps are idempotent)
- If `caddy_email` is not configured, ask the user for their email

---
name: server-management
description: Manage Hetzner Cloud servers - create, list, get IPs, and destroy servers. Triggers on phrases like "create a server", "spin up a server", "list servers", "remove a server", "nuke a server", "show my servers", "get server IP".
allowed-tools: Bash, Read
---

# Server Management Skill

You help manage Hetzner Cloud servers.

## Setup

1. Run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/check-deps.sh` to verify `hcloud` and other tools are available.
2. If `.claude/marina-skill.local.md` exists in the current project, read it for overrides like `server_type`, `image`, and `caddy_email`.

## Scripts

All server operations use `${CLAUDE_PLUGIN_ROOT}/scripts/server.sh`:

### List servers
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/server.sh list
```

### Get server IP
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/server.sh ip <name>
```

### Create a server
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/server.sh add <name>
```
Default type `cax11` (ARM), image `debian-13`. Override with env vars:
```bash
SERVER_TYPE=cx23 IMAGE=debian-13 bash ${CLAUDE_PLUGIN_ROOT}/scripts/server.sh add <name>
```

**After creating**, the server needs to be bootstrapped and have DNS configured. Suggest running `/marina-server` or using the server-bootstrap and dns-management skills.

### Delete a server
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/server.sh rm <name>
```
**DESTRUCTIVE.** Always require explicit user confirmation. Show the server name and IP before deleting.

## Domain Discovery

To see what domains the user manages, use the dns skill's zone listing:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/dns.sh list-zones
```

To see DNS records pointing to a server's IP, list records for the zone and filter by IP:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/dns.sh list <domain> | grep <server_ip>
```

## Workflow: Create + Bootstrap + DNS

A full server setup is:
1. `server.sh add <name>` — create the Hetzner server
2. Wait ~5 seconds for it to come online
3. `server.sh ip <name>` — get the IP
4. `dns.sh add <name>.<domain> <ip>` — add DNS record
5. `bootstrap.sh full <ip>` — bootstrap Docker, Caddy, deploy user

## Workflow: Nuke a Server

1. `dns.sh list <domain> | grep <server_ip>` — find all DNS records for this server
2. `dns.sh rm <fqdn>` for each record — remove DNS entries
3. `server.sh rm <name>` — delete the server
4. Always confirm with user before each destructive step.

## Behavior

- Always list current servers first so the user can see what exists
- When creating servers, suggest a sensible name based on context
- When nuking, show associated DNS names first and require explicit confirmation
- If `hcloud` is not configured, help the user with `hcloud context create`

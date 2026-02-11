---
description: Interactive server management - list, create, or remove Hetzner Cloud servers
allowed-tools: Bash, Read
---

# Marina Server Management

## Setup

1. Run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/check-deps.sh` to verify dependencies.
2. If `.claude/marina-skill.local.md` exists, read it for `caddy_email`, `server_type`, `image`.

## Steps

1. **Show current servers:**
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/server.sh list
   ```

2. **Discover domains:**
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/dns.sh list-zones
   ```

3. **Ask the user** what they'd like to do:

   - **Create a server** — Ask for a name, confirm settings, then:
     1. `bash ${CLAUDE_PLUGIN_ROOT}/scripts/server.sh add <name>` (use `SERVER_TYPE` / `IMAGE` env vars if overridden)
     2. Wait 5 seconds: `sleep 5`
     3. Get IP: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/server.sh ip <name>`
     4. Add DNS: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/dns.sh add <name>.<domain> <ip>`
     5. Bootstrap: `CADDY_EMAIL=<email> bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh full <ip>`

   - **View server details** — Show IP and DNS records pointing to it:
     ```bash
     bash ${CLAUDE_PLUGIN_ROOT}/scripts/server.sh ip <name>
     bash ${CLAUDE_PLUGIN_ROOT}/scripts/dns.sh list <domain> | grep <ip>
     ```

   - **Remove a server** — Show all DNS records first, **require explicit confirmation**, then:
     1. Remove each DNS record: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/dns.sh rm <fqdn>`
     2. Delete server: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/server.sh rm <name>`

4. Show the updated server list after the operation.

## Important

- Server creation includes full bootstrap and takes a few minutes.
- Nuking deletes DNS records too. Always show what will be destroyed.
- If `hcloud` is not configured, help with `hcloud context create`.

---
name: dns-management
description: Manage Cloudflare DNS records - list zones and records, add/update A records, remove records. Discovers domains dynamically from Cloudflare. Triggers on phrases like "add DNS record", "remove DNS", "list DNS", "Cloudflare DNS", "add subdomain", "point domain to server", "what domains do I have", "list zones".
allowed-tools: Bash, Read
---

# DNS Management Skill

You help manage Cloudflare DNS records.

## Setup

1. Run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/check-deps.sh` to verify `curl` and `jq` are available.
2. The `CF_TOKEN` environment variable must be set. The dns script checks environment first, then `.env` in the current directory. If neither works, help the user set it up.

## Domain Discovery

**Never assume a domain.** Always discover what's available:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/dns.sh list-zones
```

This returns all Cloudflare zones (domains) the user manages, with IDs and status.

## Scripts

All DNS operations use `${CLAUDE_PLUGIN_ROOT}/scripts/dns.sh`:

### List all zones (domains)
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/dns.sh list-zones
```

### List records in a zone
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/dns.sh list <domain>
```
Returns: `<id> <type> <fqdn> <content>` for each record.

### Add or update an A record
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/dns.sh add <fqdn> <ip>
```
Pass the **full domain name** (e.g., `myapp.example.com`). The script extracts the zone from the last two parts of the FQDN. Creates the record if it doesn't exist, updates if it does. TTL=1, proxied=false.

### Remove a DNS record
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/dns.sh rm <fqdn>
```
**DESTRUCTIVE.** Always confirm with the user before removing records.

## Authentication

The script needs `CF_TOKEN` (Cloudflare API token). It loads from:
1. `CF_TOKEN` environment variable
2. `.env` file in the current working directory

If not available, help the user:
```bash
export CF_TOKEN=<their-cloudflare-api-token>
```
Or create a `.env` file with `CF_TOKEN=...`.

## Behavior

- When asked about domains, run `list-zones` first
- Present DNS records in a clean table format
- When adding records, show the full FQDN that will be created and confirm
- When removing records, show record details first and require confirmation
- Cross-reference with server IPs when pointing domains at servers

# DNS Script Reference

## scripts/dns.sh

Standalone Cloudflare DNS management via API v4. No external dependencies beyond `curl` and `jq`.

### Commands

| Command | Args | Description |
|---------|------|-------------|
| `list-zones` | | List all Cloudflare zones |
| `zone-id` | `<domain>` | Get zone ID for a domain |
| `list` | `<domain>` | List all DNS records in a zone |
| `add` | `<fqdn> <ip>` | Create/update an A record |
| `rm` | `<fqdn>` | Delete a DNS record |

### Environment Variables

| Variable | Description |
|----------|-------------|
| `CF_TOKEN` | Cloudflare API token (required). Falls back to `.env` file in cwd. |

### How `add` works
1. Extracts zone from FQDN (last two parts: `foo.example.com` → zone `example.com`)
2. Looks up zone ID via Cloudflare API
3. Checks if record already exists by querying for the FQDN
4. If new: POST to create A record (TTL=1, proxied=false)
5. If exists: PUT to update the record

### How `rm` works
1. Extracts zone from FQDN
2. Looks up zone ID and record ID
3. DELETE the record

### FQDN requirement
Unlike the old marina dns script, this script always expects **fully qualified domain names** (e.g., `myapp.example.com`, not just `myapp`). This makes it zone-agnostic — it works with any domain.

### API Authentication
All requests use: `-H "Authorization: Bearer ${CF_TOKEN}"`

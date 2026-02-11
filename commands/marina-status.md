---
description: Show an overview of all servers, their IPs, and associated domains
allowed-tools: Bash, Read
---

# Marina Infrastructure Status

## Setup

1. Run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/check-deps.sh` to verify dependencies.

## Steps

1. **Discover domains:**
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/dns.sh list-zones
   ```

2. **List all servers:**
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/server.sh list
   ```

3. **For each zone**, list DNS records:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/dns.sh list <domain>
   ```

4. **Cross-reference** server IPs with DNS records to build a map.

5. **Present a clean summary:**

   ```
   ## Servers

   | Server | IP | Status | Type | Domains |
   |--------|----|--------|------|---------|
   | web1   | 1.2.3.4 | running | cx11 | app1.example.com, app2.example.com |
   | web2   | 5.6.7.8 | running | cx11 | api.example.com |

   ## DNS Records

   | Type | Name | Points To |
   |------|------|-----------|
   | A | app1.example.com | 1.2.3.4 |
   | A | app2.example.com | 1.2.3.4 |
   ```

6. **Flag orphaned records** — DNS records pointing to IPs that don't match any known server.

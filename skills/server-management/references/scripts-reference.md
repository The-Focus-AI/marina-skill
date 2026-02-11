# Server Script Reference

## scripts/server.sh

Wraps `hcloud` CLI for Hetzner Cloud operations.

### Commands

| Command | Args | Description |
|---------|------|-------------|
| `list` | | List all servers (with headers) |
| `list-quiet` | | List servers without headers (for parsing) |
| `ssh-key` | | Get first SSH key ID |
| `add` | `<name>` | Create server with SSH key |
| `rm` | `<name>` | Delete server by name |
| `ip` | `<name>` | Get server IPv4 address |

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SERVER_TYPE` | `cax11` | Hetzner server type (ARM) |
| `IMAGE` | `debian-13` | OS image |

### How `add` works
1. Gets first SSH key via `hcloud ssh-key list`
2. Runs `hcloud server create --name <name> --type <type> --image <image> --ssh-key <key>`

### How `rm` works
1. Finds server ID from `hcloud server list` by name
2. Runs `hcloud server delete <id>`

### How `ip` works
Parses the 4th column from `hcloud server list` output matching the server name.

### Prerequisites
- `hcloud` CLI installed and configured with an active context
- At least one SSH key registered with Hetzner

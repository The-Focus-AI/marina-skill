#!/bin/bash
# Hetzner Cloud server management — standalone, no marina dependency
set -euo pipefail

SERVER_TYPE="${SERVER_TYPE:-cax11}"
IMAGE="${IMAGE:-debian-13}"

cmd="${1:-help}"
shift || true

case "$cmd" in
    list)
        hcloud server list
        ;;
    list-quiet)
        hcloud server list -o noheader
        ;;
    ssh-key)
        hcloud ssh-key list -o noheader | awk '{print $1}' | head -1
        ;;
    add)
        name="${1:?Usage: server.sh add <name>}"
        ssh_key=$(hcloud ssh-key list -o noheader | awk '{print $1}' | head -1)
        hcloud server create --name "$name" --type "$SERVER_TYPE" --image "$IMAGE" --ssh-key "$ssh_key"
        ;;
    rm)
        name="${1:?Usage: server.sh rm <name>}"
        server_id=$(hcloud server list -o noheader | awk "/$name/ {print \$1}")
        if [[ -z "$server_id" ]]; then
            echo "$name not found" >&2
            exit 1
        fi
        hcloud server delete "$server_id"
        echo "Deleted $name"
        ;;
    ip)
        name="${1:?Usage: server.sh ip <name>}"
        hcloud server list -o noheader | awk "/$name/ {print \$4}"
        ;;
    help)
        echo "Usage: server.sh <command> [args]"
        echo ""
        echo "Commands:"
        echo "  list          List all servers"
        echo "  list-quiet    List servers (no headers)"
        echo "  ssh-key       Show first SSH key ID"
        echo "  add <name>    Create a new server"
        echo "  rm <name>     Delete a server"
        echo "  ip <name>     Get server IP address"
        echo ""
        echo "Environment:"
        echo "  SERVER_TYPE   Hetzner server type (default: cax11)"
        echo "  IMAGE         OS image (default: debian-13)"
        ;;
    *)
        echo "Unknown command: $cmd" >&2
        exit 1
        ;;
esac

#!/bin/bash
# Bootstrap a remote server for Docker deployments
# This runs LOCALLY and SSHes into the target server
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CADDY_EMAIL="${CADDY_EMAIL:-admin@example.com}"

cmd="${1:-help}"
shift || true

case "$cmd" in
    full)
        # Full bootstrap: runs the remote bootstrap script on a server
        ip="${1:?Usage: bootstrap.sh full <ip>}"
        echo "Bootstrapping server at $ip..."

        # Generate the remote bootstrap script and send it
        cat "$SCRIPT_DIR/remote/bootstrap-remote.sh" | ssh "root@${ip}" "cat > /root/bootstrap.sh && chmod +x /root/bootstrap.sh"
        ssh "root@${ip}" "CADDY_EMAIL='${CADDY_EMAIL}' bash /root/bootstrap.sh"

        # Deploy the deployer and post-receive scripts
        scp "$SCRIPT_DIR/remote/deployer" "$SCRIPT_DIR/remote/post-receive" "root@${ip}:/root/"
        ssh "root@${ip}" "chmod +x deployer post-receive; mv deployer post-receive ~deploy/"

        echo "Bootstrap complete."
        ;;
    update-deployer)
        # Update just the deployer scripts on a server
        ip="${1:?Usage: bootstrap.sh update-deployer <ip>}"
        echo "Updating deployer on $ip..."
        scp "$SCRIPT_DIR/remote/deployer" "$SCRIPT_DIR/remote/post-receive" "root@${ip}:/root/"
        ssh "root@${ip}" "chmod +x deployer post-receive; mv deployer post-receive ~deploy/"
        echo "Deployer updated."
        ;;
    help)
        echo "Usage: bootstrap.sh <command> [args]"
        echo ""
        echo "Commands:"
        echo "  full <ip>              Full bootstrap of a fresh server"
        echo "  update-deployer <ip>   Update deployer scripts on a server"
        echo ""
        echo "Environment:"
        echo "  CADDY_EMAIL   Email for Caddy HTTPS certificates (default: admin@example.com)"
        ;;
    *)
        echo "Unknown command: $cmd" >&2
        exit 1
        ;;
esac

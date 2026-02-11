#!/bin/bash
# Git-push-to-deploy utilities — standalone, no marina dependency
set -euo pipefail

parse_remote() {
    local remote_line
    remote_line=$(git remote -v | grep production | head -1 || true)
    if [[ -z "$remote_line" ]]; then
        echo "No 'production' git remote found" >&2
        return 1
    fi
    host=$(echo "$remote_line" | sed 's/.*@//' | sed 's/:.*//')
    site=$(echo "$remote_line" | sed 's/.*://' | sed 's/ .*//')
}

cmd="${1:-help}"
shift || true

case "$cmd" in
    env)
        parse_remote
        if [[ -f .env.production ]]; then
            echo "Copying .env.production to ${host}:${site}/config"
            scp .env.production "deploy@${host}:${site}/config"
        elif [[ -f .env ]]; then
            echo "Copying .env to ${host}:${site}/config"
            scp .env "deploy@${host}:${site}/config"
        else
            echo "No .env.production or .env file found" >&2
            exit 1
        fi
        echo "Restarting container..."
        ssh "deploy@${host}" restart "$site"
        ;;
    restart)
        parse_remote
        echo "Restarting ${site} on ${host}..."
        ssh "deploy@${host}" restart "$site"
        ;;
    push-empty)
        git commit --allow-empty -m "Empty-Commit"
        git push production main
        ;;
    info)
        parse_remote
        echo "Host: $host"
        echo "Site: $site"
        ;;
    help)
        echo "Usage: deploy.sh <command>"
        echo ""
        echo "Commands:"
        echo "  env          Copy .env.production or .env to server and restart"
        echo "  restart      Restart the remote container"
        echo "  push-empty   Create empty commit and push to trigger rebuild"
        echo "  info         Show production remote details"
        echo ""
        echo "Requires a 'production' git remote in format: deploy@<host>:<site>"
        ;;
    *)
        echo "Unknown command: $cmd" >&2
        exit 1
        ;;
esac

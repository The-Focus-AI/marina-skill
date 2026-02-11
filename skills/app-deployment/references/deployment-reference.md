# Deployment Scripts Reference

## scripts/deploy.sh (runs locally)

| Command | Description |
|---------|-------------|
| `env` | Copy `.env.production` or `.env` to server, restart container |
| `restart` | Restart remote container |
| `push-empty` | Empty commit + push to trigger rebuild |
| `info` | Show production remote host and site |

Requires a git remote named `production` in format: `deploy@<host>:<site>`

### How `env` works
1. Parses `production` remote to get host and site
2. SCPs `.env.production` (or `.env`) to `deploy@<host>:<site>/config`
3. SSHes in to restart the container

### How `restart` works
SSHes to `deploy@<host>` with command `restart <site>`. The deployer handles the actual container restart.

## scripts/remote/deployer (on server at /home/deploy/deployer)

SSH forced-command handler:
- `git-receive-pack`/`git-upload-pack` → creates bare repo if needed, handles git push, restarts container
- `restart <site>` → stops old container, starts new one
- Direct SSH with no command → shows last 20 log lines

Container restart:
- `docker stop <site> && docker rm <site>`
- Loads `--env-file ~/site/config` if exists
- `docker run --detach --name <site> --network caddy --label caddy=<site> --label caddy.reverse_proxy='{{upstreams 8080}}' <site>:latest`

## scripts/remote/post-receive (on server in git hooks)

Git post-receive hook:
1. Reads revision info from stdin
2. Checks out code to `workdir/`
3. `docker build . -t <site>`

## Architecture

```
Local: git push production main
  → SSH to deploy@<host> (forced command → deployer)
    → deployer: git-receive-pack into ~/<site>/git
      → post-receive: checkout + docker build -t <site>
    → deployer: restart container with Caddy labels
      → Caddy auto-configures HTTPS + reverse proxy to :8080
```

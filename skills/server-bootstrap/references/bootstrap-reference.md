# Bootstrap Script Reference

## scripts/bootstrap.sh (runs locally)

| Command | Args | Description |
|---------|------|-------------|
| `full` | `<ip>` | Full server bootstrap |
| `update-deployer` | `<ip>` | Update deployer scripts only |

### `full` flow
1. Sends `scripts/remote/bootstrap-remote.sh` to server via SSH pipe
2. Runs it remotely with `CADDY_EMAIL` forwarded
3. SCPs `deployer` and `post-receive` to server
4. Moves them to `~deploy/`

## scripts/remote/bootstrap-remote.sh (runs on server)

Executes as root on the target server:

1. `apt update -y && apt upgrade -y`
2. Installs: `unattended-upgrades`, `jq`, `git`
3. Enables auto-upgrades (daily update, daily upgrade, weekly cleanup)
4. Installs Docker via `get.docker.com` if missing
5. Creates `deploy` user in docker group with forced-command SSH
6. Creates Docker network `caddy`, volumes `caddy_data` and `caddy_config`
7. Runs Caddy container with auto-HTTPS

## scripts/remote/deployer (deployed to /home/deploy/deployer)

SSH forced command handler. Parses `SSH_ORIGINAL_COMMAND`:
- `git-receive-pack`/`git-upload-pack` → creates repo if needed, handles git, restarts container
- `restart` → stops and recreates container with Caddy labels
- Anything else → executes directly

Container restart details:
- Stops and removes existing container
- Loads env from `~/site/config` if exists
- Runs on `caddy` network
- Sets `--label caddy=<site>` (hostname)
- Sets `--label caddy.reverse_proxy='{{upstreams 8080}}'`
- Image: `<site>:latest`

Logs to `~/log`.

## scripts/remote/post-receive (deployed to git hooks)

Git post-receive hook:
1. Reads `oldrev newrev refname`
2. Determines site name from parent directory
3. Checks out code to `workdir/`
4. Runs `docker build . -t <site>`

---
name: app-deployment
description: Deploy applications via git-push-to-deploy workflow - set up production remotes, push code, manage environment variables, restart containers. Triggers on phrases like "deploy an app", "deploy this app", "push code to server", "set up deployment", "git push deploy", "restart app", "copy env to server", "set up production remote".
allowed-tools: Bash, Read
---

# App Deployment Skill

You help deploy applications using a git-push-to-deploy workflow.

## Setup

1. Run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/check-deps.sh` to verify tools are available.

## How Deployment Works

1. User runs `git push production main`
2. SSH connects to server as `deploy` user
3. SSH forced-command routes to `deployer` script
4. `deployer` creates a bare git repo (first time), receives the push
5. `post-receive` hook checks out code and runs `docker build`
6. `deployer` stops old container and starts new one with Caddy labels
7. Caddy automatically provisions HTTPS and reverse proxies to port 8080

**App requirements:**
- Must have a `Dockerfile` in the project root
- Container must listen on port **8080**

## Scripts

Deployment utilities use `${CLAUDE_PLUGIN_ROOT}/scripts/deploy.sh`:

### Copy env to server
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/deploy.sh env
```
Copies `.env.production` (preferred) or `.env` to the server and restarts the container.

### Restart container
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/deploy.sh restart
```

### Force rebuild
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/deploy.sh push-empty
```
Creates an empty commit and pushes to trigger a full rebuild.

### Show remote info
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/deploy.sh info
```

## Setting Up a New Deployment

Walk the user through these steps:

1. **Check prerequisites:**
   - Verify `Dockerfile` exists
   - Check the app listens on port 8080

2. **Check for existing remote:** `git remote -v | grep production`

3. **If no production remote, guide setup:**
   a. List servers: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/server.sh list`
   b. Discover domains: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/dns.sh list-zones`
   c. Pick/create server and choose app name
   d. Add remote: `git remote add production deploy@<server>.<domain>:<appname>.<domain>`
   e. Add DNS: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/dns.sh add <appname>.<domain> <server_ip>`
   f. Push: `git push production main`

4. **After deployment:** the app is at `https://<appname>.<domain>` (Caddy handles HTTPS).

## Git Remote Format

```
deploy@<server-hostname>:<site-fqdn>
```

Example: `deploy@web1.example.com:myapp.example.com`

The site FQDN becomes both the Docker container name and the hostname Caddy uses for routing/HTTPS.

## Behavior

- Check for `Dockerfile` before attempting deployment
- When setting up, show the full git remote URL and confirm
- After deployment, tell the user the app URL
- If deployment fails, suggest checking logs: `ssh deploy@<server>` (shows last 20 log entries)
- Warn about sensitive values before copying env files

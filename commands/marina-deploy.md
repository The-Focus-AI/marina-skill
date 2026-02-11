---
description: Deploy the current project to a server via git-push-to-deploy
allowed-tools: Bash, Read
---

# Marina Deploy

## Setup

1. Run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/check-deps.sh` to verify dependencies.

## Steps

### 1. Check prerequisites
- Verify a `Dockerfile` exists in the current project
- Check that the app listens on port 8080 (look at Dockerfile)

### 2. Check for existing production remote
```bash
git remote -v | grep production
```

### 3a. If production remote EXISTS
- Show the remote URL
- Offer to push: `git push production main`
- Offer to copy env: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/deploy.sh env`

### 3b. If production remote DOES NOT EXIST
Guide through setup:

1. **List servers:**
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/server.sh list
   ```

2. **Discover domain:**
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/dns.sh list-zones
   ```

3. **Pick or create a server.** If none exist, offer to create one.

4. **Choose app name** (becomes the subdomain).

5. **Add git remote:**
   ```bash
   git remote add production deploy@<server>.<domain>:<appname>.<domain>
   ```

6. **Add DNS record:**
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/dns.sh add <appname>.<domain> $(bash ${CLAUDE_PLUGIN_ROOT}/scripts/server.sh ip <server>)
   ```

7. **Push:** `git push production main`

8. **Offer to copy env** if `.env.production` or `.env` exists.

### 4. After deployment
- App is at `https://<appname>.<domain>` (Caddy handles HTTPS)
- If something fails, check logs: `ssh deploy@<server>.<domain>`

#!/bin/bash
# Runs ON the remote server (as root) to set up Docker, deploy user, and Caddy proxy
set -euo pipefail

CADDY_EMAIL="${CADDY_EMAIL:-admin@example.com}"

echo "========== Updating packages"
apt update -y && apt upgrade -y

echo "========== Installing unattended-upgrades, jq, git"
apt install -y unattended-upgrades jq git
systemctl enable unattended-upgrades
systemctl start unattended-upgrades

cat > /etc/apt/apt.conf.d/20auto-upgrades <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF

echo "========== Checking Docker"
if docker -v 2>/dev/null; then
    echo "Docker already installed"
else
    echo "Installing Docker..."
    curl -sSL https://get.docker.com | sh
fi

echo "========== Setting up deploy user"
username=deploy
if ! grep -q "$username" /etc/passwd; then
    echo "Creating $username user"
    useradd "$username" -m -g docker -s /bin/bash
fi

mkdir -p "/home/${username}/.ssh"
echo "command=\"/home/${username}/deployer admin\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty $(head -1 /root/.ssh/authorized_keys)" > "/home/${username}/.ssh/authorized_keys"
chown -R "$username" "/home/${username}"
chmod 700 "/home/${username}/.ssh"
chmod 600 "/home/${username}/.ssh/authorized_keys"

cat > "/etc/sudoers.d/${username}" <<EOF
${username} ALL=(ALL) NOPASSWD:ALL
EOF

echo "========== Setting up Caddy reverse proxy"

if [[ $(docker network ls -f name=caddy -q | wc -l) != "1" ]]; then
    docker network create caddy
fi

if [[ $(docker volume ls -f name=caddy_data -q | wc -l) != "1" ]]; then
    docker volume create caddy_data
fi

if [[ $(docker volume ls -f name=caddy_config -q | wc -l) != "1" ]]; then
    docker volume create caddy_config
fi

status=$(docker container ls -a --format json | jq -r '. | select(.Names | contains("caddy")) | .State' || true)

if [[ -z "$status" ]]; then
    docker run \
        --detach \
        --name caddy \
        --network caddy \
        --publish 80:80 \
        --publish 443:443 \
        --publish 443:443/udp \
        --label "caddy.email=${CADDY_EMAIL}" \
        --env CADDY_INGRESS_NETWORKS=caddy \
        --volume /var/run/docker.sock:/var/run/docker.sock \
        --volume caddy_data:/data \
        --volume caddy_config:/config \
        lucaslorentz/caddy-docker-proxy:ci-alpine
elif [[ "$status" != "running" ]]; then
    docker start caddy
fi

echo "========== Bootstrap complete"

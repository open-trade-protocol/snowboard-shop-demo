#!/bin/bash
# =============================================================================
# Snowboard Shop Demo — Deployment Script
# Target: demo-shop.opentradeprotocol.com
# User: trade / Password: 01trade01
# =============================================================================

set -euo pipefail

# ---------- Configuration ----------
REMOTE_HOST="demo-shop.opentradeprotocol.com"
REMOTE_USER="trade"
REMOTE_PASS="01trade01"
REMOTE_DEPLOY_DIR="/home/${REMOTE_USER}/snowboard-shop-demo"
DOMAIN="demo-shop.opentradeprotocol.com"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Helper: run command via SSH with password
ssh_cmd() {
    sshpass -p "${REMOTE_PASS}" ssh -o StrictHostKeyChecking=no "${REMOTE_USER}@${REMOTE_HOST}" "$@"
}

scp_cmd() {
    sshpass -p "${REMOTE_PASS}" scp -o StrictHostKeyChecking=no "$@"
}

sudo_remote() {
    # Run sudo command on remote server (password via -S)
    ssh_cmd "echo '${REMOTE_PASS}' | sudo -S $*"
}

echo "========================================="
echo " Snowboard Shop Demo — Deployment"
echo "========================================="
echo "Target:   ${REMOTE_HOST}"
echo "User:     ${REMOTE_USER}"
echo "Deploy to: ${REMOTE_DEPLOY_DIR}"
echo "Domain:   ${DOMAIN}"
echo "========================================="

# ---------- Step 1: Build Docker image locally ----------
echo ""
echo "[1/8] Building Docker image..."
cd "${PROJECT_DIR}"
docker build -t snowboard-shop-demo:latest -f Dockerfile .
echo "Image built: snowboard-shop-demo:latest"

# ---------- Step 2: Create tarball ----------
echo ""
echo "[2/8] Creating deployment archive..."
tar -czf /tmp/snowboard-shop-demo.tar.gz \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='deploy.sh' \
    -C "${PROJECT_DIR}" \
    .
echo "Archive created: /tmp/snowboard-shop-demo.tar.gz"

# ---------- Step 3: Install Docker on remote server ----------
echo ""
echo "[3/8] Installing Docker on remote server..."
ssh_cmd <<'REMOTE_DOCKER_INSTALL'
echo "Checking Docker installation..."
if command -v docker &>/dev/null; then
    echo "Docker is already installed: $(docker --version)"
    exit 0
fi

echo "Installing Docker prerequisites..."
echo '01trade01' | sudo -S apt-get update -qq
echo '01trade01' | sudo -S apt-get install -y -qq ca-certificates curl gnupg

echo "Adding Docker GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
echo '01trade01' | sudo -S curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.grep
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "Adding Docker repository..."
echo "deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \$(. /etc/os-release && echo \$VERSION_CODENAME) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Installing Docker Engine..."
sudo apt-get update -qq
sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Adding user to docker group..."
sudo usermod -aG docker $USER

echo "Docker installed successfully."
docker --version
docker compose version
REMOTE_DOCKER_INSTALL

# ---------- Step 4: Upload archive ----------
echo ""
echo "[4/8] Uploading archive to remote server..."
scp_cmd /tmp/snowboard-shop-demo.tar.gz "${REMOTE_USER}@${REMOTE_HOST}:/tmp/"
echo "Archive uploaded."

# ---------- Step 5: Extract and setup ----------
echo ""
echo "[5/8] Setting up remote directory..."
ssh_cmd <<'REMOTE_SETUP'
echo "Extracting archive..."
mkdir -p "${HOME}/snowboard-shop-demo"
tar -xzf /tmp/snowboard-shop-demo.tar.gz -C "${HOME}/snowboard-shop-demo/"
rm -f /tmp/snowboard-shop-demo.tar.gz
echo "Setup complete."
REMOTE_SETUP

# ---------- Step 6: Create docker-compose.yml ----------
echo ""
echo "[6/8] Creating docker-compose.yml on remote server..."
ssh_cmd <<'REMOTE_COMPOSE'
cat > "${HOME}/snowboard-shop-demo/docker-compose.yml" <<'COMPOSE'
version: '3.8'
services:
  snowboard-shop-demo:
    image: snowboard-shop-demo:latest
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8080:80"
    restart: unless-stopped
COMPOSE
echo "docker-compose.yml created."
REMOTE_COMPOSE

# ---------- Step 7: Install and configure Nginx ----------
echo ""
echo "[7/8] Installing and configuring Nginx..."
ssh_cmd <<'REMOTE_NGINX'
echo "Checking Nginx installation..."
if command -v nginx &>/dev/null; then
    echo "Nginx is already installed: $(nginx -v)"
else
    echo "Installing Nginx..."
    echo '01trade01' | sudo -S apt-get update -qq
    echo '01trade01' | sudo -S apt-get install -y -qq nginx
    echo "Nginx installed: $(nginx -v)"
fi

# Create Nginx config
sudo tee /etc/nginx/sites-available/snowboard-shop-demo > /dev/null <<'NGINX_CONF'
server {
    listen 80;
    server_name demo-shop.opentradeprotocol.com;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
NGINX_CONF

# Enable site
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/snowboard-shop-demo /etc/nginx/sites-enabled/snowboard-shop-demo

# Test and reload
sudo nginx -t
sudo systemctl reload nginx
echo "Nginx configured successfully."
REMOTE_NGINX

# ---------- Step 8: Start the service ----------
echo ""
echo "[8/8] Starting snowboard-shop-demo service..."
ssh_cmd <<'REMOTE_START'
echo "Building and starting service..."
cd "${HOME}/snowboard-shop-demo"
docker compose down 2>/dev/null || true
docker compose up -d --build
echo ""
echo "Service status:"
docker compose ps
REMOTE_START

# ---------- Cleanup ----------
rm -f /tmp/snowboard-shop-demo.tar.gz

# ---------- Final check ----------
echo ""
echo "========================================="
echo " Deployment Complete!"
echo "========================================="
echo ""
echo "Verify the deployment:"
echo "  curl -I http://${DOMAIN}"
echo "  curl http://${DOMAIN}"
echo ""
echo "Manage the service on server:"
echo "  ssh ${REMOTE_USER}@${DOMAIN}"
echo "  cd ${REMOTE_DEPLOY_DIR}"
echo "  docker compose ps"
echo "  docker compose logs -f"
echo "  docker compose down"
echo ""
echo "Add HTTPS (recommended):"
echo "  sudo apt-get install certbot python3-certbot-nginx"
echo "  sudo certbot --nginx -d ${DOMAIN}"
echo "========================================="

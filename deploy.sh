#!/bin/bash
# =============================================================================
# Snowboard Shop Demo — Deployment Script (rsync)
# Target: demo-shop.opentradeprotocol.com
# User: trade / Password: 01trade01
# =============================================================================
# Static site deployment via rsync — no Docker required.
# The server must have Nginx installed and configured to serve files from
# /usr/share/nginx/html/ (or the REMOTE_WEBROOT path below).
# =============================================================================

set -euo pipefail

# ---------- Configuration ----------
REMOTE_HOST="demo-shop.opentradeprotocol.com"
REMOTE_USER="trade"
REMOTE_PASS="01trade01"
REMOTE_WEBROOT="/var/www/trade/data/www/demo-shop.opentradeprotocol.com"
DOMAIN="demo-shop.opentradeprotocol.com"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Helper: run command via SSH with password
ssh_cmd() {
    sshpass -p "${REMOTE_PASS}" ssh -o StrictHostKeyChecking=no "${REMOTE_USER}@${REMOTE_HOST}" "$@"
}

# ---------- Pre-flight checks ----------
echo "========================================="
echo " Snowboard Shop Demo — Deployment (rsync)"
echo "========================================="
echo "Target:   ${REMOTE_HOST}"
echo "Deploy to: ${REMOTE_WEBROOT}"
echo "Domain:   ${DOMAIN}"
echo "========================================="

# Check prerequisites
for cmd in sshpass rsync; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "ERROR: '$cmd' is not installed. Run: sudo apt install $cmd"
        exit 1
    fi
done

# ---------- Step 1: Verify remote connectivity ----------
echo ""
echo "[1/3] Verifying remote connectivity..."
ssh_cmd "echo 'Connected: $(hostname), uptime: $(uptime -p)'"

# ---------- Step 2: Sync files via rsync ----------
echo ""
echo "[2/3] Syncing files via rsync..."
rsync -avz --delete \
    --exclude='.git/' \
    --exclude='.gitignore' \
    --exclude='node_modules/' \
    --exclude='deploy.sh' \
    --exclude='docker-compose.yml' \
    --exclude='*.md' \
    --exclude='.DS_Store' \
    -e "sshpass -p '${REMOTE_PASS}' ssh -o StrictHostKeyChecking=no" \
    "${PROJECT_DIR}/html/" \
    "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_WEBROOT}/"

echo "Files synced successfully."

# ---------- Step 3: Verify deployment ----------
echo ""
echo "[3/3] Verifying deployment..."
ssh_cmd "ls -la ${REMOTE_WEBROOT}/ | head -10"
echo ""
echo "========================================="
echo " Deployment Complete!"
echo "========================================="
echo "Verify the site:"
echo "  curl -I http://${DOMAIN}"
echo "  curl http://${DOMAIN}"
echo "========================================="

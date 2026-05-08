#!/usr/bin/env bash
# bootstrap.sh — first-time setup on a fresh Ubuntu 24 LTS server.
#
# What it does:
#   1. Installs nginx and fail2ban via apt
#   2. Applies kernel tuning (sysctl)
#   3. Deploys nginx main config, snippets, and logrotate
#   4. Deploys fail2ban jails and filters
#   5. Starts and enables both services
#   6. Installs the `lynxsetup` CLI to /usr/local/bin/lynxsetup
#
# Usage:
#   sudo ./bootstrap.sh
#
# After this, manage domains with:
#   lynxsetup list
#   sudo lynxsetup add app.example.com <upstream-ip> <port>
#   sudo lynxsetup add-imgproxy img.example.com <upstream-ip> <port>
#   sudo lynxsetup delete app.example.com

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

NGINX_DIR="/etc/nginx"
NGINX_USER="www-data"
CACHE_DIR="/var/cache/nginx/imgproxy"

# ---------------------------------------------------------------------------
# Colors
# ---------------------------------------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}==>${RESET} $*"; }
success() { echo -e "${GREEN}✓${RESET} $*"; }
error()   { echo -e "${RED}ERROR:${RESET} $*" >&2; exit 1; }
step()    { echo ""; echo -e "${BOLD}── $* ──${RESET}"; }

# ---------------------------------------------------------------------------
[[ $EUID -eq 0 ]] || error "Run as root: sudo ./bootstrap.sh"

step "Installing packages"
apt-get update -qq
apt-get install -y nginx fail2ban
success "nginx and fail2ban installed"

# ---------------------------------------------------------------------------
step "Applying kernel tuning"
cp "$SCRIPT_DIR/sysctl/99-nginx-tuning.conf" /etc/sysctl.d/99-nginx-tuning.conf
sysctl --system --quiet
success "sysctl tuning applied"

# ---------------------------------------------------------------------------
step "Deploying nginx config"

# Back up existing nginx.conf if present
if [[ -f "$NGINX_DIR/nginx.conf" ]]; then
    BACKUP="$NGINX_DIR/nginx.conf.bak.$(date +%Y%m%d%H%M%S)"
    info "Backing up existing nginx.conf → $BACKUP"
    cp "$NGINX_DIR/nginx.conf" "$BACKUP"
fi

cp "$SCRIPT_DIR/nginx.conf" "$NGINX_DIR/nginx.conf"

mkdir -p "$NGINX_DIR/snippets" "$NGINX_DIR/conf.d"
cp "$SCRIPT_DIR/snippets/"*.conf "$NGINX_DIR/snippets/"

cp "$SCRIPT_DIR/logrotate/nginx" /etc/logrotate.d/nginx

# Image proxy cache directory (used if imgproxy is later configured)
mkdir -p "$CACHE_DIR"
chown -R "$NGINX_USER:$NGINX_USER" "$CACHE_DIR"
chmod 700 "$CACHE_DIR"

success "nginx config deployed"

step "Testing and starting nginx"
nginx -t
systemctl enable --now nginx
systemctl reload nginx
success "nginx running"

# ---------------------------------------------------------------------------
step "Deploying fail2ban config"
mkdir -p /etc/fail2ban/jail.d /etc/fail2ban/filter.d

cp "$SCRIPT_DIR/fail2ban/jail.d/nginx.conf"             /etc/fail2ban/jail.d/nginx.conf
cp "$SCRIPT_DIR/fail2ban/jail.d/ssh.conf"               /etc/fail2ban/jail.d/ssh.conf
cp "$SCRIPT_DIR/fail2ban/filter.d/nginx-ratelimit.conf" /etc/fail2ban/filter.d/nginx-ratelimit.conf
cp "$SCRIPT_DIR/fail2ban/filter.d/nginx-4xx.conf"       /etc/fail2ban/filter.d/nginx-4xx.conf

success "fail2ban configs deployed"

step "Starting fail2ban"
systemctl enable --now fail2ban
systemctl reload-or-restart fail2ban
success "fail2ban running"

# ---------------------------------------------------------------------------
step "Installing lynxsetup CLI"
chmod +x "$SCRIPT_DIR/lynxsetup"
ln -sf "$SCRIPT_DIR/lynxsetup" /usr/local/bin/lynxsetup
success "lynxsetup CLI installed at /usr/local/bin/lynxsetup"

# ---------------------------------------------------------------------------
echo ""
echo -e "${BOLD}Bootstrap complete!${RESET}"
echo ""
echo "Active fail2ban jails:"
fail2ban-client status
echo ""
echo -e "${BOLD}Manage domains:${RESET}"
echo ""
echo "  lynxsetup list"
echo "  sudo lynxsetup add <domain> <upstream-ip> <port>"
echo "  sudo lynxsetup add-imgproxy <domain> <upstream-ip> <port>"
echo "  sudo lynxsetup delete <domain>"
echo ""
echo "Examples:"
echo "  sudo lynxsetup add app.client1.com 10.0.0.1 3000"
echo "  sudo lynxsetup add-imgproxy img.example.com 10.0.0.1 8080"
echo "  lynxsetup list"

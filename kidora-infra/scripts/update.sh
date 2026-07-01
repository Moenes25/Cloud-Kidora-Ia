#!/bin/bash
# ═══════════════════════════════════════════════════════
# Kidora — Update Script
# ═══════════════════════════════════════════════════════
# Pulls latest Docker images and restarts services.
# Usage:
#   ./update.sh                    # Update all services
#   ./update.sh backend            # Update specific service
#   ./update.sh backend frontend   # Update multiple services
# ═══════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SERVICES="${@:-backend frontend}"

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

main() {
  log "═══ Kidora Update Script ═══"

  # Get server IP from Terraform output
  SERVER_IP=$(terraform -chdir="${PROJECT_DIR}/terraform" output -raw server_ipv4 2>/dev/null || echo "")
  if [ -z "$SERVER_IP" ]; then
    log "Could not get server IP from Terraform. Using 'kidora-server' from inventory."
    SERVER_IP="kidora-server"
  fi

  log "Updating services on $SERVER_IP: $SERVICES"

  # Pull latest images and recreate services via SSH
  ssh root@"$SERVER_IP" << EOF
    cd /opt/kidora

    echo "Pulling latest images..."
    docker-compose -f docker-compose.prod.yml pull $SERVICES

    echo "Recreating services..."
    docker-compose -f docker-compose.prod.yml up -d --force-recreate $SERVICES

    echo "Cleaning up old images..."
    docker image prune -f

    echo "Checking service status..."
    docker-compose -f docker-compose.prod.yml ps
EOF

  log "Update completed successfully!"
  log "Services updated: $SERVICES"
}

main "$@"
</output>
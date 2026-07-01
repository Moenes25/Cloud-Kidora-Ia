#!/bin/bash
# ═══════════════════════════════════════════════════════
# Kidora — Rollback Script
# ═══════════════════════════════════════════════════════
# Deploys a previous Docker image tag.
# Usage:
#   ./rollback.sh backend v1.2.3
#   ./rollback.sh frontend v1.2.3
# ═══════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

SERVICE="${1:-}"
VERSION="${2:-}"

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

error() {
  echo "[ERROR] $*" >&2
  exit 1
}

main() {
  log "═══ Kidora Rollback Script ═══"

  if [ -z "$SERVICE" ] || [ -z "$VERSION" ]; then
    error "Usage: $0 <service> <version>"
    error "Example: $0 backend v1.2.3"
  fi

  log "Rolling back $SERVICE to version $VERSION..."

  cd "$PROJECT_DIR"

  # Update the Docker image tag in docker-compose
  # This assumes your images are tagged with the version
  case "$SERVICE" in
    backend)
      sed -i "s|image: ghcr.io/moenes25/client-kidora-backend:.*|image: ghcr.io/moenes25/client-kidora-backend:${VERSION}|g" \
        docker/docker-compose.prod.yml
      ;;
    frontend)
      sed -i "s|image: ghcr.io/moenes25/client-kidora-frontend:.*|image: ghcr.io/moenes25/client-kidora-frontend:${VERSION}|g" \
        docker/docker-compose.prod.yml
      ;;
    *)
      error "Unknown service: $SERVICE. Use: backend or frontend"
      ;;
  esac

  # Redeploy the specific service
  ssh root@$(terraform -chdir=terraform output -raw server_ipv4) \
    "cd /opt/kidora && docker-compose -f docker-compose.prod.yml up -d $SERVICE"

  log "Rollback of $SERVICE to $VERSION completed!"
}

main "$@"
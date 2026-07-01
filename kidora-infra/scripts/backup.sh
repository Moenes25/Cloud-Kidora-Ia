#!/bin/bash
# ═══════════════════════════════════════════════════════
# Kidora — Backup Script
# ═══════════════════════════════════════════════════════
# Usage:
#   ./backup.sh postgres /mnt/backup/postgres
#   ./backup.sh uploads /mnt/backup/uploads
# ═══════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_TYPE="${1:-full}"
BACKUP_DEST="${2:-/mnt/backup}"
RETENTION_DAYS="${3:-30}"

# Load environment if available
ENV_FILE="${SCRIPT_DIR}/../.env"
if [ -f "$ENV_FILE" ]; then
  source "$ENV_FILE"
fi

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

# ── PostgreSQL Backup ──────────────────────────
backup_postgres() {
  local dest="${BACKUP_DEST}/postgres"
  mkdir -p "$dest"

  local filename="kidora_pg_${TIMESTAMP}.sql.gz"
  local filepath="${dest}/${filename}"

  log "Starting PostgreSQL backup..."
  PGPASSWORD="${POSTGRES_PASSWORD}" pg_dump \
    -h localhost \
    -U "${POSTGRES_USER:-kidora}" \
    -d "${POSTGRES_DB:-kidora}" \
    --clean \
    --if-exists \
    --no-owner \
    --no-privileges \
    | gzip > "$filepath"

  log "Backup completed: $filepath ($(du -h "$filepath" | cut -f1))"

  # Create a symlink to latest backup
  ln -sf "$filename" "${dest}/latest.sql.gz"
}

# ── Uploads Backup ─────────────────────────────
backup_uploads() {
  local src="${DATA_MOUNT_POINT:-/mnt/data}/uploads"
  local dest="${BACKUP_DEST}/uploads"

  if [ ! -d "$src" ]; then
    log "WARNING: Uploads directory $src does not exist. Skipping."
    return
  fi

  mkdir -p "$dest"

  local filename="kidora_uploads_${TIMESTAMP}.tar.gz"
  local filepath="${dest}/${filename}"

  log "Starting uploads backup..."
  tar -czf "$filepath" -C "$(dirname "$src")" "$(basename "$src")"
  log "Backup completed: $filepath ($(du -h "$filepath" | cut -f1))"

  ln -sf "$filename" "${dest}/latest.tar.gz"
}

# ── Configuration Backup ───────────────────────
backup_configs() {
  local src="${SCRIPT_DIR}/.."
  local dest="${BACKUP_DEST}/configs"

  mkdir -p "$dest"

  local filename="kidora_configs_${TIMESTAMP}.tar.gz"
  local filepath="${dest}/${filename}"

  log "Starting configuration backup..."
  tar -czf "$filepath" \
    -C "$(dirname "$src")" \
    --exclude=".git" \
    --exclude="data" \
    --exclude="node_modules" \
    "$(basename "$src")/docker" \
    "$(basename "$src")/scripts" \
    "$(basename "$src")/monitoring"
  log "Configuration backup completed: $filepath ($(du -h "$filepath" | cut -f1))"
}

# ── Main ───────────────────────────────────────
main() {
  log "=== Kidora Backup Script ==="
  log "Type: $BACKUP_TYPE"
  log "Destination: $BACKUP_DEST"

  case "$BACKUP_TYPE" in
    postgres)
      backup_postgres
      ;;
    uploads)
      backup_uploads
      ;;
    configs)
      backup_configs
      ;;
    full)
      backup_postgres
      backup_uploads
      backup_configs
      ;;
    *)
      echo "Usage: $0 {postgres|uploads|configs|full} [destination]"
      exit 1
      ;;
  esac

  log "=== Backup Complete ==="
}

main "$@"
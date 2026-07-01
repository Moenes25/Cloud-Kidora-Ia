#!/bin/bash
# ═══════════════════════════════════════════════════════
# Kidora — Restore Script
# ═══════════════════════════════════════════════════════
# Usage:
#   ./restore.sh postgres /mnt/backup/postgres/kidora_pg_20250101_020000.sql.gz
#   ./restore.sh uploads /mnt/backup/uploads/kidora_uploads_20250101_020000.tar.gz
# ═══════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESTORE_TYPE="${1:-}"
RESTORE_FILE="${2:-}"

# Load environment
ENV_FILE="${SCRIPT_DIR}/../.env"
if [ -f "$ENV_FILE" ]; then
  source "$ENV_FILE"
fi

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

error() {
  echo "[ERROR] $*" >&2
  exit 1
}

# ── PostgreSQL Restore ─────────────────────────
restore_postgres() {
  local file="$1"

  if [ ! -f "$file" ]; then
    error "Backup file not found: $file"
  fi

  log "Restoring PostgreSQL from: $file"
  log "WARNING: This will DROP the current database!"

  # Drop and recreate database
  PGPASSWORD="${POSTGRES_PASSWORD}" psql \
    -h localhost \
    -U "${POSTGRES_USER:-kidora}" \
    -d postgres \
    -c "DROP DATABASE IF EXISTS ${POSTGRES_DB:-kidora};"

  PGPASSWORD="${POSTGRES_PASSWORD}" psql \
    -h localhost \
    -U "${POSTGRES_USER:-kidora}" \
    -d postgres \
    -c "CREATE DATABASE ${POSTGRES_DB:-kidora};"

  # Restore from gzipped dump
  gunzip -c "$file" | PGPASSWORD="${POSTGRES_PASSWORD}" psql \
    -h localhost \
    -U "${POSTGRES_USER:-kidora}" \
    -d "${POSTGRES_DB:-kidora}"

  log "PostgreSQL restore completed successfully!"
}

# ── Uploads Restore ────────────────────────────
restore_uploads() {
  local file="$1"
  local dest="${DATA_MOUNT_POINT:-/mnt/data}/uploads"

  if [ ! -f "$file" ]; then
    error "Backup file not found: $file"
  fi

  log "Restoring uploads from: $file"

  # Backup current uploads
  if [ -d "$dest" ] && [ "$(ls -A "$dest" 2>/dev/null)" ]; then
    local backup_current="/tmp/uploads_backup_$(date +%Y%m%d_%H%M%S)"
    log "Backing up current uploads to: $backup_current"
    mv "$dest" "$backup_current"
  fi

  mkdir -p "$dest"
  tar -xzf "$file" -C "$(dirname "$dest")"

  log "Uploads restore completed successfully!"
}

# ── Main ───────────────────────────────────────
main() {
  log "=== Kidora Restore Script ==="

  if [ -z "$RESTORE_TYPE" ] || [ -z "$RESTORE_FILE" ]; then
    error "Usage: $0 {postgres|uploads} <backup_file>"
  fi

  case "$RESTORE_TYPE" in
    postgres)
      restore_postgres "$RESTORE_FILE"
      ;;
    uploads)
      restore_uploads "$RESTORE_FILE"
      ;;
    *)
      error "Invalid restore type: $RESTORE_TYPE. Use: postgres or uploads"
      ;;
  esac

  log "=== Restore Complete ==="
}

main "$@"
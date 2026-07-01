#!/bin/bash
# ═══════════════════════════════════════════════════════
# Kidora — Cleanup Script
# ═══════════════════════════════════════════════════════
# Removes backup files older than specified days.
# Usage:
#   ./cleanup.sh /mnt/backup 30
# ═══════════════════════════════════════════════════════

set -euo pipefail

BACKUP_DIR="${1:-/mnt/backup}"
RETENTION_DAYS="${2:-30}"

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

main() {
  log "=== Kidora Cleanup Script ==="
  log "Backup directory: $BACKUP_DIR"
  log "Retention: $RETENTION_DAYS days"

  if [ ! -d "$BACKUP_DIR" ]; then
    log "Backup directory does not exist: $BACKUP_DIR"
    exit 0
  fi

  # Find and delete old backups
  local deleted=0
  while IFS= read -r -d '' file; do
    log "Removing old backup: $file"
    rm -f "$file"
    deleted=$((deleted + 1))
  done < <(find "$BACKUP_DIR" -type f -name "kidora_*" -mtime "+${RETENTION_DAYS}" -print0)

  # Remove empty directories
  find "$BACKUP_DIR" -type d -empty -delete 2>/dev/null || true

  log "Deleted $deleted old backup files"
  log "=== Cleanup Complete ==="
}

main "$@"
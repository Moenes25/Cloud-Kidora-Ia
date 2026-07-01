# ═══════════════════════════════════════════════════════
# Volumes — Persistent storage for data and backups
# ═══════════════════════════════════════════════════════
# These volumes are automatically formatted and mounted
# by Ansible after server creation.
# ═══════════════════════════════════════════════════════

# Data volume (for PostgreSQL, MinIO, application uploads)
resource "hcloud_volume" "data" {
  name      = "${var.server_name}-data"
  size      = var.data_volume_size
  server_id = hcloud_server.kidora.id
  automount = false
  format    = "ext4"
  labels    = merge(local.common_labels, {
    purpose = "application-data"
  })
}

# Backup volume (for database dumps and file backups)
resource "hcloud_volume" "backup" {
  name      = "${var.server_name}-backup"
  size      = var.backup_volume_size
  server_id = hcloud_server.kidora.id
  automount = false
  format    = "ext4"
  labels    = merge(local.common_labels, {
    purpose = "backups"
  })
}
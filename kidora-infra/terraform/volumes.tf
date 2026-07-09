# ═══════════════════════════════════════════════════════
# Volumes — Block storage for data and backups
# ═══════════════════════════════════════════════════════
# These volumes are additional storage attached to the server.
# Vultr block storage is provisioned separately and can be attached to instances.
# ═══════════════════════════════════════════════════════

# Data volume (for MongoDB, MinIO)
resource "vultr_block_storage" "data" {
  region = var.location
  size_gb   = var.data_volume_size
  label  = "${var.server_name}-data"
}


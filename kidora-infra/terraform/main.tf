# ═══════════════════════════════════════════════════════
# Kidora — Main Terraform Configuration
# ═══════════════════════════════════════════════════════
# This provisions a single Vultr Cloud server for the
# entire Kidora application stack (MongoDB, MinIO,
# Traefik, backend, frontend, monitoring stack).
# ═══════════════════════════════════════════════════════

locals {
  # Key-value labels for all resources (used for tagging)
  common_labels = merge(var.labels, {
    server-type = var.server_type
    location    = var.location
  })
}
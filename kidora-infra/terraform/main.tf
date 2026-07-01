# ═══════════════════════════════════════════════════════
# Kidora — Main Terraform Configuration
# ═══════════════════════════════════════════════════════
# This provisions a single Hetzner Cloud server for the
# entire Kidora application stack (PostgreSQL, MinIO,
# Traefik, backend, frontend, monitoring stack).
# ═══════════════════════════════════════════════════════

locals {
  # Key-value labels for all resources
  common_labels = merge(var.labels, {
    server-type = var.server_type
    location    = var.location
  })
}
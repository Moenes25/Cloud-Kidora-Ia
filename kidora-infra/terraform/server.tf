# ═══════════════════════════════════════════════════════
# Server — Vultr Cloud server for Kidora
# ═══════════════════════════════════════════════════════
# This server runs the entire stack via Docker Compose.
# Using the lowest tier: vc2-1c-1gb (1 vCPU, 1GB RAM, 25GB SSD)
# ═══════════════════════════════════════════════════════

# Import your SSH public key
# Replace the ssh_key content below with your actual public key
resource "vultr_ssh_key" "default" {
  name    = "${var.server_name}-key"
  ssh_key = var.ssh_public_key
}

# Create the primary server
resource "vultr_instance" "kidora" {
  plan              = var.server_type
  region            = var.location
  os_id             = var.os_image
  label             = var.server_name
  ssh_key_ids       = [vultr_ssh_key.default.id]
  firewall_group_id = vultr_firewall_group.kidora.id
  
  # Enable IPv6
  enable_ipv6 = true
  
  tags = [
    "project=${var.labels.project}",
    "environment=${var.labels.environment}",
    "managed-by=${var.labels.managed-by}"
  ]
}
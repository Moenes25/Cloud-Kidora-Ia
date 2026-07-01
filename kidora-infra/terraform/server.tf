# ═══════════════════════════════════════════════════════
# Server — Single Hetzner Cloud server for Kidora
# ═══════════════════════════════════════════════════════
# This server runs the entire stack via Docker Compose.
# ═══════════════════════════════════════════════════════

# Import your SSH public key
resource "hcloud_ssh_key" "default" {
  name       = "${var.server_name}-key"
  public_key = file(var.ssh_public_key_path)
  labels     = local.common_labels
}

# Create the primary server
resource "hcloud_server" "kidora" {
  name        = var.server_name
  server_type = var.server_type
  image       = var.os_image
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.default.id]

  # Enable backups (automated weekly backups by Hetzner)
  backups = false

  labels = merge(local.common_labels, {
    role = "application-server"
  })

  # Attach firewall
  firewall_ids = [hcloud_firewall.kidora.id]

  # Attach to private network
  network {
    network_id = hcloud_network.kidora.id
    ip         = "10.0.1.1"
  }

  # User data for initial bootstrap (optional — moved to Ansible for flexibility)
  user_data = <<-EOF
    #cloud-config
    package_update: true
    package_upgrade: true
    packages:
      - apt-transport-https
      - ca-certificates
      - curl
      - gnupg
      - lsb-release
      - ufw
      - htop
      - fail2ban
    runcmd:
      - [ curl, -fsSL, https://get.docker.com, -o, /tmp/get-docker.sh ]
      - [ sh, /tmp/get-docker.sh ]
      - [ usermod, -aG, docker, ubuntu ]
      - [ systemctl, enable, docker ]
      - [ systemctl, start, docker ]
      - [ curl, -L, "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)", -o, /usr/local/bin/docker-compose ]
      - [ chmod, +x, /usr/local/bin/docker-compose ]
  EOF

  depends_on = [
    hcloud_firewall.kidora,
    hcloud_network.kidora
  ]
}
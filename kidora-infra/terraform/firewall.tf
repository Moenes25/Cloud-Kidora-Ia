# ═══════════════════════════════════════════════════════
# Firewall — Security rules for the server
# ═══════════════════════════════════════════════════════
# Rules are applied to the server after creation.
# ═══════════════════════════════════════════════════════

resource "hcloud_firewall" "kidora" {
  name   = "${var.server_name}-firewall"
  labels = local.common_labels

  # SSH — restricted to specific IPs
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = var.ssh_allowed_ips
  }

  # HTTP/HTTPS — open to the world
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "80"
    source_ips = var.firewall_allowed_ips
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = var.firewall_allowed_ips
  }

  # Prometheus/Grafana monitoring (optional — restrict if needed)
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "9090"
    source_ips = var.firewall_allowed_ips
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "3000"
    source_ips = var.firewall_allowed_ips
  }

  # Allow all outbound traffic
  rule {
    direction = "out"
    protocol  = "tcp"
    port      = "any"
    destination_ips = ["0.0.0.0/0", "::/0"]
  }
  rule {
    direction = "out"
    protocol  = "udp"
    port      = "any"
    destination_ips = ["0.0.0.0/0", "::/0"]
  }
  rule {
    direction = "out"
    protocol  = "icmp"
    destination_ips = ["0.0.0.0/0", "::/0"]
  }
}
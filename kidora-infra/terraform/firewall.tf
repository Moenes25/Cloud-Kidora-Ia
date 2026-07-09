# ═══════════════════════════════════════════════════════
# Firewall — Security rules for the server
# ═══════════════════════════════════════════════════════
# Vultr firewall groups define rules applied to instances.
# Rules use IP addresses (not CIDR) with subnet_size for subnet mask.
# ═══════════════════════════════════════════════════════

resource "vultr_firewall_group" "kidora" {
  description = "Kidora application firewall rules"
}

# SSH - Port 22 (IPv4) - allow all
resource "vultr_firewall_rule" "ssh" {
  firewall_group_id = vultr_firewall_group.kidora.id
  ip_type           = "v4"
  protocol          = "tcp"
  port              = "22"
  subnet            = "0.0.0.0"
  subnet_size       = 0
}

# HTTP - Port 80 (IPv4) - allow all
resource "vultr_firewall_rule" "http" {
  firewall_group_id = vultr_firewall_group.kidora.id
  ip_type           = "v4"
  protocol          = "tcp"
  port              = "80"
  subnet            = "0.0.0.0"
  subnet_size       = 0
}

# HTTPS - Port 443 (IPv4) - allow all
resource "vultr_firewall_rule" "https" {
  firewall_group_id = vultr_firewall_group.kidora.id
  ip_type           = "v4"
  protocol          = "tcp"
  port              = "443"
  subnet            = "0.0.0.0"
  subnet_size       = 0
}

# MinIO API - Port 9000 (IPv4) - allow all
resource "vultr_firewall_rule" "minio" {
  firewall_group_id = vultr_firewall_group.kidora.id
  ip_type           = "v4"
  protocol          = "tcp"
  port              = "9000"
  subnet            = "0.0.0.0"
  subnet_size       = 0
}

# MinIO Console - Port 9001 (IPv4) - allow all
resource "vultr_firewall_rule" "minio_console" {
  firewall_group_id = vultr_firewall_group.kidora.id
  ip_type           = "v4"
  protocol          = "tcp"
  port              = "9001"
  subnet            = "0.0.0.0"
  subnet_size       = 0
}

# Backend API - Port 8086 (IPv4) - allow all
resource "vultr_firewall_rule" "backend" {
  firewall_group_id = vultr_firewall_group.kidora.id
  ip_type           = "v4"
  protocol          = "tcp"
  port              = "8086"
  subnet            = "0.0.0.0"
  subnet_size       = 0
}

# MongoDB - Port 27017 (IPv4) - allow all
resource "vultr_firewall_rule" "mongodb" {
  firewall_group_id = vultr_firewall_group.kidora.id
  ip_type           = "v4"
  protocol          = "tcp"
  port              = "27017"
  subnet            = "0.0.0.0"
  subnet_size       = 0
}

# Outbound TCP - Any port
resource "vultr_firewall_rule" "out_tcp" {
  firewall_group_id = vultr_firewall_group.kidora.id
  ip_type           = "v4"
  protocol          = "tcp"
  port              = "1-65535"
  subnet            = "0.0.0.0"
  subnet_size       = 0
}

# Outbound UDP - Any port
resource "vultr_firewall_rule" "out_udp" {
  firewall_group_id = vultr_firewall_group.kidora.id
  ip_type           = "v4"
  protocol          = "udp"
  port              = "1-65535"
  subnet            = "0.0.0.0"
  subnet_size       = 0
}

# ═══════════════════════════════════════════════════════
# Outputs — Useful information after provisioning
# ═══════════════════════════════════════════════════════

output "server_ipv4" {
  description = "Public IPv4 address of the server"
  value       = hcloud_server.kidora.ipv4_address
}

output "server_ipv6" {
  description = "Public IPv6 address of the server"
  value       = hcloud_server.kidora.ipv6_address
}

output "server_name" {
  description = "Name of the provisioned server"
  value       = hcloud_server.kidora.name
}

output "server_type" {
  description = "Server type (plan)"
  value       = hcloud_server.kidora.server_type
}

output "private_ip" {
  description = "Private network IP address"
  value       = "10.0.1.1"
}

output "ssh_command" {
  description = "SSH command to connect to the server"
  value       = "ssh root@${hcloud_server.kidora.ipv4_address}"
}

output "data_volume_id" {
  description = "ID of the data volume"
  value       = hcloud_volume.data.id
}

output "backup_volume_id" {
  description = "ID of the backup volume"
  value       = hcloud_volume.backup.id
}

output "firewall_id" {
  description = "ID of the firewall"
  value       = hcloud_firewall.kidora.id
}

output "network_id" {
  description = "ID of the private network"
  value       = hcloud_network.kidora.id
}
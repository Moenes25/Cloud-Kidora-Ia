# ═══════════════════════════════════════════════════════
# Outputs — Useful information after provisioning
# ═══════════════════════════════════════════════════════

output "server_ipv4" {
  description = "Public IPv4 address of the server"
  value       = vultr_instance.kidora.main_ip
}

output "server_ipv6" {
  description = "Public IPv6 address of the server"
  value       = vultr_instance.kidora.v6_main_ip
}

output "server_name" {
  description = "Label of the provisioned server"
  value       = vultr_instance.kidora.label
}

output "server_type" {
  description = "Server plan type"
  value       = vultr_instance.kidora.plan
}

output "ssh_command" {
  description = "SSH command to connect to the server"
  value       = "ssh root@${vultr_instance.kidora.main_ip}"
}

output "data_volume_id" {
  description = "ID of the data volume"
  value       = vultr_block_storage.data.id
}


output "firewall_group_id" {
  description = "ID of the firewall group"
  value       = vultr_firewall_group.kidora.id
}
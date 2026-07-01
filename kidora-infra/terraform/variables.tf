variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "server_name" {
  description = "Name of the Hetzner server"
  type        = string
  default     = "kidora-prod"
}

variable "server_type" {
  description = "Hetzner server type (CX22 = 2 vCPU, 4GB RAM, 40GB SSD)"
  type        = string
  default     = "cx22"
}

variable "location" {
  description = "Hetzner datacenter location"
  type        = string
  default     = "nbg1"   # Nuremberg
}

variable "os_image" {
  description = "OS image for the server"
  type        = string
  default     = "ubuntu-24.04"
}

variable "ssh_public_key_path" {
  description = "Path to your SSH public key (~/.ssh/id_rsa.pub)"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "firewall_allowed_ips" {
  description = "List of IPs/CIDRs allowed to access SSH and admin interfaces"
  type        = list(string)
  default     = ["0.0.0.0/0"]   # ⚠️ Restrict this in production!
}

variable "ssh_allowed_ips" {
  description = "List of IPs allowed for SSH access (only port 22)"
  type        = list(string)
  default     = ["0.0.0.0/0"]   # ⚠️ Change to your IP in production
}

variable "domain_name" {
  description = "Your domain name for the application"
  type        = string
  default     = "kidora.example.com"
}

variable "email_for_ssl" {
  description = "Email address for Let's Encrypt SSL certificates"
  type        = string
  default     = "admin@example.com"
}

variable "backup_volume_size" {
  description = "Size of the backup volume in GB"
  type        = number
  default     = 0
}

variable "data_volume_size" {
  description = "Size of the data volume (PostgreSQL, MinIO) in GB"
  type        = number
  default     = 0
}

variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default = {
    project     = "kidora"
    environment = "production"
    managed-by  = "terraform"
  }
}
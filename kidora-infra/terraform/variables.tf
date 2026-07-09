# ═══════════════════════════════════════════════════════
# Variables — Vultr Cloud Configuration
# ═══════════════════════════════════════════════════════

variable "vultr_api_key" {
  description = "Vultr API key (can be set via VULTR_API_KEY env variable)"
  type        = string
  sensitive   = true
  default     = "GJGFCYWLJQKFG3NKD5GM6GFAJX3YDDUENBGQ"
}

variable "server_name" {
  description = "Name of the Vultr server"
  type        = string
  default     = "kidora-test"
}

variable "server_type" {
  description = "Vultr server type - 'vc2-1c-1gb' is the lowest tier (1 vCPU, 1GB RAM)"
  type        = string
  default     = "vc2-1c-1gb"
}

variable "location" {
  description = "Vultr datacenter location"
  type        = string
  default     = "ewr"   # New Jersey - change to your preferred region: lax (LA), sjc (Silicon Valley), etc.
}

variable "os_image" {
  description = "OS image ID for the server"
  type        = string
  default     = "1743"   # Ubuntu 24.04 x64 - see https://www.vultr.com/api/ for other images
}

variable "ssh_public_key" {
  description = "Your SSH public key content (contents of ~/.ssh/id_rsa.pub)"
  type        = string
}

variable "firewall_allowed_ips" {
  description = "List of IPs/CIDRs allowed to access HTTP/HTTPS and admin interfaces"
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


variable "data_volume_size" {
  description = "Size of the data volume (MongoDB, MinIO) in GB"
  type        = number
  default     = 10
}

variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default = {
    project     = "kidora"
    environment = "testing"
    managed-by  = "terraform"
  }
}
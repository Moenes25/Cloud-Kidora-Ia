# ═══════════════════════════════════════════════════════
# Provider — Vultr Cloud
# ═══════════════════════════════════════════════════════
# Vultr API token is passed via:
#   1. VULTR_API_KEY environment variable (required), or
#   2. TF_VAR_vultr_api_key environment variable
# ═══════════════════════════════════════════════════════

provider "vultr" {
  api_key    = var.vultr_api_key
  rate_limit = 100
}

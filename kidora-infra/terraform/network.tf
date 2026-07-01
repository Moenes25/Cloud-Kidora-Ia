# ═══════════════════════════════════════════════════════
# Network — Private Network for the server
# ═══════════════════════════════════════════════════════
# For a single-machine setup, we use the default public
# network. A private network is optional but recommended
# for future multi-server expansion.
# ═══════════════════════════════════════════════════════

resource "hcloud_network" "kidora" {
  name     = "${var.server_name}-network"
  ip_range = "10.0.1.0/24"
  labels   = local.common_labels
}

resource "hcloud_network_subnet" "kidora" {
  network_id   = hcloud_network.kidora.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}
module "ssh_key" {
  source     = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/ssh-key"
  key_name   = var.ssh_key_name
  public_key = var.ssh_public_key
}

module "preprod_servers" {
  source = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/vultr-server"

  for_each = {
    app        = "kidora-preprod-app"
    database   = "kidora-preprod-db"
    monitoring = "kidora-preprod-monitoring"
  }

  name       = each.value
  region     = var.region
  plan       = var.plan
  os_id      = var.os_id
  vpc_id     = module.network.vpc_id
  firewall_id = module.firewall.firewall_id
  ssh_key_id = module.ssh_key.ssh_key_id
}


module "firewall" {
  source = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/firewall"
  firewall_name = "kidora-preprod-firewall"
  rules = [
    {
      protocol="tcp"
      port="22"
      ip_type="v4"
      subnet="0.0.0.0"
      subnet_size=0
    },
    {
      protocol="tcp"
      port="443"
      ip_type="v4"
      subnet="0.0.0.0"
      subnet_size=0
    },
    {
      protocol="tcp"
      port="6443"
      ip_type="v4"
      subnet="0.0.0.0"
      subnet_size=0
    }
  ]
}

module "network" {
  source = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/network"
  region = "fra"
  name   = "kidora-preprod-network"
}

module "volume" {
  source = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/volume"
  name   = "kidora-preprod-db-volume"
  region = var.region
  size   = var.volume_size
}

module "object_storage" {
  source  = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/object-storage"
  name    = "kidora-preprod-storage"
  region  = var.region
  cluster = var.storage_cluster
}

module "dns" {
  source  = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/dns"
  domain  = var.dns_domain
  records = var.dns_records
}

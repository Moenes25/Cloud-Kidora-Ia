module "ssh_key" {
  source     = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/ssh-key"
  key_name   = var.ssh_key_name
  public_key = var.ssh_public_key
}

module "k3s_master" {
  source     = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/vultr-server"
  name       = "k3s-master-01"
  region     = var.region
  plan       = var.master_plan
  os_id      = var.os_id
  ssh_key_id = module.ssh_key.ssh_key_id
}

module "metric_server" {
  source     = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/vultr-server"
  name       = "k3s-master-metrics"
  region     = var.region
  plan       = var.master_plan
  os_id      = var.os_id
  ssh_key_id = module.ssh_key.ssh_key_id
}


module "firewall" {
  source = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/firewall"
  firewall_name = "kidora-dev-firewall"
  rules = [
    {
      protocol = "tcp"
      port = "22"
      ip_type = "v4"
      subnet = "0.0.0.0"
      subnet_size = 0
    },
    {
      protocol = "tcp"
      port = "80"
      ip_type = "v4"
      subnet = "0.0.0.0"
      subnet_size = 0
    },
    {
      protocol = "tcp"
      port = "443"
      ip_type = "v4"
      subnet = "0.0.0.0"
      subnet_size = 0
    },
    {
      protocol = "tcp"
      port = "6443"
      ip_type = "v4"
      subnet = "0.0.0.0"
      subnet_size = 0
    },
    {
      protocol = "tcp"
      port = "9090"
      ip_type = "v4"
      subnet = "0.0.0.0"
      subnet_size = 0
    },
    {
      protocol = "tcp"
      port = "3000"
      ip_type = "v4"
      subnet = "0.0.0.0"
      subnet_size = 0
    },
  ]
}

module "object_storage" {
  source  = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/object-storage"
  name    = "kidora-dev-storage"
  region  = var.region
  cluster = var.storage_cluster
}

module "dns" {
  source  = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/dns"
  domain  = var.dns_domain
  records = var.dns_records
}

resource "local_file" "ansible_inventory" {
  filename = "../../../ansible/inventories/dev/hosts.ini"
  content = templatefile("inventory.tpl", {
    dev_server_ip = module.k3s_master.ip_address
  })
}
module "dev_server" {

  source = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/vultr-server"

  name   = var.server_name
  region = var.region
  plan   = var.plan
  os_id  = var.os_id
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
    }

  ]
}
module "dev_server" {

  source = "../../modules/vultr-server"

  name = var.server_name

  region = var.region

  plan = var.plan

  os_id = var.os_id

}
module "preprod_servers" {
  source = "../../modules/vultr-server"

  for_each = {
    app        = "kidora-preprod-app"
    database   = "kidora-preprod-db"
    monitoring = "kidora-preprod-monitoring"
  }

  name   = each.value
  region = var.region
  plan   = var.plan
  os_id  = var.os_id
}
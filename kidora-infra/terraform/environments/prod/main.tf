module "prod_servers" {
  source = "../../modules/vultr-server"

  for_each = {
    app        = "kidora-prod-app"
    database   = "kidora-prod-db"
    monitoring = "kidora-prod-monitoring"
  }

  name   = each.value
  region = var.region
  plan   = var.plan
  os_id  = var.os_id
}
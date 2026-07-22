resource "vultr_instance" "server" {

  plan   = var.plan
  region = var.region
  os_id  = var.os_id

  label = var.name
}   
module "prod_servers" {
  source = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/vultr-server"

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


module "firewall" {

source = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/firewall"

firewall_name = "kidora-prod-firewall"


rules = [

{
 protocol="tcp"
 port="22"
 ip_type="v4"
 subnet="YOUR_ADMIN_IP"
 subnet_size=32
},

{
 protocol="tcp"
 port="80"
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
 subnet_size=24
}

]

}
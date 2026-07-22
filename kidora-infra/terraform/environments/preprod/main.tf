module "preprod_servers" {
  source = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/vultr-server"

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


module "firewall" {

source = "../../modules/firewall"

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
module "ssh_key" {
  source     = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/ssh-key"
  key_name   = var.ssh_key_name
  public_key = var.ssh_public_key
}

module "dev_server" {
  source     = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/vultr-server"
  name       = "kidora-dev-server"
  region     = var.region
  plan       = var.plan
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


module "dns" {
  source  = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/dns"
  domain  = var.dns_domain
  records = var.dns_records
}

resource "null_resource" "git_clone_repo" {
  provisioner "local-exec" {
    command = <<EOT
      if [ ! -d "/tmp/infra-repo/.git" ]; then
        git clone https://github.com/Moenes25/Cloud-Kidora-Ia.git /tmp/infra-repo
      else
        cd /tmp/infra-repo && git pull
      fi
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "local_file" "ansible_inventory" {
  filename = "/tmp/infra-repo/kidora-infra/terraform/environments/dev/inventory.ini"
  content = templatefile("${path.module}/inventory.tpl", {
    dev_server_ip = module.dev_server.ip_address
  })

  depends_on = [null_resource.git_clone_repo]
}

resource "null_resource" "ansible_trigger" {
  depends_on = [module.dev_server, local_file.ansible_inventory]
  
  triggers = {
    inventory_path = local_file.ansible_inventory.filename
    server_ip      = module.dev_server.ip_address
  }
  
  provisioner "local-exec" {
    command = "sleep 30 && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${local_file.ansible_inventory.filename} /tmp/infra-repo/kidora-infra/ansible/playbooks/main.yml"
  }
}


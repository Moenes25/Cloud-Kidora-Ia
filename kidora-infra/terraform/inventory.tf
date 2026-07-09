resource "local_file" "ansible_inventory" {
  filename = "../ansible/inventory/inventory.ini"

  content = <<EOF
[docker]
${vultr_instance.kidora.main_ip} ansible_user=root
EOF
}
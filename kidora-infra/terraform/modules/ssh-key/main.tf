resource "vultr_ssh_key" "key" {
  name       = var.key_name
  public_key = var.public_key
}

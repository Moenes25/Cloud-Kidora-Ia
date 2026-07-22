variable "vultr_api_key" {
  type      = string
  sensitive = true
}




variable "region" {
  type = string
}

variable "plan" {
  type = string
}

variable "os_id" {
  type = number
}
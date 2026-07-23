variable "name" {
  type = string
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

variable "firewall_id" {
  type    = string
  default = null
}

variable "vpc_id" {
  description = "VPC ID to attach the instance to"
  type        = string
  default     = null
}

variable "ssh_key_id" {
  description = "SSH key ID to attach to the instance"
  type        = string
  default     = null
}

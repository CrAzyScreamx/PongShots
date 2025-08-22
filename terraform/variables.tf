variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "tag" {
  description = "Tag for resources"
  type        = string
  default     = "prod"
}

variable "watchtower_interval" {
  description = "Interval for Watchtower updates in seconds"
  type        = number
  default     = 30
}

variable "ssh_key_path" {
  description = "Path to the SSH public key file"
  type        = string
  default     = "./keys/vm-ssh-key.pub"
}

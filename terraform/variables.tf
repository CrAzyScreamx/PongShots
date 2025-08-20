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

locals {
  subnet_cidr = cidrsubnet(var.vpc_cidr, 8, 1)
}

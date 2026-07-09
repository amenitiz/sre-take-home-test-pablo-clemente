locals {
  name_prefix = "${var.project_name}-${var.environment}"

  public_subnet_cidrs = [
    for index, _ in var.availability_zones : cidrsubnet(var.vpc_cidr, 8, index)
  ]

  database_subnet_cidrs = [
    for index, _ in var.availability_zones : cidrsubnet(var.vpc_cidr, 8, index + 10)
  ]
}

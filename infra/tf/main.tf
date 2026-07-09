module "network" {
  source = "./modules/network"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  allowed_alb_cidrs  = var.allowed_alb_cidrs
  app_port           = var.app_port
  db_port            = var.db_port
}

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

module "ecr" {
  source = "./modules/ecr"

  repository_name            = var.ecr_repository_name
  untagged_image_expire_days = var.ecr_untagged_image_expire_days
  tagged_image_count_limit   = var.ecr_tagged_image_count_limit
}

module "compute" {
  source = "./modules/compute"

  name_prefix             = "${var.project_name}-${var.environment}"
  aws_region              = var.aws_region
  subnet_id               = module.network.public_subnet_ids[0]
  app_security_group_id   = module.network.app_security_group_id
  target_group_arn        = module.network.app_target_group_arn
  ecr_repository_name     = module.ecr.repository_name
  app_port                = var.app_port
  instance_type           = var.ec2_instance_type
  root_volume_size        = var.ec2_root_volume_size
  create_instance_profile = var.ec2_create_instance_profile
  instance_profile_name   = var.ec2_instance_profile_name
}

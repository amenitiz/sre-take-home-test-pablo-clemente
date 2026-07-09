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

module "database" {
  source = "./modules/database"

  name_prefix             = "${var.project_name}-${var.environment}"
  db_name                 = var.db_name
  db_username             = var.db_username
  db_instance_class       = var.db_instance_class
  db_allocated_storage    = var.db_allocated_storage
  db_port                 = var.db_port
  db_subnet_group_name    = module.network.database_subnet_group_name
  db_security_group_id    = module.network.database_security_group_id
  rails_secret_key_base   = var.rails_secret_key_base
  recovery_window_in_days = var.secrets_recovery_window_in_days
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
  db_probe_host           = module.database.address
  db_probe_port           = module.database.port
}

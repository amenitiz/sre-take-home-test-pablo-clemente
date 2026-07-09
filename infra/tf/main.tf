data "aws_caller_identity" "current" {}

module "network" {
  source = "./modules/network"

  project_name          = var.project_name
  environment           = var.environment
  vpc_cidr              = var.vpc_cidr
  availability_zones    = var.availability_zones
  allowed_alb_cidrs     = var.allowed_alb_cidrs
  app_port              = var.app_port
  db_port               = var.db_port
  enable_https          = var.enable_https
  https_certificate_arn = module.tls.certificate_arn
}

module "ecr" {
  source = "./modules/ecr"

  repository_name            = var.ecr_repository_name
  untagged_image_expire_days = var.ecr_untagged_image_expire_days
  tagged_image_count_limit   = var.ecr_tagged_image_count_limit
}

module "github_oidc" {
  source = "./modules/github_oidc"

  name_prefix                = "${var.project_name}-${var.environment}"
  aws_region                 = var.aws_region
  aws_account_id             = data.aws_caller_identity.current.account_id
  github_owner               = var.github_owner
  github_repository          = var.github_repository
  github_branch              = var.github_branch
  ecr_repository_arn         = module.ecr.repository_arn
  ec2_instance_arn           = module.compute.instance_arn
  existing_oidc_provider_arn = var.github_existing_oidc_provider_arn
  create_oidc_provider       = var.github_create_oidc_provider
  oidc_thumbprint_sha        = var.github_oidc_thumbprint_sha
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
  recovery_window_in_days = var.secrets_recovery_window_in_days
}

module "compute" {
  source = "./modules/compute"

  name_prefix                   = "${var.project_name}-${var.environment}"
  aws_region                    = var.aws_region
  subnet_id                     = module.network.public_subnet_ids[0]
  app_security_group_id         = module.network.app_security_group_id
  target_group_arn              = module.network.app_target_group_arn
  ecr_repository_name           = module.ecr.repository_name
  app_port                      = var.app_port
  instance_type                 = var.ec2_instance_type
  root_volume_size              = var.ec2_root_volume_size
  create_instance_profile       = var.ec2_create_instance_profile
  instance_profile_name         = var.ec2_instance_profile_name
  app_secret_arn                = module.database.secret_arn
  db_probe_host                 = module.database.address
  db_probe_port                 = module.database.port
  enable_cloudwatch_agent       = var.enable_cloudwatch_agent
  cloudwatch_log_group_name     = var.cloudwatch_log_group_name
  cloudwatch_log_retention_days = var.cloudwatch_log_retention_days
}

module "dns" {
  source = "./modules/dns"

  zone_name    = var.cloudflare_zone_name
  record_name  = var.cloudflare_record_name
  record_type  = "CNAME"
  record_value = module.network.alb_dns_name
  proxied      = var.cloudflare_record_proxied
}

module "tls" {
  source = "./modules/tls"

  zone_name = var.cloudflare_zone_name
  hostname  = "${var.cloudflare_record_name}.${var.cloudflare_zone_name}"
  dns_ttl   = 1
}

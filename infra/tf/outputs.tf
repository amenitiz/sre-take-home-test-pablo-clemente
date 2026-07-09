output "region" {
  description = "AWS region configured for the challenge stack."
  value       = var.aws_region
}

output "vpc_id" {
  description = "ID of the application VPC."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs used by the ALB and public EC2 instances."
  value       = module.network.public_subnet_ids
}

output "database_subnet_ids" {
  description = "Private database subnet IDs used by the RDS subnet group."
  value       = module.network.database_subnet_ids
}

output "public_subnet_count" {
  description = "Number of public subnets created for the ALB tier."
  value       = length(module.network.public_subnet_ids)
}

output "database_subnet_count" {
  description = "Number of private database subnets created for RDS."
  value       = length(module.network.database_subnet_ids)
}

output "has_nat_gateway" {
  description = "Whether this cost-conscious network creates a NAT Gateway."
  value       = false
}

output "alb_security_group_id" {
  description = "Security group ID for the public ALB."
  value       = module.network.alb_security_group_id
}

output "app_security_group_id" {
  description = "Security group ID for the EC2 application instance."
  value       = module.network.app_security_group_id
}

output "database_security_group_id" {
  description = "Security group ID for RDS PostgreSQL."
  value       = module.network.database_security_group_id
}

output "database_subnet_group_name" {
  description = "RDS DB subnet group name."
  value       = module.network.database_subnet_group_name
}

output "alb_arn" {
  description = "ARN of the public Application Load Balancer."
  value       = module.network.alb_arn
}

output "alb_dns_name" {
  description = "DNS name of the public Application Load Balancer."
  value       = module.network.alb_dns_name
}

output "app_target_group_arn" {
  description = "ARN of the app target group for future EC2 attachment."
  value       = module.network.app_target_group_arn
}

output "ecr_repository_name" {
  description = "Name of the private ECR repository for the status page image."
  value       = module.ecr.repository_name
}

output "ecr_repository_url" {
  description = "URL of the private ECR repository used by GitHub Actions and EC2."
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the private ECR repository for IAM policies."
  value       = module.ecr.repository_arn
}

output "ec2_instance_id" {
  description = "ID of the Ubuntu EC2 smoke-test instance."
  value       = module.compute.instance_id
}

output "ec2_public_ip" {
  description = "Public IP address of the Ubuntu EC2 smoke-test instance."
  value       = module.compute.public_ip
}

output "ec2_instance_profile_name" {
  description = "IAM instance profile attached to the Ubuntu EC2 smoke-test instance."
  value       = module.compute.instance_profile_name
}

output "ec2_created_instance_profile" {
  description = "Whether Terraform created the EC2 IAM role and instance profile."
  value       = module.compute.created_instance_profile
}

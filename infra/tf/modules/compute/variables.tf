variable "name_prefix" {
  description = "Prefix used for compute resource names."
  type        = string
}

variable "aws_region" {
  description = "AWS region used by the smoke-test bootstrap."
  type        = string
}

variable "subnet_id" {
  description = "Public subnet ID where the EC2 instance is launched."
  type        = string
}

variable "app_security_group_id" {
  description = "Security group ID allowing ALB traffic to the app port."
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN where the instance is registered."
  type        = string
}

variable "ecr_repository_name" {
  description = "ECR repository name used by the smoke-test bootstrap."
  type        = string
}

variable "app_port" {
  description = "Application port exposed by the smoke-test service."
  type        = number
}

variable "instance_type" {
  description = "EC2 instance type for the Ubuntu smoke-test host."
  type        = string
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB."
  type        = number
}

variable "create_instance_profile" {
  description = "Whether this module should create an EC2 IAM role and instance profile for SSM/ECR access."
  type        = bool
}

variable "instance_profile_name" {
  description = "Existing EC2 instance profile name to attach when create_instance_profile is false."
  type        = string
  default     = null
}

variable "db_probe_host" {
  description = "Database host used by the smoke service DB network probe."
  type        = string
  default     = null
}

variable "db_probe_port" {
  description = "Database port used by the smoke service DB network probe."
  type        = number
  default     = 5432
}

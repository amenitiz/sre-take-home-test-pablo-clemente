variable "name_prefix" {
  description = "Prefix used for GitHub Actions IAM resources."
  type        = string
}

variable "aws_region" {
  description = "AWS region used by the deployment workflow."
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID where the workflow role is created."
  type        = string
}

variable "github_owner" {
  description = "GitHub repository owner allowed to assume the workflow role."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository name allowed to assume the workflow role."
  type        = string
}

variable "github_branch" {
  description = "GitHub branch allowed to assume the workflow role."
  type        = string
}

variable "ecr_repository_arn" {
  description = "ECR repository ARN the workflow can push images to."
  type        = string
}

variable "ec2_instance_arn" {
  description = "EC2 instance ARN the workflow can deploy to via SSM."
  type        = string
}

variable "existing_oidc_provider_arn" {
  description = "Existing GitHub OIDC provider ARN. Leave null to use the standard provider ARN for this AWS account."
  type        = string
  default     = null
}

variable "create_oidc_provider" {
  description = "Whether Terraform should create the account-global GitHub Actions OIDC provider."
  type        = bool
  default     = false
}

variable "oidc_thumbprint_sha" {
  description = "GitHub Actions OIDC provider root certificate thumbprint."
  type        = string
  default     = "6938fd4d98bab03faadb97b34396831e3780aea1"
}

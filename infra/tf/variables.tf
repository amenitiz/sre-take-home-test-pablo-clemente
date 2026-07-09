variable "aws_region" {
  description = "AWS region for all challenge resources."
  type        = string
  default     = "eu-west-3"

  validation {
    condition     = var.aws_region == "eu-west-3"
    error_message = "The challenge only allows resources in eu-west-3."
  }
}

variable "project_name" {
  description = "Short name used for resource naming."
  type        = string
  default     = "status-page"
}

variable "environment" {
  description = "Deployment environment name used in tags and resource names."
  type        = string
  default     = "challenge"
}

variable "vpc_cidr" {
  description = "CIDR block for the application VPC."
  type        = string
  default     = "10.42.0.0/16"
}

variable "availability_zones" {
  description = "Two eu-west-3 Availability Zones used for public and database subnets."
  type        = list(string)
  default     = ["eu-west-3a", "eu-west-3b"]

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "Exactly two Availability Zones are required for the ALB and RDS subnet group."
  }

  validation {
    condition     = alltrue([for zone in var.availability_zones : startswith(zone, "eu-west-3")])
    error_message = "Availability Zones must belong to eu-west-3."
  }
}

variable "allowed_alb_cidrs" {
  description = "CIDR ranges allowed to reach the public ALB. Keep broad initially, or replace with Cloudflare IP ranges later."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "app_port" {
  description = "Rails application port exposed by the EC2 instance to the ALB."
  type        = number
  default     = 3000
}

variable "db_port" {
  description = "PostgreSQL port exposed by RDS to the EC2 instance."
  type        = number
  default     = 5432
}

variable "tags" {
  description = "Additional tags to apply to all supported AWS resources."
  type        = map(string)
  default     = {}
}

variable "ecr_repository_name" {
  description = "Name of the private ECR repository used for the status page image."
  type        = string
  default     = "status-page"

  validation {
    condition     = can(regex("^[a-z0-9]+([._/-]?[a-z0-9]+)*$", var.ecr_repository_name))
    error_message = "ECR repository names must use lowercase letters, numbers, and separators like hyphen, underscore, slash, or dot."
  }
}

variable "ecr_untagged_image_expire_days" {
  description = "Number of days to keep untagged ECR images before expiration."
  type        = number
  default     = 7

  validation {
    condition     = var.ecr_untagged_image_expire_days > 0
    error_message = "The untagged image expiration period must be greater than zero days."
  }
}

variable "ecr_tagged_image_count_limit" {
  description = "Maximum number of tagged ECR images to retain."
  type        = number
  default     = 10

  validation {
    condition     = var.ecr_tagged_image_count_limit > 0
    error_message = "The tagged image count limit must be greater than zero."
  }
}

variable "ec2_instance_type" {
  description = "EC2 instance type for the Ubuntu smoke-test host."
  type        = string
  default     = "t3.micro"

  validation {
    condition     = can(regex("^t3\\.", var.ec2_instance_type))
    error_message = "The Ubuntu amd64 AMI lookup requires a t3 instance type."
  }
}

variable "ec2_root_volume_size" {
  description = "Root EBS volume size in GiB for the Ubuntu smoke-test host."
  type        = number
  default     = 8

  validation {
    condition     = var.ec2_root_volume_size >= 8
    error_message = "Ubuntu root volume size must be at least 8 GiB."
  }
}

variable "ec2_create_instance_profile" {
  description = "Whether Terraform should create an EC2 IAM role and instance profile for SSM/ECR access."
  type        = bool
  default     = false
}

variable "ec2_instance_profile_name" {
  description = "Existing EC2 instance profile name to attach when ec2_create_instance_profile is false."
  type        = string
  default     = null
}

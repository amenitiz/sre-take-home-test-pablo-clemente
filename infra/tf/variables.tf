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

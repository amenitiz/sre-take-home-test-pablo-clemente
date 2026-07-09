variable "project_name" {
  description = "Short name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment name used in tags and resource names."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the application VPC."
  type        = string
}

variable "availability_zones" {
  description = "Two eu-west-3 Availability Zones used for public and database subnets."
  type        = list(string)
}

variable "allowed_alb_cidrs" {
  description = "CIDR ranges allowed to reach the public ALB."
  type        = list(string)
}

variable "app_port" {
  description = "Rails application port exposed by the EC2 instance to the ALB."
  type        = number
}

variable "db_port" {
  description = "PostgreSQL port exposed by RDS to the EC2 instance."
  type        = number
}

variable "name_prefix" {
  description = "Prefix used for database resource names."
  type        = string
}

variable "db_name" {
  description = "PostgreSQL database name."
  type        = string
}

variable "db_username" {
  description = "PostgreSQL master username."
  type        = string
}

variable "db_instance_class" {
  description = "RDS PostgreSQL instance class."
  type        = string
}

variable "db_allocated_storage" {
  description = "Allocated RDS storage in GiB."
  type        = number
}

variable "db_port" {
  description = "PostgreSQL port."
  type        = number
}

variable "db_subnet_group_name" {
  description = "DB subnet group name for the private RDS subnets."
  type        = string
}

variable "db_security_group_id" {
  description = "Security group ID attached to the RDS instance."
  type        = string
}

variable "recovery_window_in_days" {
  description = "Secrets Manager recovery window in days."
  type        = number
}

variable "repository_name" {
  description = "Name of the private ECR repository."
  type        = string
}

variable "untagged_image_expire_days" {
  description = "Number of days to keep untagged ECR images before expiration."
  type        = number
}

variable "tagged_image_count_limit" {
  description = "Maximum number of tagged ECR images to retain."
  type        = number
}

output "role_name" {
  description = "IAM role name assumed by GitHub Actions."
  value       = aws_iam_role.github_actions.name
}

output "role_arn" {
  description = "IAM role ARN assumed by GitHub Actions."
  value       = aws_iam_role.github_actions.arn
}

output "provider_arn" {
  description = "GitHub OIDC provider ARN trusted by the workflow role."
  value       = local.provider_arn
}

output "trusted_subject" {
  description = "GitHub Actions OIDC subject allowed to assume the role."
  value       = local.trusted_subject
}

output "ecr_repository_arn" {
  description = "ECR repository ARN allowed for image pushes."
  value       = var.ecr_repository_arn
}

output "ec2_instance_arn" {
  description = "EC2 instance ARN allowed for SSM deployment commands."
  value       = var.ec2_instance_arn
}

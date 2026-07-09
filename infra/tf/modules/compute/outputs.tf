output "instance_id" {
  description = "ID of the Ubuntu EC2 smoke-test instance."
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IP address of the Ubuntu EC2 smoke-test instance."
  value       = aws_instance.this.public_ip
}

output "instance_type" {
  description = "EC2 instance type used by the smoke-test host."
  value       = aws_instance.this.instance_type
}

output "app_port" {
  description = "Application port used by the smoke-test service and ALB target group attachment."
  value       = var.app_port
}

output "ubuntu_ami_owner" {
  description = "Canonical AWS account ID used for the Ubuntu AMI lookup."
  value       = local.ubuntu_ami_owner
}

output "ssh_key_configured" {
  description = "Whether SSH key access is configured for the instance."
  value       = false
}

output "instance_profile_name" {
  description = "IAM instance profile attached to the EC2 instance."
  value       = var.create_instance_profile ? aws_iam_instance_profile.this[0].name : var.instance_profile_name
}

output "created_instance_profile" {
  description = "Whether this module created an EC2 IAM role and instance profile."
  value       = var.create_instance_profile
}

output "runs_instance_profile_bootstrap" {
  description = "Whether user data runs SSM/ECR bootstrap that requires an instance profile."
  value       = var.create_instance_profile
}

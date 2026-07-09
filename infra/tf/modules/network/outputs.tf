output "vpc_id" {
  description = "ID of the application VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs used by the ALB and public EC2 instances."
  value       = values(aws_subnet.public)[*].id
}

output "database_subnet_ids" {
  description = "Private database subnet IDs used by the RDS subnet group."
  value       = values(aws_subnet.database)[*].id
}

output "alb_security_group_id" {
  description = "Security group ID for the public ALB."
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "Security group ID for the EC2 application instance."
  value       = aws_security_group.app.id
}

output "database_security_group_id" {
  description = "Security group ID for RDS PostgreSQL."
  value       = aws_security_group.database.id
}

output "database_subnet_group_name" {
  description = "RDS DB subnet group name."
  value       = aws_db_subnet_group.this.name
}

output "alb_arn" {
  description = "ARN of the public Application Load Balancer."
  value       = aws_lb.app.arn
}

output "alb_dns_name" {
  description = "DNS name of the public Application Load Balancer."
  value       = aws_lb.app.dns_name
}

output "app_target_group_arn" {
  description = "ARN of the app target group for future EC2 attachment."
  value       = aws_lb_target_group.app.arn
}

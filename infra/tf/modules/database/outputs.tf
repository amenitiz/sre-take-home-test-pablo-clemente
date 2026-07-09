output "address" {
  description = "RDS PostgreSQL endpoint address."
  value       = aws_db_instance.this.address
}

output "port" {
  description = "RDS PostgreSQL port."
  value       = aws_db_instance.this.port
}

output "engine" {
  description = "RDS database engine."
  value       = aws_db_instance.this.engine
}

output "db_name" {
  description = "RDS PostgreSQL database name."
  value       = aws_db_instance.this.db_name
}

output "publicly_accessible" {
  description = "Whether the RDS instance is publicly accessible."
  value       = aws_db_instance.this.publicly_accessible
}

output "secret_arn" {
  description = "Secrets Manager ARN containing Rails production runtime configuration."
  value       = aws_secretsmanager_secret.app.arn
}

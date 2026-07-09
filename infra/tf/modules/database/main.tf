resource "random_password" "db" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "rails_secret_key_base" {
  length  = 128
  special = false
}

resource "aws_db_instance" "this" {
  identifier = "${var.name_prefix}-postgres"

  engine         = "postgres"
  engine_version = "16"
  instance_class = var.db_instance_class

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db.result
  port     = var.db_port

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.db_security_group_id]
  publicly_accessible    = false
  multi_az               = false

  backup_retention_period = 1
  deletion_protection     = false
  skip_final_snapshot     = true
  apply_immediately       = true
}

resource "aws_secretsmanager_secret" "app" {
  name                    = "${var.name_prefix}/app-env"
  description             = "Rails production runtime environment for the status page app"
  recovery_window_in_days = var.recovery_window_in_days
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id = aws_secretsmanager_secret.app.id

  secret_string = jsonencode({
    RAILS_ENV           = "production"
    SECRET_KEY_BASE     = random_password.rails_secret_key_base.result
    DATABASE_URL        = "postgres://${var.db_username}:${urlencode(random_password.db.result)}@${aws_db_instance.this.address}:${var.db_port}/${var.db_name}"
    PORT                = "3000"
    RAILS_MAX_THREADS   = "3"
    RAILS_LOG_TO_STDOUT = "1"
  })
}

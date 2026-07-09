mock_provider "aws" {}
mock_provider "random" {}

run "database_contract" {
  command = apply

  module {
    source = "./modules/database"
  }

  variables {
    name_prefix             = "status-page-challenge"
    db_name                 = "status_page_production"
    db_username             = "status_page"
    db_instance_class       = "db.t3.micro"
    db_allocated_storage    = 20
    db_port                 = 5432
    db_subnet_group_name    = "status-page-challenge-db-subnets"
    db_security_group_id    = "sg-1234567890abcdef0"
    rails_secret_key_base   = "test-secret-key-base"
    recovery_window_in_days = 0
  }

  assert {
    condition     = output.engine == "postgres"
    error_message = "RDS must use regular PostgreSQL, not Aurora."
  }

  assert {
    condition     = output.db_name == "status_page_production"
    error_message = "RDS database name must match the Rails production database."
  }

  assert {
    condition     = output.port == 5432
    error_message = "RDS PostgreSQL must listen on port 5432."
  }

  assert {
    condition     = output.publicly_accessible == false
    error_message = "RDS must not be publicly accessible."
  }

  assert {
    condition     = output.secret_arn != ""
    error_message = "Secrets Manager ARN must be exposed for the app runtime secret."
  }
}

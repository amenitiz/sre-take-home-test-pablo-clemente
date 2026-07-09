# RDS And Secrets Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add private PostgreSQL and app runtime secret storage for the Rails status page.

**Architecture:** Terraform creates a private single-AZ RDS PostgreSQL instance in the database subnet group with security group access only from EC2. Terraform generates the database password and stores the Rails runtime environment as one Secrets Manager secret containing `DATABASE_URL`, `SECRET_KEY_BASE`, and production app settings.

**Tech Stack:** Terraform, AWS RDS PostgreSQL, AWS Secrets Manager, Terraform native tests, EC2 TCP smoke probe.

---

## Retrospective Status

Implemented in commit `daf2554`. The duplicate DB-only secret was deliberately removed so there is a single app runtime secret.

## File Structure

- Modify: `infra/tf/main.tf`: wire database module into root stack and pass network outputs.
- Modify: `infra/tf/variables.tf`: add DB sizing, database name, username, Rails secret, and secret recovery inputs.
- Modify: `infra/tf/outputs.tf`: expose RDS endpoint, port, and app secret ARN.
- Modify: `infra/tf/modules/compute/templates/user_data.sh.tftpl`: add `/db-healthz` TCP probe to smoke server.
- Create: `infra/tf/modules/database/*`: RDS, password generation, and app env secret.
- Create: `infra/tf/tests/database.tftest.hcl`: database contract test.

### Task 1: Add Database Contract

- [x] **Step 1: Write Terraform test**

Assert:

```hcl
output.engine == "postgres"
output.port == 5432
output.publicly_accessible == false
output.storage_encrypted == true
```

- [x] **Step 2: Verify red state**

Run:

```bash
cd infra/tf
terraform test -filter=tests/database.tftest.hcl
```

Expected before implementation: fail because the database module and outputs do not exist.

### Task 2: Create Database Module

- [x] **Step 1: Add generated DB password**

Use:

```hcl
resource "random_password" "db" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
```

- [x] **Step 2: Add PostgreSQL RDS instance**

Create `aws_db_instance` with:

```hcl
engine                = "postgres"
engine_version        = "16"
instance_class        = var.db_instance_class
allocated_storage     = var.db_allocated_storage
storage_type          = "gp3"
storage_encrypted     = true
publicly_accessible   = false
multi_az              = false
backup_retention_period = 1
```

- [x] **Step 3: Add app runtime secret**

Create one Secrets Manager secret with JSON keys:

```json
{
  "RAILS_ENV": "production",
  "SECRET_KEY_BASE": "value",
  "DATABASE_URL": "postgres://user:password@host:5432/status_page_production",
  "PORT": "3000",
  "RAILS_MAX_THREADS": "3",
  "RAILS_LOG_TO_STDOUT": "1"
}
```

### Task 3: Add EC2 Database Probe

- [x] **Step 1: Extend smoke server**

Add `/db-healthz` to open a TCP connection to the RDS hostname and port.

- [x] **Step 2: Verify deployed connectivity**

Run against the public hostname:

```bash
curl https://status-page.amenitiz-qa-1.ovh/db-healthz
```

Expected:

```json
{"status":"ok"}
```

### Task 4: Verify

- [x] **Step 1: Run Terraform checks**

Run:

```bash
cd infra/tf
terraform fmt -recursive
terraform validate
terraform test
tflint --recursive
```

Expected after implementation: all checks pass.


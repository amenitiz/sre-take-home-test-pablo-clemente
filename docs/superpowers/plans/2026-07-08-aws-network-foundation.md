# AWS Network Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the first Terraform slice for the Amenitiz challenge: a cost-conscious AWS network foundation for ALB, public EC2 placement, and private RDS PostgreSQL in `eu-west-3`.

**Architecture:** The stack creates one VPC with two public subnets and two private database subnets across `eu-west-3a` and `eu-west-3b`. The ALB is public, the future EC2 instance is intended to run in a public subnet with restrictive security groups and no SSH ingress, and RDS is private with PostgreSQL access only from the EC2 app security group. No NAT Gateway is created to reduce fixed hourly cost.

**Tech Stack:** Terraform `>= 1.15.0`, AWS provider `~> 6.0`, Terraform native tests, TFLint.

---

## File Structure

- Create `infra/tf/versions.tf`: root Terraform and AWS provider constraints, configured for `eu-west-3`.
- Create `infra/tf/locals.tf`: shared tags.
- Create `infra/tf/variables.tf`: root input variables and challenge-region validation.
- Create `infra/tf/main.tf`: root module call to `modules/network`.
- Create `infra/tf/outputs.tf`: outputs for subsequent EC2, RDS, and DNS work.
- Create `infra/tf/.gitignore`: ignore Terraform cache, state, and local plans.
- Create `infra/tf/README.md`: operator notes and verification commands.
- Create `infra/tf/tests/network.tftest.hcl`: Terraform test asserting the network contract.
- Create `infra/tf/modules/network/versions.tf`: module Terraform and AWS provider constraints for standalone linting.
- Create `infra/tf/modules/network/variables.tf`: module inputs.
- Create `infra/tf/modules/network/locals.tf`: naming and subnet CIDR calculations.
- Create `infra/tf/modules/network/main.tf`: VPC, subnets, routing, security groups, DB subnet group, ALB, listener, and target group.
- Create `infra/tf/modules/network/outputs.tf`: module outputs consumed by the root stack.

### Task 1: Write The Network Contract Test

**Files:**
- Create: `infra/tf/tests/network.tftest.hcl`

- [x] **Step 1: Create a Terraform native test for the challenge network contract**

```hcl
run "network_contract" {
  command = plan

  variables {
    project_name       = "status-page"
    environment        = "test"
    vpc_cidr           = "10.42.0.0/16"
    availability_zones = ["eu-west-3a", "eu-west-3b"]
  }

  assert {
    condition     = output.region == "eu-west-3"
    error_message = "AWS resources must be configured for the eu-west-3 challenge region."
  }

  assert {
    condition     = output.public_subnet_count == 2
    error_message = "The ALB tier must have two public subnets in distinct AZs."
  }

  assert {
    condition     = output.database_subnet_count == 2
    error_message = "The RDS subnet group must have two private database subnets."
  }

  assert {
    condition     = output.has_nat_gateway == false
    error_message = "The cost-conscious network design must not create a NAT Gateway."
  }
}
```

- [x] **Step 2: Run the test and verify it fails before implementation**

Run:

```bash
cd infra/tf
terraform test
```

Expected: FAIL with undeclared variable and output errors because the Terraform stack does not exist yet.

### Task 2: Create The Root Terraform Stack

**Files:**
- Create: `infra/tf/versions.tf`
- Create: `infra/tf/locals.tf`
- Create: `infra/tf/variables.tf`
- Create: `infra/tf/main.tf`
- Create: `infra/tf/outputs.tf`

- [x] **Step 1: Add root Terraform and provider constraints**

```hcl
terraform {
  required_version = ">= 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}
```

- [x] **Step 2: Add shared root tags**

```hcl
locals {
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )
}
```

- [x] **Step 3: Add root variables with region and AZ validation**

```hcl
variable "aws_region" {
  description = "AWS region for all challenge resources."
  type        = string
  default     = "eu-west-3"

  validation {
    condition     = var.aws_region == "eu-west-3"
    error_message = "The challenge only allows resources in eu-west-3."
  }
}

variable "availability_zones" {
  description = "Two eu-west-3 Availability Zones used for public and database subnets."
  type        = list(string)
  default     = ["eu-west-3a", "eu-west-3b"]

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "Exactly two Availability Zones are required for the ALB and RDS subnet group."
  }

  validation {
    condition     = alltrue([for zone in var.availability_zones : startswith(zone, "eu-west-3")])
    error_message = "Availability Zones must belong to eu-west-3."
  }
}
```

- [x] **Step 4: Wire the root stack to the network module**

```hcl
module "network" {
  source = "./modules/network"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  allowed_alb_cidrs  = var.allowed_alb_cidrs
  app_port           = var.app_port
  db_port            = var.db_port
}
```

- [x] **Step 5: Expose outputs required by the test and future layers**

Expose at least these outputs from `infra/tf/outputs.tf`:

```hcl
output "region" {
  description = "AWS region configured for the challenge stack."
  value       = var.aws_region
}

output "public_subnet_count" {
  description = "Number of public subnets created for the ALB tier."
  value       = length(module.network.public_subnet_ids)
}

output "database_subnet_count" {
  description = "Number of private database subnets created for RDS."
  value       = length(module.network.database_subnet_ids)
}

output "has_nat_gateway" {
  description = "Whether this cost-conscious network creates a NAT Gateway."
  value       = false
}
```

### Task 3: Build The Network Module

**Files:**
- Create: `infra/tf/modules/network/versions.tf`
- Create: `infra/tf/modules/network/variables.tf`
- Create: `infra/tf/modules/network/locals.tf`
- Create: `infra/tf/modules/network/main.tf`
- Create: `infra/tf/modules/network/outputs.tf`

- [x] **Step 1: Add module provider metadata for standalone linting**

```hcl
terraform {
  required_version = ">= 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
```

- [x] **Step 2: Add module inputs**

```hcl
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
```

- [x] **Step 3: Add deterministic subnet CIDR calculations**

```hcl
locals {
  name_prefix = "${var.project_name}-${var.environment}"

  public_subnet_cidrs = [
    for index, _ in var.availability_zones : cidrsubnet(var.vpc_cidr, 8, index)
  ]

  database_subnet_cidrs = [
    for index, _ in var.availability_zones : cidrsubnet(var.vpc_cidr, 8, index + 10)
  ]
}
```

- [x] **Step 4: Create VPC, Internet Gateway, public subnets, database subnets, and public routing**

Create these resource blocks in `infra/tf/modules/network/main.tf`:

```hcl
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.name_prefix}-igw"
  }
}

resource "aws_subnet" "public" {
  for_each = {
    for index, zone in var.availability_zones : zone => local.public_subnet_cidrs[index]
  }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true
}

resource "aws_subnet" "database" {
  for_each = {
    for index, zone in var.availability_zones : zone => local.database_subnet_cidrs[index]
  }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = false
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}
```

Expected behavior: public subnets map public IPs on launch; database subnets do not.

- [x] **Step 5: Create the RDS subnet group**

```hcl
resource "aws_db_subnet_group" "this" {
  name       = "${local.name_prefix}-db-subnets"
  subnet_ids = values(aws_subnet.database)[*].id
}
```

- [x] **Step 6: Create security groups and rules**

Create these security group resources:

```hcl
resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Allow public HTTP and HTTPS traffic to the application load balancer"
  vpc_id      = aws_vpc.this.id
}

resource "aws_security_group" "app" {
  name        = "${local.name_prefix}-app-sg"
  description = "Allow ALB traffic to the EC2 Rails application"
  vpc_id      = aws_vpc.this.id
}

resource "aws_security_group" "database" {
  name        = "${local.name_prefix}-database-sg"
  description = "Allow PostgreSQL traffic only from the EC2 application security group"
  vpc_id      = aws_vpc.this.id
}
```

Rules must enforce:

- ALB accepts HTTP `80` and HTTPS `443`.
- EC2 app accepts `3000` only from the ALB security group.
- RDS accepts PostgreSQL `5432` only from the EC2 app security group.
- EC2 app can reach outbound HTTP `80`, HTTPS `443`, DNS `53`, and PostgreSQL `5432` to the RDS security group.

- [x] **Step 7: Create the ALB, listener, and app target group**

Create these load balancer resources:

```hcl
resource "aws_lb" "app" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = values(aws_subnet.public)[*].id
}

resource "aws_lb_target_group" "app" {
  name        = "${local.name_prefix}-app-tg"
  port        = var.app_port
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.this.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/healthz"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
```

Target group requirements:

- Protocol: `HTTP`
- Target type: `instance`
- Port: `var.app_port`
- Health check path: `/healthz`
- Health matcher: `200`

- [x] **Step 8: Expose module outputs for subsequent EC2/RDS work**

Expose VPC ID, public subnet IDs, database subnet IDs, security group IDs, DB subnet group name, ALB ARN/DNS name, and app target group ARN.

### Task 4: Add Operator Documentation And Ignore Rules

**Files:**
- Create: `infra/tf/README.md`
- Create: `infra/tf/.gitignore`

- [x] **Step 1: Document the network slice**

Document that the first slice creates:

- VPC with DNS support.
- Two public subnets.
- Two private database subnets.
- Internet Gateway and public route table.
- ALB, listener, app target group, and security groups.
- No NAT Gateway.

- [x] **Step 2: Add Terraform ignore rules**

```gitignore
.terraform/
*.tfstate
*.tfstate.*
*.tfplan
crash.log
crash.*.log
override.tf
override.tf.json
*_override.tf
*_override.tf.json
```

### Task 5: Verify The Network Slice

**Files:**
- Verify: `infra/tf/**/*.tf`
- Verify: `infra/tf/tests/network.tftest.hcl`

- [x] **Step 1: Initialize Terraform without a backend**

Run:

```bash
cd infra/tf
terraform init -backend=false
```

Expected: provider installation succeeds and `.terraform.lock.hcl` is created.

- [x] **Step 2: Format Terraform**

Run:

```bash
terraform fmt -recursive
```

Expected: command exits `0`.

- [x] **Step 3: Validate Terraform**

Run:

```bash
terraform validate
```

Expected:

```text
Success! The configuration is valid.
```

- [x] **Step 4: Run Terraform tests**

Run:

```bash
terraform test
```

Expected:

```text
Success! 1 passed, 0 failed.
```

- [x] **Step 5: Run TFLint**

Run:

```bash
tflint --recursive
```

Expected: command exits `0` with no lint findings.

If TFLint fails in the Codex sandbox with a Unix socket bind error, rerun with command escalation because TFLint's bundled plugin opens a local Unix socket.

### Task 6: Commit The Network Slice After Deployment Review

**Files:**
- Stage: `infra/tf/.gitignore`
- Stage: `infra/tf/.terraform.lock.hcl`
- Stage: `infra/tf/README.md`
- Stage: `infra/tf/*.tf`
- Stage: `infra/tf/modules/network/*.tf`
- Stage: `infra/tf/tests/network.tftest.hcl`
- Stage: `docs/superpowers/plans/2026-07-08-aws-network-foundation.md`

- [ ] **Step 1: Confirm no Terraform state files are staged**

Run:

```bash
git status --short --ignored infra/tf
```

Expected: `.terraform/` and state files are ignored; no `terraform.tfstate` or lock-info file is staged.

- [ ] **Step 2: Stage the intended files only**

Run:

```bash
git add infra/tf docs/superpowers/plans/2026-07-08-aws-network-foundation.md
```

- [ ] **Step 3: Review staged files**

Run:

```bash
git diff --cached --name-only
```

Expected: Terraform code, lock file, README, `.gitignore`, test file, and this plan file are listed. Local Terraform state files are not listed.

- [ ] **Step 4: Commit after the user confirms deployment succeeded**

Run:

```bash
git commit -m "feat: add AWS network foundation"
```

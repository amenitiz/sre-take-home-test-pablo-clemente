# Registry And Compute Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the container registry and Ubuntu EC2 foundation needed to run the status page behind the ALB.

**Architecture:** Terraform creates a low-cost private ECR repository and a single Ubuntu EC2 instance attached to the ALB target group. Because the sandbox denied `iam:CreateRole`, the EC2 instance profile path is optional and disabled by default, while a temporary smoke server validates ALB and database connectivity.

**Tech Stack:** Terraform, AWS ECR, EC2, ALB target groups, Ubuntu cloud-init, systemd, Terraform native tests.

---

## Retrospective Status

Implemented in commit `5984eda` with later adjustments for database probing and CloudWatch toggles.

## File Structure

- Modify: `infra/tf/main.tf`: wire ECR and compute modules.
- Modify: `infra/tf/variables.tf`: add ECR and EC2 inputs, including IAM profile toggles.
- Modify: `infra/tf/outputs.tf`: expose ECR and EC2 outputs.
- Create: `infra/tf/modules/ecr/*`: low-cost ECR repository and lifecycle policy.
- Create: `infra/tf/modules/compute/*`: Ubuntu EC2, optional IAM role/profile, ALB target attachment, smoke server user-data.
- Create: `infra/tf/tests/ecr.tftest.hcl`: registry contract test.
- Create: `infra/tf/tests/compute.tftest.hcl`: compute contract test.

### Task 1: Add ECR Repository

- [x] **Step 1: Write ECR contract test**

Run:

```bash
cd infra/tf
terraform test -filter=tests/ecr.tftest.hcl
```

Expected before implementation: fail because the ECR module and outputs do not exist.

- [x] **Step 2: Create ECR module**

Create `infra/tf/modules/ecr/main.tf` with:

```hcl
resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}
```

- [x] **Step 3: Add lifecycle policy**

Keep storage cost bounded by expiring old untagged images and retaining a limited number of tagged images.

- [x] **Step 4: Wire root outputs**

Expose repository name, URL, and ARN for future IAM/deployment work.

### Task 2: Add Ubuntu EC2 Instance

- [x] **Step 1: Write compute contract test**

Assert these properties:

```hcl
output.instance_type == "t3.micro"
output.app_port == 3000
output.ubuntu_ami_owner == "099720109477"
output.created_instance_profile == false
```

- [x] **Step 2: Create compute module**

Use Canonical Ubuntu 24.04 amd64 AMI lookup, `t3.micro`, encrypted gp3 root volume, public subnet placement, and ALB target group attachment.

- [x] **Step 3: Add IAM profile toggle**

Default:

```hcl
variable "ec2_create_instance_profile" {
  type    = bool
  default = false
}
```

When enabled, create an EC2 IAM role/profile with SSM and ECR read-only policy attachments.

- [x] **Step 4: Add temporary smoke server**

Create a systemd-managed Python server on port `3000` that exposes `/healthz` and later `/db-healthz`.

### Task 3: Verify

- [x] **Step 1: Format**

Run:

```bash
cd infra/tf
terraform fmt -recursive
```

- [x] **Step 2: Validate**

Run:

```bash
terraform validate
```

- [x] **Step 3: Test**

Run:

```bash
terraform test
```

- [x] **Step 4: Lint**

Run:

```bash
tflint --recursive
```

Expected after implementation: all checks pass.


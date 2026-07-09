# EC2 App Deployment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the temporary smoke server with the real Rails status page container on EC2.

**Architecture:** EC2 runs a systemd-managed Docker container behind the ALB. The instance profile allows SSM, ECR reads, and Secrets Manager reads. User-data installs Docker and AWS CLI through official upstream installation paths, writes `/opt/status-page/deploy.sh`, and keeps the temporary smoke service available until the first real app deployment.

**Tech Stack:** Terraform, EC2 user-data, Docker, systemd, Rails container, RDS PostgreSQL, Secrets Manager optional runtime path, GitHub Actions optional deploy path.

---

## Status

Implemented locally. The remaining external verification is the GitHub Actions deployment run after the workflow is pushed.

## File Structure

- Modify: `infra/tf/main.tf`: pass app secret ARN and ECR settings into compute module.
- Modify: `infra/tf/modules/compute/variables.tf`: add app secret and IAM profile inputs.
- Modify: `infra/tf/modules/compute/templates/user_data.sh.tftpl`: install Docker, AWS CLI, SSM agent, write deploy script, and create the Rails systemd service.
- Modify: `infra/tf/modules/compute/main.tf`: grant EC2 SSM, ECR read, and Secrets Manager read permissions through the instance profile.
- Modify: `infra/tf/modules/compute/outputs.tf`: expose instance ARN and profile-related outputs.
- Modify: `infra/tf/tests/compute.tftest.hcl`: assert the compute/deploy contract.

### Task 1: Define Deployment Contract

- [ ] **Step 1: Add root variables**

Add:

```hcl
variable "app_image" {
  description = "Container image to run on EC2 for the status page app."
  type        = string
}

variable "render_app_env_from_terraform" {
  description = "Render the app env file in EC2 user-data as a fallback when EC2 cannot read Secrets Manager."
  type        = bool
  default     = true
}
```

- [ ] **Step 2: Pass variables to compute module**

In `infra/tf/main.tf`, pass:

```hcl
app_image                     = var.app_image
render_app_env_from_terraform = var.render_app_env_from_terraform
app_env_secret_json           = module.database.app_env_secret_json
```

### Task 2: Expose App Env JSON From Database Module

- [ ] **Step 1: Add database module output**

Add:

```hcl
output "app_env_secret_json" {
  description = "Rails production runtime environment JSON. Sensitive because it contains DATABASE_URL and SECRET_KEY_BASE."
  value       = aws_secretsmanager_secret_version.app.secret_string
  sensitive   = true
}
```

- [ ] **Step 2: Add root pass-through only for compute**

Do not expose this as a human-facing root output. Pass it directly into compute to avoid casual CLI display.

### Task 3: Replace Smoke Server With Rails Container

- [ ] **Step 1: Install Docker outside IAM profile block**

Move Docker install out of the `create_instance_profile` conditional so the fallback path can run containers.

- [ ] **Step 2: Write env file**

When `render_app_env_from_terraform` is true, write `/opt/status-page/.env` from Terraform-rendered key/value pairs.

- [ ] **Step 3: Add migration service**

Run once during boot:

```bash
docker run --rm --env-file /opt/status-page/.env "${app_image}" bin/rails db:prepare
```

- [ ] **Step 4: Add systemd service**

Create `status-page.service` with:

```ini
[Unit]
Description=Status Page Rails container
After=docker.service network-online.target
Requires=docker.service
Wants=network-online.target

[Service]
Restart=always
RestartSec=5
ExecStartPre=-/usr/bin/docker rm -f status-page
ExecStart=/usr/bin/docker run --name status-page --env-file /opt/status-page/.env -p 3000:3000 ${app_image}
ExecStop=/usr/bin/docker stop status-page

[Install]
WantedBy=multi-user.target
```

### Task 4: Add Compute Tests

- [ ] **Step 1: Assert app image is configured**

In `infra/tf/tests/compute.tftest.hcl`, set:

```hcl
app_image = "ghcr.io/example/status-page:abc123"
```

Assert:

```hcl
output.app_image == "ghcr.io/example/status-page:abc123"
```

- [ ] **Step 2: Assert smoke server is no longer the app path**

Remove or replace assertions that only validate the temporary smoke server.

### Task 5: Verify Deployment

- [ ] **Step 1: Run local Terraform checks**

Run:

```bash
cd infra/tf
terraform fmt -recursive
terraform validate
terraform test
tflint --recursive
```

- [ ] **Step 2: Apply**

Run with the image pushed by GHCR:

```bash
terraform apply -var='app_image=ghcr.io/<owner>/status-page:<sha>'
```

- [ ] **Step 3: Verify public app behavior**

Run:

```bash
curl https://status-page.amenitiz-qa-1.ovh/healthz
curl https://status-page.amenitiz-qa-1.ovh/
```

Then create and edit a service through the web UI.

Expected: Rails app responds from the public URL, persists data in RDS, and `/healthz` returns a valid response.

### Task 6: Preferred Profile-Based Deployment Path

- [ ] **Step 1: Enable EC2 instance profile when IAM permissions are fixed**

Set:

```bash
terraform apply -var='ec2_create_instance_profile=true'
```

- [ ] **Step 2: Add Secrets Manager runtime read**

Replace Terraform-rendered env fallback with EC2 boot-time:

```bash
aws secretsmanager get-secret-value --secret-id status-page-challenge/app-env --query SecretString --output text
```

- [ ] **Step 3: Add GitHub OIDC deploy path**

Create an IAM role trusted by GitHub Actions and allow `ssm:SendCommand` to the EC2 instance. The workflow deploy job sends a command containing the new immutable image tag.

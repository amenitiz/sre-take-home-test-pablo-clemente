# Optional CloudWatch Logging Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a cost-conscious CloudWatch Logs option without breaking the default IAM-restricted deployment path.

**Architecture:** Terraform adds a CloudWatch Agent toggle, disabled by default. When both `ec2_create_instance_profile` and `enable_cloudwatch_agent` are true, EC2 receives CloudWatch permissions, installs the agent, and ships cloud-init/syslog to a retained log group.

**Tech Stack:** Terraform, AWS CloudWatch Logs, EC2 user-data, Amazon CloudWatch Agent, Terraform native tests.

---

## Retrospective Status

Implemented in commit `f92c451`. Disabled by default because the sandbox denied IAM role creation.

## File Structure

- Modify: `infra/tf/variables.tf`: add CloudWatch toggle, log group name, and retention days.
- Modify: `infra/tf/main.tf`: pass CloudWatch settings into compute module.
- Modify: `infra/tf/outputs.tf`: expose CloudWatch enabled status and log group name.
- Modify: `infra/tf/modules/compute/variables.tf`: add module inputs.
- Modify: `infra/tf/modules/compute/main.tf`: add optional log group and optional IAM policy attachment.
- Modify: `infra/tf/modules/compute/outputs.tf`: expose effective CloudWatch state.
- Modify: `infra/tf/modules/compute/templates/user_data.sh.tftpl`: install/configure CloudWatch Agent when enabled.
- Modify: `infra/tf/tests/compute.tftest.hcl`: assert CloudWatch remains disabled by default.

### Task 1: Add Default-Off Contract

- [x] **Step 1: Extend compute test variables**

Set:

```hcl
enable_cloudwatch_agent       = false
cloudwatch_log_group_name     = "/status-page/challenge/app"
cloudwatch_log_retention_days = 7
```

- [x] **Step 2: Add assertions**

Assert:

```hcl
output.cloudwatch_agent_enabled == false
output.cloudwatch_log_group_name == null
```

- [x] **Step 3: Verify red state**

Run:

```bash
cd infra/tf
terraform test -filter=tests/compute.tftest.hcl
```

Expected before implementation: fail because outputs and variables do not exist.

### Task 2: Add Terraform Toggle

- [x] **Step 1: Add root variables**

Add:

```hcl
variable "enable_cloudwatch_agent" {
  type    = bool
  default = false
}
```

- [x] **Step 2: Add retention validation**

Allow only CloudWatch-supported retention values such as `1`, `3`, `5`, `7`, `14`, `30`, `60`, `90`, `365`, and longer AWS-supported values.

- [x] **Step 3: Add optional log group**

Create:

```hcl
resource "aws_cloudwatch_log_group" "app" {
  count             = var.enable_cloudwatch_agent ? 1 : 0
  name              = var.cloudwatch_log_group_name
  retention_in_days = var.cloudwatch_log_retention_days
}
```

### Task 3: Add Agent Bootstrap

- [x] **Step 1: Attach CloudWatch policy only when profile path is enabled**

Use:

```hcl
count = var.create_instance_profile && var.enable_cloudwatch_agent ? 1 : 0
```

- [x] **Step 2: Install agent from AWS package**

Download the Ubuntu `.deb` package from AWS and install with `dpkg`.

- [x] **Step 3: Configure log collection**

Collect:

```text
/var/log/cloud-init-output.log
/var/log/syslog
```

### Task 4: Verify

- [x] **Step 1: Run checks**

Run:

```bash
cd infra/tf
terraform fmt -recursive
terraform validate
terraform test
tflint --recursive
```

Expected after implementation: all checks pass.


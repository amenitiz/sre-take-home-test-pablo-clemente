# ECR OIDC SSM Deployment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Rails image in GitHub Actions, push it to private ECR, and deploy the immutable image tag to EC2 through SSM.

**Architecture:** Terraform creates a GitHub Actions IAM role trusted through GitHub OIDC for only the `challenge` branch of this repository. The role can push to the `status-page` ECR repository and send `AWS-RunShellScript` commands to the status page EC2 instance. The workflow builds `status-page/Dockerfile`, pushes the image tagged with the commit SHA, discovers the EC2 instance by tag, and calls `/opt/status-page/deploy.sh <image-uri>` through SSM.

**Tech Stack:** Terraform, AWS IAM OIDC, GitHub Actions, ECR, SSM Run Command, Docker.

---

## Retrospective Status

Implemented locally. The GitHub OIDC provider already existed in the AWS account, so the module defaults to reusing the account-global provider ARN and only creates the provider when explicitly requested.

## File Structure

- Create: `infra/tf/modules/github_oidc/*`: GitHub Actions IAM role, trust policy, and least-privilege ECR/SSM permissions.
- Modify: `infra/tf/main.tf`: wire the GitHub OIDC module to ECR and EC2 outputs.
- Modify: `infra/tf/variables.tf`: add repository, branch, and OIDC provider controls.
- Modify: `infra/tf/outputs.tf`: expose the GitHub Actions role ARN and trusted subject.
- Create: `infra/tf/tests/github_oidc.tftest.hcl`: assert OIDC branch restriction, ECR scope, EC2 scope, and provider reuse.
- Create: `.github/workflows/build-push-deploy-ecr.yml`: build, push, and deploy pipeline.

### Task 1: Add GitHub OIDC Contract

- [x] **Step 1: Restrict trust to this repository and branch**

Assert the trusted subject:

```text
repo:amenitiz/sre-take-home-test-pablo-clemente:ref:refs/heads/challenge
```

- [x] **Step 2: Reuse the account-global OIDC provider by default**

Default provider ARN:

```text
arn:aws:iam::<account_id>:oidc-provider/token.actions.githubusercontent.com
```

Creation is opt-in with:

```hcl
github_create_oidc_provider = true
```

### Task 2: Add Least-Privilege AWS Role

- [x] **Step 1: Allow ECR push only to the status page repository**

Grant image upload and image metadata actions against the `status-page` ECR repository ARN.

- [x] **Step 2: Allow SSM deploy only to the status page EC2 instance**

Allow `ssm:SendCommand` for `AWS-RunShellScript` and the target EC2 instance ARN. Allow read-only command lookup actions needed by the workflow.

### Task 3: Add Build Push Deploy Workflow

- [x] **Step 1: Configure OIDC authentication**

Use:

```yaml
permissions:
  contents: read
  id-token: write
```

and assume:

```text
arn:aws:iam::376129434003:role/status-page-challenge-github-actions-role
```

- [x] **Step 2: Build and push immutable image**

Build `status-page/Dockerfile` and push:

```text
376129434003.dkr.ecr.eu-west-3.amazonaws.com/status-page:<github-sha>
```

- [x] **Step 3: Deploy through SSM**

Discover the EC2 instance with `Name=status-page-challenge-app` and run:

```bash
sudo /opt/status-page/deploy.sh "<image-uri>"
```

### Task 4: Verify

- [x] `terraform validate`
- [x] `terraform test`
- [x] `tflint --recursive`
- [x] Workflow YAML parse
- [ ] Push workflow and confirm GitHub Actions deploys the real Rails app

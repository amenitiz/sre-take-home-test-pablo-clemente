# Cloudflare And HTTPS Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Expose the status page stack at a Cloudflare-managed hostname with ALB HTTPS.

**Architecture:** Terraform creates a Cloudflare CNAME pointing `status-page.amenitiz-qa-1.ovh` to the ALB. Terraform creates an ACM certificate validated through Cloudflare DNS, configures an ALB HTTPS listener, and redirects HTTP traffic to HTTPS.

**Tech Stack:** Terraform, AWS ACM, AWS ALB listeners, Cloudflare provider v5, Cloudflare API token, Terraform native tests.

---

## Retrospective Status

Implemented in commit `02690bc`. HTTP redirects to HTTPS and both `/healthz` and `/db-healthz` were verified publicly.

## File Structure

- Modify: `infra/tf/main.tf`: wire DNS and TLS modules and pass certificate ARN to network.
- Modify: `infra/tf/variables.tf`: add Cloudflare zone/record variables and `enable_https`.
- Modify: `infra/tf/outputs.tf`: expose public hostname, public URL, HTTPS URL, ACM certificate ARN, and HTTPS enabled status.
- Modify: `infra/tf/modules/network/*`: add optional HTTPS listener and HTTP redirect behavior.
- Create: `infra/tf/modules/dns/*`: Cloudflare CNAME record.
- Create: `infra/tf/modules/tls/*`: ACM certificate and Cloudflare DNS validation.
- Create: `infra/tf/tests/dns.tftest.hcl`: DNS contract test.
- Create: `infra/tf/tests/tls.tftest.hcl`: TLS contract test.

### Task 1: Add Cloudflare DNS Module

- [x] **Step 1: Write DNS contract**

Assert hostname construction and CNAME intent:

```hcl
output.hostname == "status-page.amenitiz-qa-1.ovh"
output.public_url == "http://status-page.amenitiz-qa-1.ovh"
```

- [x] **Step 2: Create Cloudflare DNS record**

Use `cloudflare_dns_record` with:

```hcl
name    = var.record_name
type    = "CNAME"
content = var.record_value
proxied = var.proxied
ttl     = 1
```

### Task 2: Add ACM Certificate And Validation

- [x] **Step 1: Write TLS contract**

Assert:

```hcl
output.hostname == "status-page.amenitiz-qa-1.ovh"
output.https_url == "https://status-page.amenitiz-qa-1.ovh"
```

- [x] **Step 2: Create ACM certificate**

Use DNS validation for the Cloudflare-managed hostname.

- [x] **Step 3: Upsert validation record**

Use a local-exec helper against Cloudflare API because Cloudflare provider v5 cannot always plan unknown ACM validation record fields cleanly.

### Task 3: Enable ALB HTTPS

- [x] **Step 1: Add network module inputs**

Add:

```hcl
variable "enable_https" {
  type = bool
}

variable "https_certificate_arn" {
  type = string
}
```

- [x] **Step 2: Add HTTPS listener**

Create `aws_lb_listener` on port `443` with the ACM certificate.

- [x] **Step 3: Redirect HTTP to HTTPS**

When `enable_https` is true, configure the HTTP listener to return a `301` redirect to HTTPS.

### Task 4: Verify

- [x] **Step 1: Run local checks**

Run:

```bash
cd infra/tf
terraform fmt -recursive
terraform validate
terraform test
tflint --recursive
```

- [x] **Step 2: Verify deployed endpoints**

Run:

```bash
curl -I http://status-page.amenitiz-qa-1.ovh/healthz
curl https://status-page.amenitiz-qa-1.ovh/healthz
curl https://status-page.amenitiz-qa-1.ovh/db-healthz
```

Expected:

```text
HTTP 301 redirect to HTTPS
{"status":"ok"}
{"status":"ok"}
```


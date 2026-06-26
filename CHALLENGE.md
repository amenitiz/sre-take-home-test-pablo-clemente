# Amenitiz Infrastructure Challenge

## Overview

You've been given access to an AWS account and a simple Rails application (in the `status-page/` directory). Your task is to deploy this application to AWS in a way you'd be comfortable handing over to a teammate to operate.

**Time guidance:** We expect this to take 3-4 hours depending on your familiarity with the tools involved. If something isn't cooperating, that's just infrastructure being infrastructure. We genuinely don't want you spending more time on this than necessary. If anything is unclear or you're stuck on something that feels like it shouldn't be hard, please reach out to us. We'd rather clarify upfront than have you spend time on the wrong thing.

## What You're Given

- **This repository** containing a working Rails app with PostgreSQL
- **An AWS IAM user** (you can create EC2 instances, RDS databases, load balancers, VPCs, etc...)
- **A Cloudflare user with a domain** (`amenitiz-qa-1.ovh`) you have full control over its DNS records
- **A starter Dockerfile** in `status-page/` -- it works, but it's not production-optimised. Improve it or replace it as you see fit.
- **A `.env.example`** showing the environment variables the app expects in production
- The app works locally with `docker compose up` for the database and `bin/rails server` if you want to verify before deploying

**Note:** The test suite has a known issue. Run `bin/rails test` before you start -- we'd like to see how you handle it.

**Heads up:** RDS databases and EC2 provisioning take a few minutes on AWS. This is normal -- use the wait time to work on other parts of your submission.

### AWS Sandbox Constraints

The AWS account is a **disposable sandbox** with a few guardrails. These exist for cost control, not to trip you up:

- **Region:** create resources in `eu-west-3`. Other regions are blocked.
- **Instance sizes:** EC2 is limited to `t3`/`t4g` up to `*.large`; RDS to `db.t3`/`db.t4g` up to `*.medium`. That's more than enough for this app.
- **IAM:** you can create roles and instance profiles (e.g. for EC2), but not IAM users or access keys.
- **DNS:** the domain is managed in Cloudflare, not Route 53.

If you hit an `AccessDenied` that seems to contradict the task, it's almost certainly a guardrail -- ping us and we'll sort it out.

## The Task

Deploy the Status Page application so that it is:

1. **Accessible over HTTP(S)** at a public URL (an IP address is fine, a domain is a bonus)
2. **Running against a real PostgreSQL database** (not SQLite, not an in-container database)
3. **Functional** -- the root page loads, services can be created/edited, and `/healthz` returns a valid response

Beyond getting it running, **make it production-ready to whatever degree you think matters most given the time**. Some things you _might_ consider (this is not a checklist -- prioritise what you think matters):

- Infrastructure as code
- How the app process is managed
- Firewall / network security
- How secrets and configuration are handled
- How you'd deploy a new version of the app
- Health checking
- Logging
- Repository QoL (linters, checks...)

## What To Submit

When you're done, **open a pull request in this repository** containing all infrastructure code you wrote (Terraform/OpenTofu, scripts, config files, etc.).

In your **PR description**, include:

- The **public URL of the running application**
- **What approach you chose and why**
- **What you prioritised and what you deliberately left out**
- **What you'd do differently with more time**
- **Cost implications of your build**
- **Anything that gave you trouble**

A few paragraphs is fine -- we care about your thinking, not essay length.

## Constraints

- **Use AWS** -- the whole point is to work within the provided cloud environment
- **Do not use ECS or EKS** -- we want to see how you think about servers and infrastructure, not YAML templating
- **Fargate, Lambda, Lightsail and other PaaS solutions are also off-limits** -- we want to see you make infrastructure decisions, not use a PaaS
- You may use any IaC tool (Terraform, OpenTofu, Pulumi, Ansible, shell scripts, etc.)
- You may modify the Rails application if needed for deployment (e.g. adjusting config, improving the Dockerfile, adding a Procfile), but the application code itself doesn't need changes

## A Note on AI Tools

You're welcome to use whatever tools you normally use, including AI assistants. But be aware: **we will review your pull request and ask questions about your choices**. We'll want to understand _why_ you made specific decisions, how you'd debug issues, and what trade-offs you considered. Your ability to explain and discuss your work matters as much as the work itself.

## What We're Looking For

We're hiring an SRE. This exercise is intentionally open-ended because the role is too. We want to understand:

- **How you think about infrastructure** -- not just whether you can make it work
- **How you prioritise** -- what's worth doing in a handful of hours vs. what can wait
- **How you communicate decisions** -- your PR description matters as much as the code
- **How you'd operate this in production** -- could someone else understand and maintain what you built?

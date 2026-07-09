# Status Page Terraform

Terraform infrastructure for the Amenitiz Status Page challenge.

This first slice creates the AWS network foundation in `eu-west-3`:

- One VPC with DNS support enabled.
- Two public subnets for the public Application Load Balancer and the cost-conscious public EC2 placement.
- Two private database subnets for the RDS subnet group.
- Internet gateway and public route table.
- Security groups for ALB, EC2 app traffic, and RDS PostgreSQL.
- Public HTTP ALB, HTTP listener, and app target group using `/healthz`.
- No NAT Gateway, to avoid fixed hourly cost for this take-home.

## Traffic Model

```text
Cloudflare -> ALB :80/:443 -> EC2 :3000 -> RDS PostgreSQL :5432
```

The EC2 security group accepts app traffic only from the ALB security group. The RDS security group accepts PostgreSQL only from the EC2 app security group.

## Commands

```bash
terraform init -backend=false
terraform fmt -recursive
terraform validate
terraform test
tflint --recursive
```

mock_provider "aws" {}
mock_provider "cloudflare" {}

override_resource {
  target = module.tls.aws_acm_certificate.this
  values = {
    arn = "arn:aws:acm:eu-west-3:123456789012:certificate/00000000-0000-0000-0000-000000000000"
    domain_validation_options = [
      {
        domain_name           = "status-page.amenitiz-qa-1.ovh"
        resource_record_name  = "_validation.status-page.amenitiz-qa-1.ovh"
        resource_record_type  = "CNAME"
        resource_record_value = "_validation.acm-validations.aws"
      }
    ]
  }
}

run "network_contract" {
  command = plan

  variables {
    project_name       = "status-page"
    environment        = "test"
    vpc_cidr           = "10.42.0.0/16"
    availability_zones = ["eu-west-3a", "eu-west-3b"]
    enable_https       = true
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

  assert {
    condition     = output.https_enabled == true
    error_message = "The ALB must support HTTPS when a certificate is provided."
  }
}

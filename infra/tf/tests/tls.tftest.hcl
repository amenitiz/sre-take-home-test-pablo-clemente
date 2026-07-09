mock_provider "aws" {}
mock_provider "cloudflare" {}

override_resource {
  target = aws_acm_certificate.this
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

run "tls_contract" {
  command = plan

  module {
    source = "./modules/tls"
  }

  variables {
    zone_name = "amenitiz-qa-1.ovh"
    hostname  = "status-page.amenitiz-qa-1.ovh"
    dns_ttl   = 1
  }

  assert {
    condition     = output.domain_name == "status-page.amenitiz-qa-1.ovh"
    error_message = "TLS certificate must be issued for the status page hostname."
  }

  assert {
    condition     = output.https_url == "https://status-page.amenitiz-qa-1.ovh"
    error_message = "TLS module must expose the HTTPS public URL."
  }
}

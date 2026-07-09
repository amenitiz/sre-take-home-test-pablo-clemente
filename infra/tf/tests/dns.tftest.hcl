mock_provider "cloudflare" {}

run "dns_contract" {
  command = apply

  module {
    source = "./modules/dns"
  }

  variables {
    zone_name    = "amenitiz-qa-1.ovh"
    record_name  = "status-page"
    record_type  = "CNAME"
    record_value = "status-page-challenge-alb-1994744909.eu-west-3.elb.amazonaws.com"
    proxied      = false
  }

  assert {
    condition     = output.hostname == "status-page.amenitiz-qa-1.ovh"
    error_message = "DNS module must expose the expected public hostname."
  }

  assert {
    condition     = output.public_url == "http://status-page.amenitiz-qa-1.ovh"
    error_message = "DNS module must expose the expected HTTP public URL."
  }

  assert {
    condition     = output.proxied == false
    error_message = "Cloudflare proxying must be disabled initially for simpler ALB debugging."
  }
}

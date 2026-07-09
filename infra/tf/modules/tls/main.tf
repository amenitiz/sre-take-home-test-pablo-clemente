data "cloudflare_zone" "this" {
  filter = {
    name = var.zone_name
  }
}

resource "aws_acm_certificate" "this" {
  domain_name       = var.hostname
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "terraform_data" "cloudflare_validation_record" {
  input = {
    zone_id = data.cloudflare_zone.this.id
    name    = one(aws_acm_certificate.this.domain_validation_options[*].resource_record_name)
    content = one(aws_acm_certificate.this.domain_validation_options[*].resource_record_value)
    type    = one(aws_acm_certificate.this.domain_validation_options[*].resource_record_type)
    ttl     = var.dns_ttl
  }

  # We're using a local-exec provisioner instead of a data source because we need to
  # use the Cloudflare API to create the validation record.
  # The data source would not be able to do this because it is not a native Terraform
  # provider

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -euo pipefail
      python3 - "$CLOUDFLARE_API_TOKEN" '${jsonencode(self.input)}' <<'PY'
      import json
      import os
      import sys
      import urllib.parse
      import urllib.request

      token = sys.argv[1]
      record = json.loads(sys.argv[2])
      zone_id = record["zone_id"]
      record_type = record["type"]
      record_name = record["name"].rstrip(".")
      api_base = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records"
      headers = {
          "Authorization": f"Bearer {token}",
          "Content-Type": "application/json",
      }

      def request(method, url, payload=None):
          data = None if payload is None else json.dumps(payload).encode()
          req = urllib.request.Request(url, data=data, headers=headers, method=method)
          with urllib.request.urlopen(req) as response:
              body = json.loads(response.read().decode())
          if not body.get("success"):
              raise SystemExit(body)
          return body

      query = urllib.parse.urlencode({"type": record_type, "name": record_name})
      existing = request("GET", f"{api_base}?{query}")["result"]
      payload = {
          "type": record_type,
          "name": record_name,
          "content": record["content"],
          "ttl": record["ttl"],
          "proxied": False,
      }

      if existing:
          request("PUT", f"{api_base}/{existing[0]['id']}", payload)
      else:
          request("POST", api_base, payload)
      PY
    EOT
  }
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [one(aws_acm_certificate.this.domain_validation_options[*].resource_record_name)]

  depends_on = [terraform_data.cloudflare_validation_record]
}

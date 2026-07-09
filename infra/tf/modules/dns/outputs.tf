output "hostname" {
  description = "Fully qualified public hostname."
  value       = "${var.record_name}.${var.zone_name}"
}

output "public_url" {
  description = "Public HTTP URL."
  value       = "http://${var.record_name}.${var.zone_name}"
}

output "proxied" {
  description = "Whether Cloudflare proxies the DNS record."
  value       = cloudflare_dns_record.status_page.proxied
}

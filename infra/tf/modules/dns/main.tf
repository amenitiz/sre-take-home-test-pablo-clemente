data "cloudflare_zone" "this" {
  filter = {
    name = var.zone_name
  }
}

resource "cloudflare_dns_record" "status_page" {
  zone_id = data.cloudflare_zone.this.id
  name    = var.record_name
  content = var.record_value
  type    = var.record_type
  ttl     = 1
  proxied = var.proxied
}

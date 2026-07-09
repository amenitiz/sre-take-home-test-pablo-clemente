variable "zone_name" {
  description = "Cloudflare DNS zone name used for ACM DNS validation."
  type        = string
}

variable "hostname" {
  description = "Fully qualified hostname for the ACM certificate."
  type        = string
}

variable "dns_ttl" {
  description = "TTL for ACM validation DNS records."
  type        = number
}

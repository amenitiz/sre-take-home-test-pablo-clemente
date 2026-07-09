variable "zone_name" {
  description = "Cloudflare DNS zone name."
  type        = string
}

variable "record_name" {
  description = "DNS record name inside the Cloudflare zone."
  type        = string
}

variable "record_type" {
  description = "DNS record type."
  type        = string
}

variable "record_value" {
  description = "DNS record target value."
  type        = string
}

variable "proxied" {
  description = "Whether Cloudflare proxies the DNS record."
  type        = bool
}

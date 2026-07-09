output "domain_name" {
  description = "Domain name covered by the ACM certificate."
  value       = aws_acm_certificate.this.domain_name
}

output "certificate_arn" {
  description = "Validated ACM certificate ARN."
  value       = aws_acm_certificate_validation.this.certificate_arn
}

output "https_url" {
  description = "Public HTTPS URL."
  value       = "https://${var.hostname}"
}

output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.wildcard.arn
}

output "domain_validation_options" {
  description = "DNS records"
  value       = aws_acm_certificate.wildcard.domain_validation_options
}

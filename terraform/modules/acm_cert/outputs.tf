output "certificate_arn" {
  value       = aws_acm_certificate.wildcard.arn
}

output "domain_validation_options" {
  value       = aws_acm_certificate.wildcard.domain_validation_options
}

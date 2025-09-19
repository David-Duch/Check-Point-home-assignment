output "zone_id" {
  value       = aws_route53_zone.this.zone_id
  description = "The Route53 hosted zone ID"
}

output "zone_name" {
  value       = aws_route53_zone.this.name
  description = "The domain name of the hosted zone"
}

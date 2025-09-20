output "alb_arn" {
  value       = aws_lb.this.arn
  description = "ARN of the ALB"
}

output "alb_dns_name" {
  value       = aws_lb.this.dns_name
  description = "DNS name of the ALB"
}

output "alb_listener_arn" {
  value       = aws_lb_listener.https.arn
  description = "ARN of the HTTPS listener"
}

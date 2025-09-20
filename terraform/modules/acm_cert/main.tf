resource "aws_acm_certificate" "wildcard" {
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"

  tags = {
    Project = var.project
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = all
  }
}
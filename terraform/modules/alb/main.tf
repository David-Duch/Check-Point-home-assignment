resource "aws_lb" "this" {
  name               = "${var.name}-${terraform.workspace}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.subnets

  tags = {
    Project = var.project
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Service unavailable"
      status_code  = "503"
    }
  }
}

# Placeholder for future rules on port 443
# resource "aws_lb_listener_rule" "example" {
#   listener_arn = aws_lb_listener.https.arn
#   priority     = 100
#   action {
#     type             = "forward"
#     target_group_arn = "<TARGET_GROUP_ARN>"
#   }
#   condition {
#     path_pattern {
#       values = ["/example*"]
#     }
#   }
# }

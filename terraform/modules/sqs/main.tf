resource "aws_sqs_queue" "this" {
  name = "${var.name}.fifo"
  fifo_queue = true
  content_based_deduplication = true

  visibility_timeout_seconds = 30
  message_retention_seconds  = 86400
  delay_seconds              = 0
  max_message_size           = 262144

  tags = {
    Project = var.project
  }
}

resource "aws_sqs_queue_policy" "this_policy" {
  queue_url = aws_sqs_queue.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "SQSAccountPolicy"
    Statement = [
      {
        Sid       = "AllowAccountActions"
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        }
        Action   = "SQS:*"
        Resource = aws_sqs_queue.this.arn
      }
    ]
  })
}

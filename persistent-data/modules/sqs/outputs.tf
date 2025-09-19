output "queue_id" {
  description = "The ID of the SQS queue"
  value       = aws_sqs_queue.this.id
}

output "sqs_arn" {
  value = aws_sqs_queue.this.arn
}

output "sqs_url" {
  value = aws_sqs_queue.this.id
}

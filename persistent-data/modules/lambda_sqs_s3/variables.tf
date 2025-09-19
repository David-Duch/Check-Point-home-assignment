variable "lambda_name" {
  type        = string
  description = "Base name for Lambda function"
}

variable "sqs_queue_arn" {
  type        = string
  description = "SQS queue ARN"
}

variable "s3_bucket" {
  type        = string
  description = "S3 bucket name"
}

variable "s3_path" {
  type        = string
  default     = "messages/"
}

variable "schedule_expression" {
  type        = string
  default     = "rate(5 minutes)"
}

variable "image_uri" {
  type        = string
  description = "ECR image URI for Lambda"
}

variable "project" {
  type        = string
  default     = "Checkpoint"
}

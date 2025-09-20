variable "lambda_name" {}
variable "image_uri" {}
variable "sqs_arn" {}
variable "sqs_url" {}
variable "s3_bucket" {}
variable "s3_path" {}
variable "schedule_expression" {}
variable "project" {
  default = "Checkpoint"
}

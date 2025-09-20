variable "name" {
  description = "Name of the SQS queue"
  type        = string
}

variable "account_id" {
  description = "AWS account ID for the queue policy"
  type        = string
}

variable "project" {
  description = "Project tag"
  type        = string
  default     = "Checkpoint"
}

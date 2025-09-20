variable "name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "account_id" {
  description = "AWS account ID for bucket policy"
  type        = string
}

variable "project" {
  description = "Project tag"
  type        = string
  default     = "Checkpoint"
}

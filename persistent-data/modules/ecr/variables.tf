variable "name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "account_id" {
  description = "AWS account ID for policy"
  type        = string
}

variable "project" {
  description = "Project tag"
  type        = string
  default     = "Checkpoint"
}
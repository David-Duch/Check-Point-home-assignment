variable "name" {
  type        = string
  description = "Base name for the ALB"
}

variable "vpc_id" {
  type        = string
  description = "VPC where the ALB will be created"
}

variable "alb_sg_id" {
  type        = string
  description = "Security group ID for the ALB"
}

variable "subnets" {
  type        = list(string)
  description = "Subnets for the ALB"
}

variable "project" {
  type        = string
  default     = "Checkpoint"
  description = "Project tag"
}

variable "certificate_arn" {
  type        = string
  description = "ARN of the ACM certificate to use for HTTPS"
}

variable "name" {
  type        = string
}

variable "vpc_id" {
  type        = string
}

variable "alb_sg_id" {
  type        = string
}

variable "subnets" {
  type        = list(string)
}

variable "project" {
  type        = string
  default     = "Checkpoint"
}

variable "certificate_arn" {
  type        = string
}

variable "messages_target_group_arn" {
  type        = string
  default     = ""  # optional if sometimes empty
}
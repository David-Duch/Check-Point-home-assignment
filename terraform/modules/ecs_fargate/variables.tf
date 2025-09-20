variable "aws_region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "service_name" {
  type = string
}

variable "project" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "security_groups" {
  type = list(string)
}

variable "image_url" {
  type = string
}

variable "container_port" {
  type    = number
  default = 5000
}

variable "cpu" {
  type    = number
  default = 512
}

variable "memory" {
  type    = number
  default = 1024
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "token_param_arn" {
  type = string
}

variable "sqs_url" {
  type = string
}

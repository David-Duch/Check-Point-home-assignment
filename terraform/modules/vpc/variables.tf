variable "name" {
  type        = string
}

variable "cidr_block" {
  type        = string
}

variable "public_subnet_cidrs" {
  type        = list(string)
}

variable "private_subnet_cidrs" {
  type        = list(string)
}

variable "availability_zones" {
  type        = list(string)
}

variable "project" {
  type        = string
  default     = "Checkpoint"
}

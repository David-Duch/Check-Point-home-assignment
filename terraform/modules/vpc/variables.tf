variable "name" {
  description = "Base name for resources"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDRs for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDRs for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of AZs for subnets"
  type        = list(string)
}

variable "project" {
  description = "Project tag"
  type        = string
  default     = "Checkpoint"
}

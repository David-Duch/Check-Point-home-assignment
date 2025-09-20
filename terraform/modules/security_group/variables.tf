variable "name" {
  description = "Name of the security group"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the security group"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port     = number
    to_port       = number
    protocol      = string
    cidr_blocks   = list(string)
    source_sg_id  = string
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress rules"
  type = list(object({
    from_port         = number
    to_port           = number
    protocol          = string
    cidr_blocks       = list(string)
    destination_sg_id = string
  }))
  default = []
}

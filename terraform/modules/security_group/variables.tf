variable "name" {
  type        = string
}

variable "vpc_id" {
  type        = string
}

variable "ingress_rules" {
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
  type = list(object({
    from_port         = number
    to_port           = number
    protocol          = string
    cidr_blocks       = list(string)
    destination_sg_id = string
  }))
  default = []
}

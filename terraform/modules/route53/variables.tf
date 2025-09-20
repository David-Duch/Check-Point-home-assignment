variable "domain_name" {
  type        = string
}

variable "records" {
  type = map(object({
    name    = string
    type    = string
    ttl     = number
    records = list(string)
  }))
  default = {}
}

variable "project" {
  type        = string
  default     = "Checkpoint"
}
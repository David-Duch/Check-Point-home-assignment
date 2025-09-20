variable "domain_name" {
  description = "The domain name for the hosted zone"
  type        = string
}

variable "records" {
  description = "Map of Route53 records to create"
  type = map(object({
    name    = string
    type    = string
    ttl     = number
    records = list(string)
  }))
  default = {}
}

variable "project" {
  description = "Project tag for resources"
  type        = string
  default     = "Checkpoint"
}
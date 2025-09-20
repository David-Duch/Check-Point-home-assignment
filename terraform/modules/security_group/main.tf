resource "aws_security_group" "this" {
  name        = var.name
  description = "Managed by Terraform"
  vpc_id      = var.vpc_id
  tags = {
    Project = "Checkpoint"
  }
}

# Ingress - CIDR blocks
resource "aws_security_group_rule" "ingress_cidr" {
  for_each = { for i, r in var.ingress_rules : i => r if length(r.cidr_blocks) > 0 }

  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  security_group_id = aws_security_group.this.id

  cidr_blocks = each.value.cidr_blocks
}

# Ingress - Source SG
resource "aws_security_group_rule" "ingress_sg" {
  for_each = { for i, r in var.ingress_rules : i => r if can(r.source_sg_id) && r.source_sg_id != "" }

  type                     = "ingress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  security_group_id        = aws_security_group.this.id
  source_security_group_id = each.value.source_sg_id
}

# Egress - CIDR blocks
resource "aws_security_group_rule" "egress_cidr" {
  for_each = { for i, r in var.egress_rules : i => r if length(r.cidr_blocks) > 0 }

  type              = "egress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  security_group_id = aws_security_group.this.id

  cidr_blocks = each.value.cidr_blocks
}

# Egress - Destination SG
resource "aws_security_group_rule" "egress_sg" {
  for_each = { for i, r in var.egress_rules : i => r if can(r.destination_sg_id) && r.destination_sg_id != "" }

  type                     = "egress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  security_group_id        = aws_security_group.this.id
  source_security_group_id = each.value.destination_sg_id
}

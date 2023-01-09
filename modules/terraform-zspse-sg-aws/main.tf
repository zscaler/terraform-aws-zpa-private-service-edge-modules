################################################################################
# Pull in VPC info
################################################################################
data "aws_vpc" "selected" {
  id = var.vpc_id
}


################################################################################
# Create Security Group and Rules for Service Edge Interfaces
################################################################################
resource "aws_security_group" "pse_sg" {
  count       = var.byo_security_group == false ? var.sg_count : 0
  name        = var.sg_count > 1 ? "${var.name_prefix}-pse-${count.index + 1}-sg-${var.resource_tag}" : "${var.name_prefix}-pse-sg-${var.resource_tag}"
  description = "Security group for Service Edge interface"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.global_tags,
    { Name = "${var.name_prefix}-pse-${count.index + 1}-sg-${var.resource_tag}" }
  )
}

# Or use existing Security Group ID
data "aws_security_group" "pse_sg_selected" {
  count = var.byo_security_group == false ? length(aws_security_group.pse_sg[*].id) : length(var.byo_security_group_id)
  id    = var.byo_security_group == false ? element(aws_security_group.pse_sg[*].id, count.index) : element(var.byo_security_group_id, count.index)
}


# Security Group Rules are only created if variable "byo_security_group" is false
resource "aws_security_group_rule" "pse_node_ingress_ssh" {
  count             = var.byo_security_group == false ? var.sg_count : 0
  description       = "Allow SSH to Service Edge VM only from within the VPC CIDR space"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.pse_sg[count.index].id
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
  type              = "ingress"
}

resource "aws_security_group_rule" "pse_node_ingress_https_tcp" {
  count             = var.byo_security_group == false ? var.sg_count : 0
  description       = var.associate_public_ip_address == false ? "Allow HTTPS TCP to Service Edge VM only from within the VPC CIDR space" : "Allow HTTPS TCP to Service Edge VM from Internet"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.pse_sg[count.index].id
  cidr_blocks       = var.associate_public_ip_address == false ? [data.aws_vpc.selected.cidr_block] : ["0.0.0.0/0"]
  type              = "ingress"
}

resource "aws_security_group_rule" "pse_node_ingress_https_udp" {
  count             = var.byo_security_group == false ? var.sg_count : 0
  description       = var.associate_public_ip_address == false ? "Allow HTTPS UDP to Service Edge VM only from within the VPC CIDR space" : "Allow HTTPS UDP to Service Edge VM from Internet"
  from_port         = 443
  to_port           = 443
  protocol          = "udp"
  security_group_id = aws_security_group.pse_sg[count.index].id
  cidr_blocks       = var.associate_public_ip_address == false ? [data.aws_vpc.selected.cidr_block] : ["0.0.0.0/0"]
  type              = "ingress"
}

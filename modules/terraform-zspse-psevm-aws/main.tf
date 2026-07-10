################################################################################
# Create Service Edge VM
################################################################################
resource "aws_instance" "pse_vm" {
  count                  = var.pse_count
  ami                    = element(var.ami_id, count.index)
  instance_type          = var.psevm_instance_type
  iam_instance_profile   = element(var.iam_instance_profile, count.index)
  vpc_security_group_ids = [element(var.security_group_id, count.index)]
  subnet_id              = element(var.pse_subnet_ids, count.index)
  key_name               = var.instance_key
  user_data_base64       = base64encode(element(var.user_data, count.index))

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = var.imdsv2_enabled ? "required" : "optional"
  }

  tags = merge(var.global_tags,
    { Name = "${var.name_prefix}-pse-vm-${count.index + 1}-${var.resource_tag}" }
  )
}


resource "aws_eip" "pse_eip" {
  count    = var.associate_public_ip_address ? var.pse_count : 0
  instance = aws_instance.pse_vm[count.index].id
  domain   = "vpc"

  tags = merge(var.global_tags,
    { Name = "${var.name_prefix}-eip-psevm-${count.index + 1}-${var.resource_tag}" }
  )
}

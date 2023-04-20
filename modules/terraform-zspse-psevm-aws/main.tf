################################################################################
# Retrieve the default AWS KMS key in the current region for EBS encryption
################################################################################
data "aws_ebs_default_kms_key" "current_kms_key" {
  count = var.encrypted_ebs_enabled ? 1 : 0
}

################################################################################
# Retrieve an alias for the KMS key for EBS encryption
################################################################################
data "aws_kms_alias" "current_kms_arn" {
  count = var.encrypted_ebs_enabled ? 1 : 0
  name  = data.aws_ebs_default_kms_key.current_kms_key[0].key_arn
}


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
  user_data              = base64encode(var.user_data)

  ebs_optimized = true

  root_block_device {
    delete_on_termination = true
    encrypted             = var.encrypted_ebs_enabled
    kms_key_id            = var.encrypted_ebs_enabled ? data.aws_kms_alias.current_kms_arn[0].target_key_arn : null
    volume_type           = var.ebs_volume_type
    tags = merge(var.global_tags,
      { Name = "${var.name_prefix}-pse-vm-${count.index + 1}-ebs-${var.resource_tag}" }
    )
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = var.imdsv2_enabled ? "required" : "optional"
  }

  tags = merge(var.global_tags,
    { Name = "${var.name_prefix}-pse-vm-${count.index + 1}-${var.resource_tag}" }
  )

  lifecycle {
    ignore_changes = [
      root_block_device[0].kms_key_id
    ]
  }
}


resource "aws_eip" "pse_eip" {
  count    = var.associate_public_ip_address ? var.pse_count : 0
  instance = aws_instance.pse_vm[count.index].id
  vpc      = true

  tags = merge(var.global_tags,
    { Name = "${var.name_prefix}-eip-psevm-${count.index + 1}-${var.resource_tag}" }
  )
}

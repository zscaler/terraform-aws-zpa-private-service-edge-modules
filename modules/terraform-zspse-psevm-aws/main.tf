################################################################################
# Locate Latest Amazon Linux 2 AMI for instance use
# Used only if use_zscaler_ami variable set to false
################################################################################
data "aws_ssm_parameter" "amazon_linux_latest" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}


################################################################################
# Locate Latest Service Edge AMI by product code
# Latest Software version and AMI ID in each region can be located here:
# https://aws.amazon.com/marketplace/server/configuration?productId=8ba43891-b39b-4200-9cc7-032845af4634&ref_=psb_cfg_continue
################################################################################
data "aws_ami" "service_edge" {
  most_recent = true

  filter {
    name   = "product-code"
    values = ["89m6h1zvds9p3zju6hvutudro"]
  }

  owners = ["aws-marketplace"]
}


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
  count                       = var.pse_count
  ami                         = var.use_zscaler_ami == true ? data.aws_ami.service_edge.id : data.aws_ssm_parameter.amazon_linux_latest.value
  instance_type               = var.psevm_instance_type
  iam_instance_profile        = element(var.iam_instance_profile, count.index)
  vpc_security_group_ids      = [element(var.security_group_id, count.index)]
  subnet_id                   = element(var.pse_subnet_ids, count.index)
  key_name                    = var.instance_key
  associate_public_ip_address = var.associate_public_ip_address
  user_data                   = base64encode(var.user_data)

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
}

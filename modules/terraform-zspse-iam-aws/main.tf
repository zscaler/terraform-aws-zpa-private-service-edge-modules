################################################################################
# Create IAM role and instance profile
################################################################################

################################################################################
# Define AssumeRole access for EC2
################################################################################
data "aws_iam_policy_document" "instance_assume_role_policy" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


################################################################################
# Create AC IAM Role and Host/Instance Profile
################################################################################
resource "aws_iam_role" "pse_node_iam_role" {
  count              = var.byo_iam == false ? var.iam_count : 0
  name               = var.iam_count > 1 ? "${var.name_prefix}-pse-${count.index + 1}-node-iam-role-${var.resource_tag}" : "${var.name_prefix}-pse_node_iam_role-${var.resource_tag}"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json

  tags = merge(var.global_tags)
}

# Assign AC IAM Role to Instance Profile for AC instance attachment
resource "aws_iam_instance_profile" "pse_host_profile" {
  count = var.byo_iam == false ? var.iam_count : 0
  name  = var.iam_count > 1 ? "${var.name_prefix}-pse-${count.index + 1}-host-profile-${var.resource_tag}" : "${var.name_prefix}-pse_host_profile-${var.resource_tag}"
  role  = aws_iam_role.pse_node_iam_role[count.index].name

  tags = merge(var.global_tags)
}

# Or use existing IAM Instance Profile if specified in byo_iam
data "aws_iam_instance_profile" "pse_host_profile_selected" {
  count = var.byo_iam == false ? length(aws_iam_instance_profile.pse_host_profile[*].id) : length(var.byo_iam_instance_profile_id)
  name  = var.byo_iam == false ? element(aws_iam_instance_profile.pse_host_profile[*].name, count.index) : element(var.byo_iam_instance_profile_id, count.index)
}


################################################################################
# IAM Policy for SSM Parameter Store (OAuth Token Registration)
################################################################################
data "aws_iam_policy_document" "pse_ssm_policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "ssm:PutParameter",
      "ssm:AddTagsToResource",
      "ssm:GetParameter",
      "ssm:DeleteParameter"
    ]
    resources = [
      "arn:aws:ssm:*:*:parameter/zpa/oauth-tokens/*"
    ]
  }
}

resource "aws_iam_role_policy" "pse_ssm_policy" {
  count  = var.byo_iam == false ? var.iam_count : 0
  name   = "${var.name_prefix}-pse-ssm-policy-${var.resource_tag}"
  role   = aws_iam_role.pse_node_iam_role[count.index].id
  policy = data.aws_iam_policy_document.pse_ssm_policy.json
}

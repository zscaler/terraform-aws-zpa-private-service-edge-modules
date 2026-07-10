################################################################################
# Create launch template for Service Edge autoscaling group instance creation. 
# Mgmt and service interface device indexes are swapped to support ASG + GWLB 
# instance association
################################################################################
resource "aws_launch_template" "pse_launch_template" {
  count         = 1
  name          = "${var.name_prefix}-pse-launch-template-${var.resource_tag}"
  image_id      = element(var.ami_id, count.index)
  instance_type = var.psevm_instance_type
  key_name      = var.instance_key
  user_data     = base64encode(var.user_data)

  iam_instance_profile {
    name = element(var.iam_instance_profile, count.index)
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.global_tags, { Name = "${var.name_prefix}-psevm-asg-${var.resource_tag}" })
  }

  tag_specifications {
    resource_type = "network-interface"
    tags          = merge(var.global_tags, { Name = "${var.name_prefix}-psevm-nic-asg-${var.resource_tag}" })
  }

  network_interfaces {
    description                 = "Interface for Service Edge traffic"
    device_index                = 0
    security_groups             = [element(var.security_group_id, count.index)]
    associate_public_ip_address = var.associate_public_ip_address
  }

  ebs_optimized = true

  block_device_mappings {
    device_name = var.ebs_block_device_name

    ebs {
      delete_on_termination = true
      encrypted             = var.encrypted_ebs_enabled
      volume_type           = var.ebs_volume_type
    }
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = var.imdsv2_enabled ? "required" : "optional"
  }


  lifecycle {
    create_before_destroy = true
  }
}


################################################################################
# Create Service Edge autoscaling group
################################################################################
resource "aws_autoscaling_group" "pse_asg" {
  name                      = "${var.name_prefix}-pse-asg-${var.resource_tag}"
  vpc_zone_identifier       = distinct(var.pse_subnet_ids)
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_type         = "EC2"
  health_check_grace_period = var.health_check_grace_period

  launch_template {
    id      = aws_launch_template.pse_launch_template[0].id
    version = var.launch_template_version
  }

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  dynamic "warm_pool" {
    for_each = var.warm_pool_enabled == true ? [var.warm_pool_enabled] : []
    content {
      pool_state                  = var.warm_pool_state
      min_size                    = var.warm_pool_min_size
      max_group_prepared_capacity = var.warm_pool_max_group_prepared_capacity
      instance_reuse_policy {
        reuse_on_scale_in = var.reuse_on_scale_in
      }
    }
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

################################################################################
# Create autoscaling group policy based on dynamic Target Tracking Scaling on 
# average CPU
################################################################################
resource "aws_autoscaling_policy" "pse_asg_target_tracking_policy" {
  name                   = "${var.name_prefix}-pse-asg-target-policy-${var.resource_tag}"
  autoscaling_group_name = aws_autoscaling_group.pse_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.target_tracking_metric
    }
    target_value = var.target_cpu_util_value
  }
}

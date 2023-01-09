# Zscaler Service Edge / AWS Autoscaling (Service Edge) Module

This module creates a AWS Launch Template, Autoscaling Group, and Policy resources needed to deploy Service Edge appliances.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.7, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.49.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.49.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.pse_asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_policy.pse_asg_target_tracking_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_launch_template.pse_launch_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_ami.service_edge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ebs_default_kms_key.current_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ebs_default_kms_key) | data source |
| [aws_kms_alias.current_kms_arn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_alias) | data source |
| [aws_ssm_parameter.amazon_linux_latest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | enable/disable public IP addresses on Service Edge instances. Setting this to true will result in the following: Dynamic Public IP address on the Service Edge VM Instance will be enabled; no EIP or NAT Gateway resources will be created; and the Service Edge Route Table default route next-hop will be set as the IGW | `bool` | `false` | no |
| <a name="input_ebs_volume_type"></a> [ebs\_volume\_type](#input\_ebs\_volume\_type) | (Optional) Type of volume. Valid values include standard, gp2, gp3, io1, io2, sc1, or st1. Defaults to gp3 | `string` | `"gp3"` | no |
| <a name="input_encrypted_ebs_enabled"></a> [encrypted\_ebs\_enabled](#input\_encrypted\_ebs\_enabled) | true/false whether to encrypt root block ebs with default AWS KMS key | `bool` | `true` | no |
| <a name="input_global_tags"></a> [global\_tags](#input\_global\_tags) | Populate any custom user defined tags from a map | `map(string)` | `{}` | no |
| <a name="input_health_check_grace_period"></a> [health\_check\_grace\_period](#input\_health\_check\_grace\_period) | The amount of time until EC2 Auto Scaling performs the first health check on new instances after they are put into service. Default is 5 minutes | `number` | `300` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | IAM instance profile ID assigned to Service Edge | `list(string)` | n/a | yes |
| <a name="input_imdsv2_enabled"></a> [imdsv2\_enabled](#input\_imdsv2\_enabled) | true/false whether to force IMDSv2 only for instance bring up | `bool` | `true` | no |
| <a name="input_instance_key"></a> [instance\_key](#input\_instance\_key) | SSH Key for instances | `string` | n/a | yes |
| <a name="input_launch_template_version"></a> [launch\_template\_version](#input\_launch\_template\_version) | Launch template version. Can be version number, `$Latest` or `$Default` | `string` | `"$Latest"` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | Maxinum number of Service Edges to maintain in Autoscaling group | `number` | `4` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | Mininum number of Service Edges to maintain in Autoscaling group | `number` | `2` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix to associate to all the Service Edge module resources | `string` | `null` | no |
| <a name="input_pse_subnet_ids"></a> [pse\_subnet\_ids](#input\_pse\_subnet\_ids) | Service Edge EC2 Instance subnet IDs list | `list(string)` | n/a | yes |
| <a name="input_psevm_instance_type"></a> [psevm\_instance\_type](#input\_psevm\_instance\_type) | Service Edge Instance Type | `string` | `"m5.large"` | no |
| <a name="input_resource_tag"></a> [resource\_tag](#input\_resource\_tag) | A tag to associate to all the Service Edge module resources | `string` | `null` | no |
| <a name="input_reuse_on_scale_in"></a> [reuse\_on\_scale\_in](#input\_reuse\_on\_scale\_in) | Specifies whether instances in the Auto Scaling group can be returned to the warm pool on scale in. | `bool` | `"false"` | no |
| <a name="input_security_group_id"></a> [security\_group\_id](#input\_security\_group\_id) | Service Edge EC2 Instance management subnet id | `list(string)` | n/a | yes |
| <a name="input_target_cpu_util_value"></a> [target\_cpu\_util\_value](#input\_target\_cpu\_util\_value) | Target value number for autoscaling policy CPU utilization target tracking. ie: trigger a scale in/out to keep average CPU Utliization percentage across all instances at/under this number | `number` | `50` | no |
| <a name="input_target_tracking_metric"></a> [target\_tracking\_metric](#input\_target\_tracking\_metric) | The AWS ASG pre-defined target tracking metric type. Service Edge recommends ASGAverageCPUUtilization | `string` | `"ASGAverageCPUUtilization"` | no |
| <a name="input_use_zscaler_ami"></a> [use\_zscaler\_ami](#input\_use\_zscaler\_ami) | By default, Service Edge will deploy via the Zscaler Latest AMI. Setting this to false will deploy the latest Amazon Linux 2 AMI instead | `bool` | `true` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | App Init data | `string` | n/a | yes |
| <a name="input_warm_pool_enabled"></a> [warm\_pool\_enabled](#input\_warm\_pool\_enabled) | If set to true, add a warm pool to the specified Auto Scaling group. See [warm\_pool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#warm_pool). | `bool` | `"false"` | no |
| <a name="input_warm_pool_max_group_prepared_capacity"></a> [warm\_pool\_max\_group\_prepared\_capacity](#input\_warm\_pool\_max\_group\_prepared\_capacity) | Specifies the total maximum number of instances that are allowed to be in the warm pool or in any state except Terminated for the Auto Scaling group. Ignored when 'warm\_pool\_enabled' is false | `number` | `null` | no |
| <a name="input_warm_pool_min_size"></a> [warm\_pool\_min\_size](#input\_warm\_pool\_min\_size) | Specifies the minimum number of instances to maintain in the warm pool. This helps you to ensure that there is always a certain number of warmed instances available to handle traffic spikes. Ignored when 'warm\_pool\_enabled' is false | `number` | `null` | no |
| <a name="input_warm_pool_state"></a> [warm\_pool\_state](#input\_warm\_pool\_state) | Sets the instance state to transition to after the lifecycle hooks finish. Valid values are: Stopped (default), Running or Hibernated. Ignored when 'warm\_pool\_enabled' is false | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_availability_zone"></a> [availability\_zone](#output\_availability\_zone) | Auto Scaling Group Availability Zones Output |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

# Zscaler Service Edge / AWS Security Groups Module

This module creates Security Rules and Groups resources required for successful Service Edge deployments. As part of Zscaler provided deployment templates most resources have conditional create options leveraged "byo" variables should a customer want to leverage the module outputs with data reference to resources that may already exist in their AWS environment.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.7, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.94.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.94.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_security_group.pse_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.pse_node_ingress_https_tcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.pse_node_ingress_https_udp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.pse_node_ingress_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group.pse_sg_selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |
| [aws_vpc.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | enable/disable public IP addresses on Service Edge instances. For Security Group Module, this variable determines whether the inbound HTTPS rules permit source VPC if private or source ANY (Internet) if public | `bool` | `false` | no |
| <a name="input_byo_security_group"></a> [byo\_security\_group](#input\_byo\_security\_group) | Bring your own Security Group for Service Edge. Setting this variable to true will effectively instruct this module to not create any resources and only reference data resources from values provided in byo\_mgmt\_security\_group\_id and byo\_service\_security\_group\_id | `bool` | `false` | no |
| <a name="input_byo_security_group_id"></a> [byo\_security\_group\_id](#input\_byo\_security\_group\_id) | Management Security Group ID for Service Edge association | `list(string)` | `null` | no |
| <a name="input_global_tags"></a> [global\_tags](#input\_global\_tags) | Populate any custom user defined tags from a map | `map(string)` | `{}` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix to associate to all the Service Edge Security Group module resources | `string` | `null` | no |
| <a name="input_resource_tag"></a> [resource\_tag](#input\_resource\_tag) | A tag to associate to all the Service Edge Security Group module resources | `string` | `null` | no |
| <a name="input_sg_count"></a> [sg\_count](#input\_sg\_count) | Default number of security groups to create | `number` | `1` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | Service Edge VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_pse_security_group_arn"></a> [pse\_security\_group\_arn](#output\_pse\_security\_group\_arn) | Service Edge Security Group ARN |
| <a name="output_pse_security_group_id"></a> [pse\_security\_group\_id](#output\_pse\_security\_group\_id) | Service Edge Security Group ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

# Zscaler Service Edge / AWS Network Infrastructure Module

This module has multi-purpose use and is leveraged by all other Zscaler Service Edge child modules in some capacity. All network infrastructure resources pertaining to connectivity dependencies for a successful Service Edge deployment in a private subnet are referenced here. Full list of resources can be found below, but in general this module will handle all VPC, IGW, Subnets, NAT Gateways, Elastic IP Addresses, and Route Table creations to build out a resilient AWS network architecture. Most resources also have "conditional create" capabilities where, by default, they will all be created unless instructed not to with various "byo" variables. Use cases are documented in more detail in each description in variables.tf as well as the terraform.tfvars example file for all non-base deployment types.

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
| [aws_eip.eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.ngw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route_table.pse_rt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public_rt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.pse_rt_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public_rt_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.pse_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_internet_gateway.igw_selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/internet_gateway) | data source |
| [aws_nat_gateway.ngw_selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/nat_gateway) | data source |
| [aws_subnet.pse_subnet_selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_vpc.vpc_selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | enable/disable public IP addresses on Service Edge instances. Setting this to true will result in the following: Dynamic Public IP address on the Service Edge VM Instance will be enabled; no EIP or NAT Gateway resources will be created; and the Service Edge Route Table default route next-hop will be set as the IGW | `bool` | `false` | no |
| <a name="input_az_count"></a> [az\_count](#input\_az\_count) | Default number of subnets to create based on availability zone input | `number` | `2` | no |
| <a name="input_bastion_deploy"></a> [bastion\_deploy](#input\_bastion\_deploy) | Bastion deployments in a public subnet only exists in greenfield example templates.  This variable boolean is used for production Service Edge deployments with a public IP address associated to not create unneccesary public network resources. Default is false | `bool` | `false` | no |
| <a name="input_byo_igw"></a> [byo\_igw](#input\_byo\_igw) | Bring your own AWS VPC for Service Edge | `bool` | `false` | no |
| <a name="input_byo_igw_id"></a> [byo\_igw\_id](#input\_byo\_igw\_id) | User provided existing AWS Internet Gateway ID | `string` | `null` | no |
| <a name="input_byo_ngw"></a> [byo\_ngw](#input\_byo\_ngw) | Bring your own AWS NAT Gateway(s) Service Edge | `bool` | `false` | no |
| <a name="input_byo_ngw_ids"></a> [byo\_ngw\_ids](#input\_byo\_ngw\_ids) | User provided existing AWS NAT Gateway IDs | `list(string)` | `null` | no |
| <a name="input_byo_subnet_ids"></a> [byo\_subnet\_ids](#input\_byo\_subnet\_ids) | User provided existing AWS Subnet IDs | `list(string)` | `null` | no |
| <a name="input_byo_subnets"></a> [byo\_subnets](#input\_byo\_subnets) | Bring your own AWS Subnets for Service Edge | `bool` | `false` | no |
| <a name="input_byo_vpc"></a> [byo\_vpc](#input\_byo\_vpc) | Bring your own AWS VPC for Service Edge | `bool` | `false` | no |
| <a name="input_byo_vpc_id"></a> [byo\_vpc\_id](#input\_byo\_vpc\_id) | User provided existing AWS VPC ID | `string` | `null` | no |
| <a name="input_global_tags"></a> [global\_tags](#input\_global\_tags) | Populate any custom user defined tags from a map | `map(string)` | `{}` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix to associate to all the network module resources | `string` | `null` | no |
| <a name="input_pse_subnets"></a> [pse\_subnets](#input\_pse\_subnets) | Service Edge Subnets to create in VPC. This is only required if you want to override the default subnets that this code creates via vpc\_cidr variable. | `list(string)` | `null` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | Public/NAT GW Subnets to create in VPC. This is only required if you want to override the default subnets that this code creates via vpc\_cidr variable. | `list(string)` | `null` | no |
| <a name="input_resource_tag"></a> [resource\_tag](#input\_resource\_tag) | A tag to associate to all the network module resources | `string` | `null` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC IP CIDR Range. All subnet resources that might get created (public / Service Edge) are derived from this /16 CIDR. If you require creating a VPC smaller than /16, you may need to explicitly define all other subnets via public\_subnets and pse\_subnets variables | `string` | `"10.1.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nat_gateway_ips"></a> [nat\_gateway\_ips](#output\_nat\_gateway\_ips) | NAT Gateway Public IPs |
| <a name="output_pse_subnet_ids"></a> [pse\_subnet\_ids](#output\_pse\_subnet\_ids) | Service Edge Subnet IDs |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | Public Subnet IDs |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID Selected |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

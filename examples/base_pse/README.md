# Zscaler "base_pse" deployment type

This deployment type is intended for greenfield/pov/lab purposes. It will deploy a fully functioning sandbox environment in a new VPC. Full set of resources provisioned are listed below, but this will effectively create all network infrastructure dependencies for an AWS environment. Everything from "Base" deployment type (Creates 1 new VPC with one or more public subnets; one IGW; one or more NAT Gateways; one Bastion Host in the public subnet assigned an Elastic IP and routing to the IGW; and generates a local key pair .pem file for ssh access)<br>

Additionally: Creates Private Service Edge private subnets and Private Service Edge VMs egressing through the NAT Gateways in their respective availability zones. The preferred deployment configuration are Private Service Edges in a private subnet. If you desire to deploy to a public subnet, setting variable "associate_public_ip_address" to true will enable the automatic dynamic public IPv4 address assignment and set the Route Table to default next-hop through IGW.<br> 

We are leveraging the [Zscaler ZPA Provider](https://github.com/zscaler/terraform-provider-zpa) to connect to your ZPA Admin console and provision a new Private Service Edge Group + Provisioning Key. You can still run this template if deploying to an existing Private Service Edge Group rather than creating a new one, but using the conditional create functionality from variable byo_provisioning_key and supplying to name of your provisioning key to variable byo_provisioning_key_name. In either deployment, this is fed directly into the userdata for bootstrapping.<br>


## How to deploy:

### Option 1 (guided):
Optional: Edit the terraform.tfvars file under your desired deployment type (ie: base_pse) to setup your Private Service Edge Group (Details are documented inside the file)
From the examples directory, run the zspse bash script that walks to all required inputs.
- ./zspse up
- enter "greenfield"
- enter "base_pse"
- follow the remainder of the authentication and configuration input prompts.
- script will detect client operating system and download/run a specific version of terraform in a temporary bin directory
- inputs will be validated and terraform init/apply will automatically exectute.
- verify all resources that will be created/modified and enter "yes" to confirm

### Option 2 (manual):
Modify/populate any required variable input values in base_pse/terraform.tfvars file and save.

From base_pse directory execute:
- terraform init
- terraform apply

## How to destroy:

### Option 1 (guided):
From the examples directory, run the zspse bash script that walks to all required inputs.
- ./zspse destroy

### Option 2 (manual):
From base_pse directory execute:
- terraform destroy

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.7, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.94.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.5.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0.0 |
| <a name="requirement_zpa"></a> [zpa](#requirement\_zpa) | ~> 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.94.0 |
| <a name="provider_local"></a> [local](#provider\_local) | ~> 2.5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.6.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | ~> 4.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bastion"></a> [bastion](#module\_bastion) | ../../modules/terraform-zspse-bastion-aws | n/a |
| <a name="module_network"></a> [network](#module\_network) | ../../modules/terraform-zspse-network-aws | n/a |
| <a name="module_pse_iam"></a> [pse\_iam](#module\_pse\_iam) | ../../modules/terraform-zspse-iam-aws | n/a |
| <a name="module_pse_sg"></a> [pse\_sg](#module\_pse\_sg) | ../../modules/terraform-zspse-sg-aws | n/a |
| <a name="module_pse_vm"></a> [pse\_vm](#module\_pse\_vm) | ../../modules/terraform-zspse-psevm-aws | n/a |
| <a name="module_zpa_provisioning_key"></a> [zpa\_provisioning\_key](#module\_zpa\_provisioning\_key) | ../../modules/terraform-zpa-provisioning-key | n/a |
| <a name="module_zpa_service_edge_group"></a> [zpa\_service\_edge\_group](#module\_zpa\_service\_edge\_group) | ../../modules/terraform-zpa-service-edge-group | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_key_pair.deployer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [local_file.private_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.rhel9_user_data_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.testbed](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.user_data_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_private_key.key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_ami.rhel_9_latest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.service_edge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | AMI ID(s) to be used for deploying Private Service Edge appliances. Ideally all VMs should be on the same AMI ID as templates always pull the latest from AWS Marketplace. This variable is provided if a customer desires to override/retain an old ami for existing deployments rather than upgrading and forcing a replacement. It is also inputted as a list to facilitate if a customer desired to manually upgrade select PSEs deployed based on the pse\_count index | `list(string)` | <pre>[<br/>  ""<br/>]</pre> | no |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | enable/disable public IP addresses on Service Edge instances. Setting this to true will result in the following: Dynamic Public IP address on the Service Edge VM Instance will be enabled; no EIP or NAT Gateway resources will be created; and the Service Edge Route Table default route next-hop will be set as the IGW | `bool` | `false` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region. | `string` | `"us-west-2"` | no |
| <a name="input_az_count"></a> [az\_count](#input\_az\_count) | Default number of subnets to create based on availability zone input | `number` | `2` | no |
| <a name="input_bastion_deploy"></a> [bastion\_deploy](#input\_bastion\_deploy) | Bastion deployments in a public subnet only exists in greenfield example templates.  This variable boolean is used for production Service Edge deployments with a public IP address associated to not create unneccesary public network resources. Default is true | `bool` | `true` | no |
| <a name="input_bastion_nsg_source_prefix"></a> [bastion\_nsg\_source\_prefix](#input\_bastion\_nsg\_source\_prefix) | CIDR blocks of trusted networks for bastion host ssh access | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_byo_provisioning_key"></a> [byo\_provisioning\_key](#input\_byo\_provisioning\_key) | Bring your own Service Edge Provisioning Key. Setting this variable to true will effectively instruct this module to not create any resources and only reference data resources from values provided in byo\_provisioning\_key\_name | `bool` | `false` | no |
| <a name="input_byo_provisioning_key_name"></a> [byo\_provisioning\_key\_name](#input\_byo\_provisioning\_key\_name) | Existing Service Edge Provisioning Key name | `string` | `null` | no |
| <a name="input_enrollment_cert"></a> [enrollment\_cert](#input\_enrollment\_cert) | Get name of ZPA enrollment cert to be used for Service Edge provisioning | `string` | `"Service Edge"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | The name prefix for all your resources | `string` | `"zsdemo"` | no |
| <a name="input_owner_tag"></a> [owner\_tag](#input\_owner\_tag) | populate custom owner tag attribute | `string` | `"zspse-admin"` | no |
| <a name="input_provisioning_key_association_type"></a> [provisioning\_key\_association\_type](#input\_provisioning\_key\_association\_type) | Specifies the provisioning key type for Service Edges or ZPA Private Service Edges. The supported value is SERVICE\_EDGE\_GRP | `string` | `"SERVICE_EDGE_GRP"` | no |
| <a name="input_provisioning_key_enabled"></a> [provisioning\_key\_enabled](#input\_provisioning\_key\_enabled) | Whether the provisioning key is enabled or not. Default: true | `bool` | `true` | no |
| <a name="input_provisioning_key_max_usage"></a> [provisioning\_key\_max\_usage](#input\_provisioning\_key\_max\_usage) | The maximum number of instances where this provisioning key can be used for enrolling an App Connector or Service Edge | `number` | `10` | no |
| <a name="input_provisioning_key_name"></a> [provisioning\_key\_name](#input\_provisioning\_key\_name) | Name of the provisioning key | `string` | `""` | no |
| <a name="input_pse_count"></a> [pse\_count](#input\_pse\_count) | Default number of Service Edge appliances to create | `number` | `2` | no |
| <a name="input_pse_group_country_code"></a> [pse\_group\_country\_code](#input\_pse\_group\_country\_code) | Optional: Country code of this Service Edge Group. example 'US' | `string` | `"US"` | no |
| <a name="input_pse_group_description"></a> [pse\_group\_description](#input\_pse\_group\_description) | Optional: Description of the Service Edge Group | `string` | `""` | no |
| <a name="input_pse_group_enabled"></a> [pse\_group\_enabled](#input\_pse\_group\_enabled) | Whether this Service Edge Group is enabled or not | `bool` | `true` | no |
| <a name="input_pse_group_latitude"></a> [pse\_group\_latitude](#input\_pse\_group\_latitude) | Latitude of the Service Edge Group. Integer or decimal. With values in the range of -90 to 90 | `string` | `"37.33874"` | no |
| <a name="input_pse_group_location"></a> [pse\_group\_location](#input\_pse\_group\_location) | location of the Service Edge Group in City, State, Country format. example: 'San Jose, CA, USA' | `string` | `"San Jose, CA, USA"` | no |
| <a name="input_pse_group_longitude"></a> [pse\_group\_longitude](#input\_pse\_group\_longitude) | Longitude of the Service Edge Group. Integer or decimal. With values in the range of -90 to 90 | `string` | `"-121.8852525"` | no |
| <a name="input_pse_group_name"></a> [pse\_group\_name](#input\_pse\_group\_name) | Name of the Service Edge Group | `string` | `""` | no |
| <a name="input_pse_group_override_version_profile"></a> [pse\_group\_override\_version\_profile](#input\_pse\_group\_override\_version\_profile) | Optional: Whether the default version profile of the Service Edge Group is applied or overridden. Default: false | `bool` | `false` | no |
| <a name="input_pse_group_upgrade_day"></a> [pse\_group\_upgrade\_day](#input\_pse\_group\_upgrade\_day) | Optional: Service Edges in this group will attempt to update to a newer version of the software during this specified day. Default value: SUNDAY. List of valid days (i.e., SUNDAY, MONDAY, etc) | `string` | `"SUNDAY"` | no |
| <a name="input_pse_group_upgrade_time_in_secs"></a> [pse\_group\_upgrade\_time\_in\_secs](#input\_pse\_group\_upgrade\_time\_in\_secs) | Optional: Service Edges in this group will attempt to update to a newer version of the software during this specified time. Default value: 66600. Integer in seconds (i.e., 66600). The integer should be greater than or equal to 0 and less than 86400, in 15 minute intervals | `string` | `"66600"` | no |
| <a name="input_pse_group_version_profile_id"></a> [pse\_group\_version\_profile\_id](#input\_pse\_group\_version\_profile\_id) | Optional: ID of the version profile. To learn more, see Version Profile Use Cases. https://help.zscaler.com/zpa/configuring-version-profile | `string` | `"2"` | no |
| <a name="input_pse_is_public"></a> [pse\_is\_public](#input\_pse\_is\_public) | (Optional) Enable or disable public access for the Service Edge Group. Default value is false | `bool` | `false` | no |
| <a name="input_pse_subnets"></a> [pse\_subnets](#input\_pse\_subnets) | Service Edge Subnets to create in VPC. This is only required if you want to override the default subnets that this code creates via vpc\_cidr variable. | `list(string)` | `null` | no |
| <a name="input_psevm_instance_type"></a> [psevm\_instance\_type](#input\_psevm\_instance\_type) | Service Edge Instance Type | `string` | `"m5.large"` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | Public/NAT GW Subnets to create in VPC. This is only required if you want to override the default subnets that this code creates via vpc\_cidr variable. | `list(string)` | `null` | no |
| <a name="input_reuse_iam"></a> [reuse\_iam](#input\_reuse\_iam) | Specifies whether the SG module should create 1:1 IAM per instance or 1 IAM for all instances | `bool` | `false` | no |
| <a name="input_reuse_security_group"></a> [reuse\_security\_group](#input\_reuse\_security\_group) | Specifies whether the SG module should create 1:1 security groups per instance or 1 security group for all instances | `bool` | `false` | no |
| <a name="input_tls_key_algorithm"></a> [tls\_key\_algorithm](#input\_tls\_key\_algorithm) | algorithm for tls\_private\_key resource | `string` | `"RSA"` | no |
| <a name="input_use_zscaler_ami"></a> [use\_zscaler\_ami](#input\_use\_zscaler\_ami) | By default, Service Edge will deploy via the Zscaler Latest AMI. Setting this to false will deploy the latest Amazon Linux 2 AMI instead | `bool` | `true` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC IP CIDR Range. All subnet resources that might get created (public / service edge) are derived from this /16 CIDR. If you require creating a VPC smaller than /16, you may need to explicitly define all other subnets via public\_subnets and pse\_subnets variables | `string` | `"10.1.0.0/16"` | no |
| <a name="input_zpa_trusted_network_name"></a> [zpa\_trusted\_network\_name](#input\_zpa\_trusted\_network\_name) | To query trusted network that are associated with a specific Zscaler cloud, it is required to append the cloud name to the name of the trusted network. For more details refer to docs: https://registry.terraform.io/providers/zscaler/zpa/latest/docs/data-sources/zpa_trusted_network | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_testbedconfig"></a> [testbedconfig](#output\_testbedconfig) | AWS Testbed results |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

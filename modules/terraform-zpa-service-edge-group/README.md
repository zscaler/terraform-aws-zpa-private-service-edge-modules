# Zscaler ZPA Provider Service Edge Group Module

This module provides the resources necessary to create a new ZPA Service Edge Group to be used with Service Edge appliance deployment and provisioining. This module is not intended to be used for any existing ZPA Service Edge Groups created outside of Terraform.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.7, < 2.0.0 |
| <a name="requirement_zpa"></a> [zpa](#requirement\_zpa) | ~> 3.31.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_zpa"></a> [zpa](#provider\_zpa) | ~> 3.31.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [zpa_service_edge_group.service_edge_group](https://registry.terraform.io/providers/zscaler/zpa/latest/docs/resources/service_edge_group) | resource |
| [zpa_trusted_network.zpa_trusted_network](https://registry.terraform.io/providers/zscaler/zpa/latest/docs/data-sources/trusted_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_pse_group_country_code"></a> [pse\_group\_country\_code](#input\_pse\_group\_country\_code) | Optional: Country code of this Private Service Edge Group. example 'US' | `string` | `""` | no |
| <a name="input_pse_group_description"></a> [pse\_group\_description](#input\_pse\_group\_description) | Optional: Description of the Private Service Edge Group | `string` | `""` | no |
| <a name="input_pse_group_enabled"></a> [pse\_group\_enabled](#input\_pse\_group\_enabled) | Whether this Private Service Edge Group is enabled or not | `bool` | `true` | no |
| <a name="input_pse_group_latitude"></a> [pse\_group\_latitude](#input\_pse\_group\_latitude) | Latitude of the Private Service Edge Group. Integer or decimal. With values in the range of -90 to 90 | `string` | n/a | yes |
| <a name="input_pse_group_location"></a> [pse\_group\_location](#input\_pse\_group\_location) | location of the Private Service Edge Group in City, State, Country format. example: 'San Jose, CA, USA' | `string` | n/a | yes |
| <a name="input_pse_group_longitude"></a> [pse\_group\_longitude](#input\_pse\_group\_longitude) | Longitude of the Private Service Edge Group. Integer or decimal. With values in the range of -90 to 90 | `string` | n/a | yes |
| <a name="input_pse_group_name"></a> [pse\_group\_name](#input\_pse\_group\_name) | Name of the Private Service Edge Group | `string` | n/a | yes |
| <a name="input_pse_group_override_version_profile"></a> [pse\_group\_override\_version\_profile](#input\_pse\_group\_override\_version\_profile) | Optional: Whether the default version profile of the Private Service Edge Group is applied or overridden. Default: false | `bool` | `false` | no |
| <a name="input_pse_group_upgrade_day"></a> [pse\_group\_upgrade\_day](#input\_pse\_group\_upgrade\_day) | Optional: Private Service Edges in this group will attempt to update to a newer version of the software during this specified day. Default value: SUNDAY. List of valid days (i.e., SUNDAY, MONDAY, etc) | `string` | `"SUNDAY"` | no |
| <a name="input_pse_group_upgrade_time_in_secs"></a> [pse\_group\_upgrade\_time\_in\_secs](#input\_pse\_group\_upgrade\_time\_in\_secs) | Optional: Private Service Edges in this group will attempt to update to a newer version of the software during this specified time. Default value: 66600. Integer in seconds (i.e., 66600). The integer should be greater than or equal to 0 and less than 86400, in 15 minute intervals | `string` | `"66600"` | no |
| <a name="input_pse_group_version_profile_id"></a> [pse\_group\_version\_profile\_id](#input\_pse\_group\_version\_profile\_id) | Optional: ID of the version profile. To learn more, see Version Profile Use Cases. https://help.zscaler.com/zpa/configuring-version-profile | `string` | `"2"` | no |
| <a name="input_pse_is_public"></a> [pse\_is\_public](#input\_pse\_is\_public) | (Optional) Enable or disable public access for the Service Edge Group. Default value is false | `bool` | `false` | no |
| <a name="input_zpa_trusted_network_name"></a> [zpa\_trusted\_network\_name](#input\_zpa\_trusted\_network\_name) | To query trusted network that are associated with a specific Zscaler cloud, it is required to append the cloud name to the name of the trusted network. For more details refer to docs: https://registry.terraform.io/providers/zscaler/zpa/latest/docs/data-sources/zpa_trusted_network | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_edge_group_id"></a> [service\_edge\_group\_id](#output\_service\_edge\_group\_id) | Service Edge Group IP Output |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

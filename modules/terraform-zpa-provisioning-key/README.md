# Zscaler ZPA Provider Service Edge Provisioning Key Module

This module provides the resources necessary to create a new ZPA Service Edge Provisioning Key to be used with Service Edge appliance deployment and provisioining.

There is a "BYO" option where you can conditionally create new or reference an existing provisioning key by name.

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
| [zpa_provisioning_key.provisioning_key](https://registry.terraform.io/providers/zscaler/zpa/latest/docs/resources/provisioning_key) | resource |
| [zpa_enrollment_cert.connector_cert](https://registry.terraform.io/providers/zscaler/zpa/latest/docs/data-sources/enrollment_cert) | data source |
| [zpa_provisioning_key.provisioning_key_selected](https://registry.terraform.io/providers/zscaler/zpa/latest/docs/data-sources/provisioning_key) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_byo_provisioning_key"></a> [byo\_provisioning\_key](#input\_byo\_provisioning\_key) | Bring your own Service Edge Provisioning Key. Setting this variable to true will effectively instruct this module to not create any resources and only reference data resources from values provided in byo\_provisioning\_key\_name | `bool` | `false` | no |
| <a name="input_byo_provisioning_key_name"></a> [byo\_provisioning\_key\_name](#input\_byo\_provisioning\_key\_name) | Existing Service Edge Provisioning Key name | `string` | `null` | no |
| <a name="input_enrollment_cert"></a> [enrollment\_cert](#input\_enrollment\_cert) | Get name of ZPA enrollment cert to be used for Service Edge provisioning | `string` | `"Service Edge"` | no |
| <a name="input_provisioning_key_association_type"></a> [provisioning\_key\_association\_type](#input\_provisioning\_key\_association\_type) | Specifies the provisioning key type for Service Edges or ZPA Private Service Edges. The supported value is SERVICE\_EDGE\_GRP | `string` | `"SERVICE_EDGE_GRP"` | no |
| <a name="input_provisioning_key_enabled"></a> [provisioning\_key\_enabled](#input\_provisioning\_key\_enabled) | Whether the provisioning key is enabled or not. Default: true | `bool` | `true` | no |
| <a name="input_provisioning_key_max_usage"></a> [provisioning\_key\_max\_usage](#input\_provisioning\_key\_max\_usage) | The maximum number of instances where this provisioning key can be used for enrolling an Service Edge or Service Edge | `number` | n/a | yes |
| <a name="input_provisioning_key_name"></a> [provisioning\_key\_name](#input\_provisioning\_key\_name) | Name of the provisioning key | `string` | n/a | yes |
| <a name="input_pse_group_id"></a> [pse\_group\_id](#input\_pse\_group\_id) | ID of Service Edge Group from zpa-service-edge-group module | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_provisioning_key"></a> [provisioning\_key](#output\_provisioning\_key) | ZPA Provisioning Key Output |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

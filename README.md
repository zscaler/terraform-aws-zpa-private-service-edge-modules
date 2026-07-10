![GitHub release (latest by date)](https://img.shields.io/github/v/release/zscaler/terraform-aws-zpa-private-service-edge-modules?style=flat-square)
![GitHub](https://img.shields.io/github/license/zscaler/terraform-aws-zpa-private-service-edge-modules?style=flat-square)
![GitHub pull requests](https://img.shields.io/github/issues-pr/zscaler/terraform-aws-zpa-private-service-edge-modules?style=flat-square)
![Terraform registry downloads total](https://img.shields.io/badge/dynamic/json?color=green&label=downloads%20total&query=data.attributes.total&url=https%3A%2F%2Fregistry.terraform.io%2Fv2%2Fmodules%2Fzscaler%2Fzpa-private-service-edge-modules%2Faws%2Fdownloads%2Fsummary&style=flat-square)
![Terraform registry download month](https://img.shields.io/badge/dynamic/json?color=green&label=downloads%20this%20month&query=data.attributes.month&url=https%3A%2F%2Fregistry.terraform.io%2Fv2%2Fmodules%2Fzscaler%2Fzpa-private-service-edge-modules%2Faws%2Fdownloads%2Fsummary&style=flat-square)
[![Zscaler Community](https://img.shields.io/badge/zscaler-community-blue)](https://community.zscaler.com/)


Zscaler Service Edge AWS Terraform Modules
===========================================

## Support Disclaimer

-> **Disclaimer:** Please refer to our [General Support Statement](docs/guides/support.md) before proceeding with the use of this provider.

## Description
This repository contains various modules and deployment configurations that can be used to deploy Zscaler Service Edge appliances to securely connect to workloads within Amazon Web Services (AWS) via the Zscaler Zero Trust Exchange. The examples directory contains complete automation scripts for both greenfield/POV and brownfield/production use.

These deployment templates are intended to be fully functional and self service for both greenfield/pov as well as production use. All modules may also be utilized as design recommendation based on Zscaler's Official [Zero Trust Access to Private Apps in AWS with ZPA](https://www.zscaler.com/resources/reference-architecture/zero-trust-with-zpa.pdf).

## Service Edge Onboarding Methods

This module supports **two** onboarding methods for enrolling Private Service Edges, selectable via the `onboarding_method` variable:

| Method | `onboarding_method` | Status | Summary |
|--------|---------------------|--------|---------|
| **OAuth2 User Code** | `"oauth"` | **Default (recommended)** | Service Edges enroll automatically via OAuth2 user codes. No provisioning key is required. |
| **Provisioning Key** | `"provisioning_key"` | Secondary (still fully supported) | The legacy flow. A provisioning key is created (or brought via `byo_provisioning_key`) and injected into each VM's `user_data`. |

Both methods remain fully supported. OAuth2 is the default because it removes the need to pre-create and distribute provisioning keys, but you can opt back into the provisioning key flow at any time by setting `onboarding_method = "provisioning_key"`.

### OAuth2 User Code flow (default)

1. Terraform provisions the SSM parameters and the Service Edge VM(s)/Auto Scaling Group.
2. Each Service Edge boots, generates its OAuth2 user code (written to `/etc/issue` on the VM), and publishes the code to **AWS SSM Parameter Store**.
3. Terraform polls SSM Parameter Store until every expected user code is available.
4. Terraform creates the Service Edge Group, passing the collected user codes.
5. Private Service Edges are enrolled via the ZPA OAuth2 API.

The token relay uses AWS SSM Parameter Store (not SSH). Instances are granted the minimal `ssm:PutParameter` / `ssm:GetParameter` permissions through the IAM module. By default the module creates SSM parameters under a generated prefix; set `byo_ssm_parameter_name` to use your own prefix or pre-created parameters.

For Auto Scaling Group examples (`base_pse_asg`, `pse_asg`), Terraform discovers the ASG instances dynamically and reads back each instance's OAuth token from SSM before creating the Service Edge Group.

### Provisioning Key flow (secondary)

Set `onboarding_method = "provisioning_key"` to use the legacy flow. In this mode the ZPA provider creates a provisioning key (or reuses an existing one via `byo_provisioning_key` / `byo_provisioning_key_name`), and the key is written into each VM's `user_data`. SSM Parameter Store is not used in this mode. See the `terraform.tfvars` in each example for the full list of provisioning key variables.

> This module requires the ZPA Terraform provider `>= 4.4.0` for OAuth2 user-code onboarding.

## Prerequisites

Our Deployment scripts are leveraging Terraform v1.1.9 that includes full binary and provider support for MacOS M1 chips, but any Terraform version 0.13.7 should be generally supported.

- provider registry.terraform.io/hashicorp/aws v5.94.x
- provider registry.terraform.io/hashicorp/random v3.6.x
- provider registry.terraform.io/hashicorp/local v2.5.x
- provider registry.terraform.io/hashicorp/null v3.2.x
- provider registry.terraform.io/providers/hashicorp/tls v4.0.x
- provider registry.terraform.io/providers/hashicorp/time v0.9.x
- provider registry.terraform.io/providers/hashicorp/external v2.3.x (Auto Scaling Group examples)
- provider registry.terraform.io/providers/zscaler/zpa v4.4.x or later (required for OAuth2 onboarding)

### AWS requirements
1. A valid AWS account
2. AWS ACCESS KEY ID
3. AWS SECRET ACCESS KEY
4. AWS Region (E.g. us-west-2)
5. Subscribe and accept terms of using Amazon Linux 2 AMI (for base deployments with workloads + bastion) at [this link](https://aws.amazon.com/marketplace/pp/prodview-zc4x2k7vt6rpu)
6. Subscribe and accept terms of using Zscaler Service Edge image at [this link](https://aws.amazon.com/marketplace/pp/prodview-epy3md7fcvk4g)

### Zscaler requirements
This module leverages the Zscaler Private Access [ZPA Terraform Provider](https://registry.terraform.io/providers/zscaler/zpa/latest/docs) for the automated onboarding process. Before proceeding make sure you have the following pre-requistes ready.

## Legacy ZPA API Authentication Framework

1. A valid Zscaler Private Access subscription and portal access
2. Zscaler ZPA API Keys. Details on how to find and generate ZPA API keys can be located [here](https://registry.terraform.io/providers/zscaler/zpa/latest/docs#legacy-api-framework)
- `zpa_client_id`
- `zpa_client_secret`
- `zpa_customer_id`
- `zpa_cloud` - This authentication parameter is optional and only required if authenticating to a non-production cloud i.e `BETA`, `GOV`, `GOVUS`, `ZPATWO`
- `use_legacy_client` - This parameter MUST be set to `true` if your tenant is NOT migrated to Zidentity.

```hcl
provider "zpa" {
  zpa_client_id            = "zpa_client_id" # pragma: allowlist secret
  zpa_client_secret        = "zpa_client_secret" # pragma: allowlist secret
  zpa_customer_id          = "zpa_client_secret" # pragma: allowlist secret
  zpa_cloud                = "zpa_cloud" # pragma: allowlist secret
  use_legacy_client        = "true" # pragma: allowlist secret
}
```

3. (Optional) With the default `oauth` onboarding method no provisioning key is required. If you set `onboarding_method = "provisioning_key"`, you may optionally supply an existing Service Edge Group and Provisioning Key, or follow the prompts in the examples `terraform.tfvars` to create a new Service Edge Group and Provisioning Key.

See: [Zscaler App Connector AWS Deployment Guide](https://help.zscaler.com/zpa/connector-deployment-guide-amazon-web-services) for additional prerequisite provisioning steps.

## ZPA OneAPI Authentication Framework (OneAPI)

1. A valid Zscaler Private Access subscription and portal access
2. Zscaler tenant MUST be migrated to Zidentity platform.
3. Details on how to authenticate to ZPA via Zidentity/OneAPI are located here [here](https://registry.terraform.io/providers/zscaler/zpa/latest/docs#authentication---oneapi-new-framework)
- `client_id`
- `client_secret`
- `zpa_customer_id`
- `vanity_domain`
- `zscaler_cloud` - This authentication parameter is optional and only required if authenticating to a non-production cloud i.e `beta`

```hcl
provider "zpa" {
  client_id = "client_id" # pragma: allowlist secret
  client_secret = "client_secret" # pragma: allowlist secret
  zpa_customer_id = "client_secret" # pragma: allowlist secret
  vanity_domain = "vanity_domain" # pragma: allowlist secret
  zscaler_cloud = "zscaler_cloud" # pragma: allowlist secret
}
```

4. (Optional) With the default `oauth` onboarding method no provisioning key is required. If you set `onboarding_method = "provisioning_key"`, you may optionally supply an existing Service Edge Group and Provisioning Key, or follow the prompts in the examples `terraform.tfvars` to create a new Service Edge Group and Provisioning Key.

See: [Zscaler Service Edge AWS Deployment Guide](https://help.zscaler.com/zpa/service-edge-deployment-guide-amazon-web-services) for additional prerequisite provisioning steps.

## How to deploy
Provisioning templates are available for customer use/reference to successfully deploy fully operational Service Edge appliances once the prerequisites have been completed. Please follow the instructions located in [examples](examples/README.md).

## Format

This repository follows the [Hashicorp Standard Modules Structure](https://www.terraform.io/registry/modules/publish):

* `modules` - All module resources utilized by and customized specifically for Service Edge deployments. The intent is these modules are resusable and functional for any deployment type referencing for both production or lab/testing purposes.
* `examples` - Zscaler provides fully functional deployment templates utilizing a combination of some or all of the modules published. These can utilized in there entirety or as reference templates for more advanced customers or custom deployments. For novice Terraform users, we also provide a bash script (zspse) that can be run from any Linux/Mac OS or CSP Cloud Shell that walks through all provisioning requirements as well as downloading/running an isolated teraform process. This allows Service Edge deployments from any supported client without needing to even have Terraform installed or know how the language/syntax for running it.

## Versioning

These modules follow recommended release tagging in [Semantic Versioning](http://semver.org/). You can find each new release,
along with the changelog, on the GitHub [Releases](https://github.com/zscaler/terraform-aws-zpa-private-service-edge-modules/releases) page.

# License and Copyright

Copyright (c) 2022 Zscaler, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

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

## Prerequisites

Our Deployment scripts are leveraging Terraform v1.1.9 that includes full binary and provider support for MacOS M1 chips, but any Terraform version 0.13.7 should be generally supported.

- provider registry.terraform.io/hashicorp/aws v5.58.x
- provider registry.terraform.io/hashicorp/random v3.6.x
- provider registry.terraform.io/hashicorp/local v2.5.x
- provider registry.terraform.io/hashicorp/null v3.2.x
- provider registry.terraform.io/providers/hashicorp/tls v4.0.x
- provider registry.terraform.io/providers/zscaler/zpa v3.31.x

### AWS requirements
1. A valid AWS account
2. AWS ACCESS KEY ID
3. AWS SECRET ACCESS KEY
4. AWS Region (E.g. us-west-2)
5. Subscribe and accept terms of using Amazon Linux 2 AMI (for base deployments with workloads + bastion) at [this link](https://aws.amazon.com/marketplace/pp/prodview-zc4x2k7vt6rpu)
6. Subscribe and accept terms of using Zscaler Service Edge image at [this link](https://aws.amazon.com/marketplace/pp/prodview-epy3md7fcvk4g)

### Zscaler requirements
This module leverages the Zscaler Private Access [ZPA Terraform Provider](https://registry.terraform.io/providers/zscaler/zpa/latest/docs) for the automated onboarding process. Before proceeding make sure you have the following pre-requistes ready.

7. A valid Zscaler Private Access subscription and portal access
8. Zscaler ZPA API Keys. Details on how to find and generate ZPA API keys can be located [here](https://help.zscaler.com/zpa/about-api-keys#:~:text=An%20API%20key%20is%20required,from%20the%20API%20Keys%20page)
- Client ID
- Client Secret
- Customer ID
9. (Optional) An existing Service Edge Group and Provisioning Key. Otherwise, you can follow the prompts in the examples terraform.tfvars to create a new Connector Group and Provisioning Key

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

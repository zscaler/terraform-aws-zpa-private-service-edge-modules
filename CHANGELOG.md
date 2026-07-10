# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0](https://github.com/zscaler/terraform-aws-zpa-private-service-edge-modules/compare/v1.1.1...v2.0.0) (2026-07-10)

### ⚠ BREAKING CHANGES

* OAuth2 user-code onboarding is now the default enrollment
method, replacing the provisioning key flow. Existing deployments that relied
on the provisioning key default must set onboarding_method = "provisioning_key"
(or byo_provisioning_key = true) to preserve prior behavior. Several
tfvars/variables changed across examples and modules, and the ZPA provider
>= 4.4.0 is now required.

* ci: add terratest composite action and per-module TestValidate tests

Restore the CI scaffolding the reusable workflow requires and fix
terraform fmt drift in example tfvars.

- Add .github/actions/terratest/action.yml (setup Terraform/Go, OIDC AWS
  auth via ASSUME_ROLE, run `make <path> ACTION=<action>`), mirroring the
  app-connector module. Fixes "Can't find action.yml" failures across all
  validate/test matrix jobs.
- Add main_test.go (TestValidate -> testskeleton.ValidateCode) to all eight
  modules so `make modules/<name> ACTION=Validate` runs under the matrix.
- Reformat pse_is_public assignment in base_pse/pse/pse_asg tfvars to
  satisfy terraform fmt (pre-commit terraform_fmt hook).

* docs: regenerate module and example READMEs via terraform-docs

Refresh the auto-generated terraform-docs tables to match the current
inputs/outputs after the OAuth2 onboarding changes. Fixes the
terraform_docs pre-commit hook failure.

- Add user_codes input to the service edge group module docs
- Update pse_group_version_profile_id description/default
- Add zpa_customer_version_profile data source and provider version bumps
- Normalize table separators to terraform-docs current output

* fix: resolve terraform_tflint unused-declaration findings

Use the computed local.version_profile_id (which sends "0" when the
version profile is not overridden) on the zpa_service_edge_group
resource instead of the raw variable, so the local is no longer
unused and the API receives the correct value.

Remove the unused pse_count, reuse_security_group, and reuse_iam
variables from the pse_asg example (the ASG flow uses min_size/max_size
and creates a single SG/IAM profile), and drop their rows from the
generated README.

* fix: drop KMS alias lookup for EBS encryption to match app-connector

The bastion, psevm, and asg modules resolved the default aws/ebs KMS
key via aws_ebs_default_kms_key + aws_kms_alias data sources purely to
populate root_block_device.kms_key_id. That lookup requires
kms:ListAliases, which the CI OIDC role does not grant, so every
terraform plan failed once the pre-commit gate was cleared.

The app-connector modules never perform this lookup. Align with that
approach: remove the KMS data sources and the explicit kms_key_id, and
keep encrypted = var.encrypted_ebs_enabled. With encryption enabled and
no kms_key_id, AWS uses the account default EBS key automatically, so
volumes stay encrypted without needing any KMS read permission.

Regenerate the affected module READMEs to drop the removed data sources.

### Features

* add OAuth2 user-code onboarding as the default enrollment method ([#9](https://github.com/zscaler/terraform-aws-zpa-private-service-edge-modules/issues/9)) ([12c3a49](https://github.com/zscaler/terraform-aws-zpa-private-service-edge-modules/commit/12c3a493f449f84edeb189148c1f29f26951dac4))

### Bug Fixes

* add ignore_tags to base example provider to stop tags idempotence drift ([5c32643](https://github.com/zscaler/terraform-aws-zpa-private-service-edge-modules/commit/5c326434fdacb3864832cac7e48cfc42b7314aed))
* mirror app-connector instances to stop bastion/PSE VM idempotence drift ([d104b7b](https://github.com/zscaler/terraform-aws-zpa-private-service-edge-modules/commit/d104b7b7cf9c46578635b7ca9a34e4f98ed4fefb))
* prevent version_profile_id idempotence drift on service edge group ([ecad7b7](https://github.com/zscaler/terraform-aws-zpa-private-service-edge-modules/commit/ecad7b7aa3d9a63255045bb95defda9ebe4d2a84))
* set city_country on service edge group to stop tags/city_country drift ([b43005f](https://github.com/zscaler/terraform-aws-zpa-private-service-edge-modules/commit/b43005f3cbf924a7065a007990bcfe44ed6c056c))

### [1.1.1](https://github.com/zscaler/terraform-aws-zpa-private-service-edge-modules/compare/v1.1.0...v1.1.1) (2025-04-08)


### Bug Fixes

* Upgraded ZPA Provider Version to v4.0.x and AWS to v5.90.x ([#8](https://github.com/zscaler/terraform-aws-zpa-private-service-edge-modules/issues/8)) ([1b33ebd](https://github.com/zscaler/terraform-aws-zpa-private-service-edge-modules/commit/1b33ebdb5855b2af7165551bf916528b41b266a6))

## 1.0.0 (2023-01-11)

### Features

* AWS Service Edge release ([eee9078](https://github.com/zscaler/terraform-aws-zpa-private-service-edge-modules/commit/eee907892f461e9494511fa2bcdc11b84581f0fd))
* CICD and supporting docs ([70dab95](https://github.com/zscaler/terraform-aws-zpa-private-service-edge-modules/commit/70dab95b62c4963409501a3969fd6530df5dc742))


### Bug Fixes

* launch_template ebs device_name change ([fa2ec52](https://github.com/zscaler/terraform-aws-zpa-private-service-edge-modules/commit/fa2ec52dfc9272543caae8332240f864734c8366))
* service_edge_group creation fixes ([ec5fc9e](https://github.com/zscaler/terraform-aws-zpa-private-service-edge-modules/commit/ec5fc9ecf3f7e1f01b42e7e640991e72b90746ae))
* zspse zpa cloud selection ([e4fc1bc](https://github.com/zscaler/terraform-aws-zpa-private-service-edge-modules/commit/e4fc1bce254048a6bdad73d73ab05d06db9d74f0))
* zspse zpa_cloud shorthand ([140a949](https://github.com/zscaler/terraform-aws-zpa-private-service-edge-modules/commit/140a949e5ea8108ec13734a8a9cce31b029e90cc))

################################################################################
# Generate a unique random string for resource name assignment and key pair
################################################################################
resource "random_string" "suffix" {
  length  = 8
  upper   = false
  special = false
}


################################################################################
# Map default tags with values to be assigned to all tagged resources
################################################################################
locals {
  global_tags = {
    Owner                                                                               = var.owner_tag
    ManagedBy                                                                           = "terraform"
    Vendor                                                                              = "Zscaler"
    "zs-service-edge-cluster/${var.name_prefix}-cluster-${random_string.suffix.result}" = "shared"
  }

  # Onboarding method switch. Default is OAuth2; set onboarding_method to
  # "provisioning_key" (or byo_provisioning_key = true) to use the legacy
  # provisioning key flow instead.
  use_provisioning_key = var.onboarding_method == "provisioning_key" || var.byo_provisioning_key
}


################################################################################
# The following lines generates a new SSH key pair and stores the PEM file
# locally. The public key output is used as the instance_key passed variable
# to the ec2 modules for admin_ssh_key public_key authentication.
# This is not recommended for production deployments. Please consider modifying
# to pass your own custom public key file located in a secure location.
################################################################################
resource "tls_private_key" "key" {
  algorithm = var.tls_key_algorithm
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.name_prefix}-key-${random_string.suffix.result}"
  public_key = tls_private_key.key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.key.private_key_pem
  filename        = "./${var.name_prefix}-key-${random_string.suffix.result}.pem"
  file_permission = "0600"
}


################################################################################
# 1. Create/reference all network infrastructure resource dependencies for all
#    child modules (vpc, igw, nat gateway, subnets, route tables)
################################################################################
module "network" {
  source                      = "../../modules/terraform-zspse-network-aws"
  name_prefix                 = var.name_prefix
  resource_tag                = random_string.suffix.result
  global_tags                 = local.global_tags
  az_count                    = var.az_count
  vpc_cidr                    = var.vpc_cidr
  public_subnets              = var.public_subnets
  pse_subnets                 = var.pse_subnets
  associate_public_ip_address = var.associate_public_ip_address

  #bring-your-own variables
  byo_vpc        = var.byo_vpc
  byo_vpc_id     = var.byo_vpc_id
  byo_subnets    = var.byo_subnets
  byo_subnet_ids = var.byo_subnet_ids
  byo_igw        = var.byo_igw
  byo_igw_id     = var.byo_igw_id
  byo_ngw        = var.byo_ngw
  byo_ngw_ids    = var.byo_ngw_ids
}


################################################################################
# 2. Generate Service Edge Group name with template variable support
################################################################################
locals {
  # Default naming pattern if not specified
  default_pse_group_name = "${var.aws_region}-${module.network.vpc_id}"

  # User-provided name with variable substitution
  custom_pse_group_name = var.pse_group_name != "" ? replace(
    replace(
      replace(
        replace(var.pse_group_name, "{region}", var.aws_region),
        "{vpc_id}", module.network.vpc_id
      ),
      "{name_prefix}", var.name_prefix
    ),
    "{random_suffix}", random_string.suffix.result
  ) : local.default_pse_group_name
}


################################################################################
# 3. (Provisioning key flow only) Create the ZPA Service Edge Group and
#    Provisioning Key up front so the key can be baked into the VM user_data.
################################################################################
module "zpa_service_edge_group_pk" {
  count                              = local.use_provisioning_key && var.byo_provisioning_key == false ? 1 : 0
  source                             = "../../modules/terraform-zpa-service-edge-group"
  pse_group_name                     = local.custom_pse_group_name
  pse_group_description              = "${var.pse_group_description}-${var.aws_region}-${module.network.vpc_id}"
  pse_group_enabled                  = var.pse_group_enabled
  pse_group_country_code             = var.pse_group_country_code
  pse_group_city_country             = var.pse_group_city_country
  pse_group_latitude                 = var.pse_group_latitude
  pse_group_longitude                = var.pse_group_longitude
  pse_group_location                 = var.pse_group_location
  pse_group_upgrade_day              = var.pse_group_upgrade_day
  pse_group_upgrade_time_in_secs     = var.pse_group_upgrade_time_in_secs
  pse_group_override_version_profile = var.pse_group_override_version_profile
  pse_group_version_profile_id       = var.pse_group_version_profile_id
  pse_is_public                      = var.pse_is_public
  zpa_trusted_network_name           = var.zpa_trusted_network_name
}

module "zpa_provisioning_key" {
  count                             = local.use_provisioning_key ? 1 : 0
  source                            = "../../modules/terraform-zpa-provisioning-key"
  enrollment_cert                   = var.enrollment_cert
  provisioning_key_name             = var.provisioning_key_name != "" ? var.provisioning_key_name : local.custom_pse_group_name
  provisioning_key_enabled          = var.provisioning_key_enabled
  provisioning_key_association_type = var.provisioning_key_association_type
  provisioning_key_max_usage        = var.provisioning_key_max_usage
  pse_group_id                      = try(module.zpa_service_edge_group_pk[0].service_edge_group_id, "")
  byo_provisioning_key              = var.byo_provisioning_key
  byo_provisioning_key_name         = var.byo_provisioning_key_name
}


################################################################################
# 4. (OAuth2 flow only) Create SSM Parameter Store parameters for OAuth token
#    storage. Terraform creates these upfront, VMs update them with their codes.
################################################################################
resource "aws_ssm_parameter" "oauth_tokens" {
  count = local.use_provisioning_key == false && var.byo_ssm_parameter_name == "" ? var.pse_count : 0

  name  = "/zpa/oauth-tokens/${var.name_prefix}-${var.aws_region}-pse-${count.index + 1}-${random_string.suffix.result}"
  type  = "SecureString"
  value = "PENDING" # Placeholder - will be updated by VM user_data

  tags = merge(local.global_tags, {
    Purpose = "ZPA-OAuth-Token"
    VMIndex = count.index
  })

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

locals {
  ssm_parameter_names = var.byo_ssm_parameter_name == "" ? aws_ssm_parameter.oauth_tokens[*].name : [for i in range(var.pse_count) : "${var.byo_ssm_parameter_name}-${i}"]
}


################################################################################
# 5. Generate user_data using centralized scripts (Zscaler AMI or RHEL9 based
#    on use_zscaler_ami). The onboarding_method flag selects between OAuth2 and
#    provisioning key bootstrap logic inside the script.
################################################################################
locals {
  provisioning_key_value = local.use_provisioning_key ? try(module.zpa_provisioning_key[0].provisioning_key, "") : ""

  # Zscaler AMI user_data (for Fixed VMs)
  pseuserdata = [for i in range(var.pse_count) :
    templatefile("${path.module}/../../scripts/user_data_zscaler.sh", {
      onboarding_method    = local.use_provisioning_key ? "provisioning_key" : "oauth"
      provisioning_key     = local.provisioning_key_value
      ssm_parameter_name   = local.use_provisioning_key ? "" : local.ssm_parameter_names[i]
      ssm_parameter_prefix = ""
      is_asg               = false
    })
  ]

  # RHEL9 user_data (for Fixed VMs)
  rhel9userdata = [for i in range(var.pse_count) :
    templatefile("${path.module}/../../scripts/user_data_rhel9.sh", {
      onboarding_method    = local.use_provisioning_key ? "provisioning_key" : "oauth"
      provisioning_key     = local.provisioning_key_value
      ssm_parameter_name   = local.use_provisioning_key ? "" : local.ssm_parameter_names[i]
      ssm_parameter_prefix = ""
      is_asg               = false
    })
  ]
}


################################################################################
# Locate Latest Service Edge AMI by product code
################################################################################
data "aws_ami" "service_edge" {
  count       = var.use_zscaler_ami ? 1 : 0
  most_recent = true

  filter {
    name   = "product-code"
    values = ["f3xw1xhjj0gvf0o97rfphs0k0"]
  }

  owners = ["aws-marketplace"]
}


################################################################################
# Locate Latest Red Hat Enterprise Linux 9 AMI for instance use
################################################################################
data "aws_ami" "rhel_9_latest" {
  count       = var.use_zscaler_ami ? 0 : 1
  most_recent = true
  owners      = ["309956199498"]

  filter {
    name   = "name"
    values = ["RHEL-9.4.0_HVM-20240423-x86_64-62-Hourly2-GP3"]
  }
}

# Local variable to select the appropriate AMI ID
locals {
  ami_selected = try(data.aws_ami.service_edge[0].id, data.aws_ami.rhel_9_latest[0].id)
}


################################################################################
# 6. Create specified number of PSE appliances
################################################################################
module "pse_vm" {
  source                      = "../../modules/terraform-zspse-psevm-aws"
  pse_count                   = var.pse_count
  name_prefix                 = var.name_prefix
  resource_tag                = random_string.suffix.result
  global_tags                 = local.global_tags
  pse_subnet_ids              = module.network.pse_subnet_ids
  instance_key                = aws_key_pair.deployer.key_name
  user_data                   = var.use_zscaler_ami == true ? local.pseuserdata : local.rhel9userdata
  psevm_instance_type         = var.psevm_instance_type
  iam_instance_profile        = module.pse_iam.iam_instance_profile_id
  security_group_id           = module.pse_sg.pse_security_group_id
  associate_public_ip_address = var.associate_public_ip_address
  ami_id                      = contains(var.ami_id, "") ? [local.ami_selected] : var.ami_id

  depends_on = [
    aws_ssm_parameter.oauth_tokens,
    module.zpa_provisioning_key
  ]
}


################################################################################
# 7. Create IAM Policy, Roles, and Instance Profiles to be assigned to PSE.
################################################################################
module "pse_iam" {
  source       = "../../modules/terraform-zspse-iam-aws"
  iam_count    = var.reuse_iam == false ? var.pse_count : 1
  name_prefix  = var.name_prefix
  resource_tag = random_string.suffix.result
  global_tags  = local.global_tags

  byo_iam = var.byo_iam
  # optional inputs. only required if byo_iam set to true
  byo_iam_instance_profile_id = var.byo_iam_instance_profile_id
  # optional inputs. only required if byo_iam set to true
}


################################################################################
# 8. Create Security Group and rules to be assigned to the Service Edge
#    interface.
################################################################################
module "pse_sg" {
  source                      = "../../modules/terraform-zspse-sg-aws"
  sg_count                    = var.reuse_security_group == false ? var.pse_count : 1
  name_prefix                 = var.name_prefix
  resource_tag                = random_string.suffix.result
  global_tags                 = local.global_tags
  vpc_id                      = module.network.vpc_id
  associate_public_ip_address = var.associate_public_ip_address

  byo_security_group = var.byo_security_group
  # optional inputs. only required if byo_security_group set to true
  byo_security_group_id = var.byo_security_group_id
  # optional inputs. only required if byo_security_group set to true
}


################################################################################
# 9. (OAuth2 flow only) Retrieve OAuth2 user codes from SSM Parameter Store.
#     VMs register tokens quickly (2-4 min), then Terraform reads them back.
################################################################################

# Wait for OAuth tokens to be registered in SSM
resource "time_sleep" "wait_for_oauth_tokens" {
  count      = local.use_provisioning_key ? 0 : 1
  depends_on = [module.pse_vm]

  create_duration = "360s" # 6 minutes - ensures all VMs have time to register
}

# Retrieve OAuth tokens from SSM Parameter Store
data "aws_ssm_parameter" "oauth_tokens" {
  count      = local.use_provisioning_key ? 0 : var.pse_count
  name       = local.ssm_parameter_names[count.index]
  depends_on = [time_sleep.wait_for_oauth_tokens, aws_ssm_parameter.oauth_tokens]
}

# Extract tokens from SSM parameters
locals {
  user_codes = local.use_provisioning_key ? [] : [for i in range(var.pse_count) : data.aws_ssm_parameter.oauth_tokens[i].value]
}


################################################################################
# 10. (OAuth2 flow only) Create the ZPA Service Edge Group with OAuth2 user
#     codes. Created AFTER waiting for all OAuth tokens to be ready.
################################################################################
module "zpa_service_edge_group" {
  count                              = local.use_provisioning_key ? 0 : 1
  source                             = "../../modules/terraform-zpa-service-edge-group"
  pse_group_name                     = local.custom_pse_group_name
  pse_group_description              = "${var.pse_group_description}-${var.aws_region}-${module.network.vpc_id}"
  pse_group_enabled                  = var.pse_group_enabled
  pse_group_country_code             = var.pse_group_country_code
  pse_group_city_country             = var.pse_group_city_country
  pse_group_latitude                 = var.pse_group_latitude
  pse_group_longitude                = var.pse_group_longitude
  pse_group_location                 = var.pse_group_location
  pse_group_upgrade_day              = var.pse_group_upgrade_day
  pse_group_upgrade_time_in_secs     = var.pse_group_upgrade_time_in_secs
  pse_group_override_version_profile = var.pse_group_override_version_profile
  pse_group_version_profile_id       = var.pse_group_version_profile_id
  pse_is_public                      = var.pse_is_public
  zpa_trusted_network_name           = var.zpa_trusted_network_name
  user_codes                         = local.user_codes

  depends_on = [
    data.aws_ssm_parameter.oauth_tokens
  ]
}

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
  filename        = "../${var.name_prefix}-key-${random_string.suffix.result}.pem"
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
# 2. Create ZPA Service Edge Group
################################################################################
module "zpa_service_edge_group" {
  count                              = var.byo_provisioning_key == true ? 0 : 1 # Only use this module if a new provisioning key is needed
  source                             = "../../modules/terraform-zpa-service-edge-group"
  pse_group_name                     = coalesce(var.pse_group_name, "${var.aws_region}-${module.network.vpc_id}")
  pse_group_description              = "${var.pse_group_description}-${var.aws_region}-${module.network.vpc_id}"
  pse_group_enabled                  = var.pse_group_enabled
  pse_group_country_code             = var.pse_group_country_code
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


################################################################################
# 3. Create ZPA Provisioning Key (or reference existing if byo set)
################################################################################
module "zpa_provisioning_key" {
  source                            = "../../modules/terraform-zpa-provisioning-key"
  enrollment_cert                   = var.enrollment_cert
  provisioning_key_name             = coalesce(var.provisioning_key_name, "${var.aws_region}-${module.network.vpc_id}")
  provisioning_key_enabled          = var.provisioning_key_enabled
  provisioning_key_association_type = var.provisioning_key_association_type
  provisioning_key_max_usage        = var.provisioning_key_max_usage
  pse_group_id                      = try(module.zpa_service_edge_group[0].service_edge_group_id, "")
  byo_provisioning_key              = var.byo_provisioning_key
  byo_provisioning_key_name         = var.byo_provisioning_key_name
}


################################################################################
# 4. Create specified number PSE VMs per min_size / max_size which will span  
#    equally across designated availability zones per az_count. E.g. min_size  
#    set to 4 and az_count set to 2 will create 2x PSEs in AZ1 and 2x PSEs in AZ2
################################################################################

################################################################################
# A. Create the user_data file with necessary bootstrap variables for Service   
#    Edge registration. Used if variable use_zscaler_ami is set to false.
################################################################################
locals {
  pseuserdata = <<PSEUSERDATA
#!/bin/bash 
#Stop the Service Edge service which was auto-started at boot time 
systemctl stop zpa-service-edge 
#Create a file from the Service Edge provisioning key created in the ZPA Admin Portal 
#Make sure that the provisioning key is between double quotes 
echo "${module.zpa_provisioning_key.provisioning_key}" > /opt/zscaler/var/service-edge/provision_key
#Run a yum update to apply the latest patches 
yum update -y 
#Start the Service Edge service to enroll it in the ZPA cloud 
systemctl start zpa-service-edge 
#Wait for the Service Edge to download latest build 
sleep 60 
#Stop and then start the Service Edge for the latest build 
systemctl stop zpa-service-edge 
systemctl start zpa-service-edge
PSEUSERDATA
}

# Write the file to local filesystem for storage/reference
resource "local_file" "user_data_file" {
  count    = var.use_zscaler_ami == true ? 1 : 0
  content  = local.pseuserdata
  filename = "../user_data"
}


################################################################################
# B. Create the user_data file with necessary bootstrap variables for App
#    Connector registration. Used if variable use_zscaler_ami is set to false.
################################################################################
locals {
  rhel9userdata = <<RHEL9USERDATA
#!/usr/bin/bash
# Sleep to allow the system to initialize
sleep 15

# Create the Zscaler repository file
touch /etc/yum.repos.d/zscaler.repo
cat > /etc/yum.repos.d/zscaler.repo <<-EOT
[zscaler]
name=Zscaler Private Access Repository
baseurl=https://yum.private.zscaler.com/yum/el9
enabled=1
gpgcheck=1
gpgkey=https://yum.private.zscaler.com/gpg
EOT

# Sleep to allow the repo file to be registered
sleep 60

# Install unzip
yum install -y unzip

# Download and install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --update -i /usr/bin/aws-cli -b /usr/bin

# Verify AWS CLI installation
/usr/bin/aws --version

# Install App Connector packages
yum install -y zpa-connector

# Stop the App Connector service which was auto-started at boot time
systemctl stop zpa-connector

# Create a file from the App Connector provisioning key created in the ZPA Admin Portal
# Make sure that the provisioning key is between double quotes
echo "${module.zpa_provisioning_key.provisioning_key}" > /opt/zscaler/var/provision_key
chmod 644 /opt/zscaler/var/provision_key

# Run a yum update to apply the latest patches
yum update -y

# Start the App Connector service to enroll it in the ZPA cloud
systemctl start zpa-connector

# Wait for the App Connector to download the latest build
sleep 60

# Stop and then start the App Connector for the latest build
systemctl stop zpa-connector
systemctl start zpa-connector
RHEL9USERDATA
}

# Write the file to local filesystem for storage/reference
resource "local_file" "rhel9_user_data_file" {
  count    = var.use_zscaler_ami == true ? 0 : 1
  content  = local.rhel9userdata
  filename = "../user_data"
}


################################################################################
# Locate Latest Service Edge AMI by product code
# Latest Software version and AMI ID in each region can be located here:
# https://aws.amazon.com/marketplace/server/configuration?productId=ff37a29a-8ec3-44c5-8010-e6ee4d0f56d0&ref_=psb_cfg_continue
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

# Data source to retrieve RHEL 9.4.0 AMI
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
# Create the specified PSE VMs via Launch Template and Autoscaling Group
################################################################################
module "pse_asg" {
  source                      = "../../modules/terraform-zspse-asg-aws"
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

  max_size                  = var.max_size
  min_size                  = var.min_size
  target_cpu_util_value     = var.target_cpu_util_value
  health_check_grace_period = var.health_check_grace_period
  launch_template_version   = var.launch_template_version
  target_tracking_metric    = var.target_tracking_metric

  warm_pool_enabled = var.warm_pool_enabled
  ### only utilzed if warm_pool_enabled set to true ###
  warm_pool_state                       = var.warm_pool_state
  warm_pool_min_size                    = var.warm_pool_min_size
  warm_pool_max_group_prepared_capacity = var.warm_pool_max_group_prepared_capacity
  reuse_on_scale_in                     = var.reuse_on_scale_in
  ### only utilzed if warm_pool_enabled set to true ###  

  depends_on = [
    module.zpa_provisioning_key,
  ]
}


################################################################################
# 5. Create IAM Policy, Roles, and Instance Profiles to be assigned to PSE.
#    Default behavior will create 1 of each IAM resource per PSE VM. Set variable
#    "reuse_iam" to true if you would like a single IAM profile created and
#    assigned to ALL Service Edges instead.
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
# 6. Create Security Group and rules to be assigned to the Service Edge
#    interface. Default behavior will create 1 of each SG resource per PSE VM.
#    Set variable "reuse_security_group" to true if you would like a single
#    security group created and assigned to ALL Service Edges instead.
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

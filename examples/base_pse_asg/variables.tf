variable "aws_region" {
  type        = string
  description = "The AWS region."
  default     = "us-west-2"
}

variable "name_prefix" {
  type        = string
  description = "The name prefix for all your resources"
  default     = "zsdemo"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC IP CIDR Range. All subnet resources that might get created (public / service edge) are derived from this /16 CIDR. If you require creating a VPC smaller than /16, you may need to explicitly define all other subnets via public_subnets and pse_subnets variables"
  default     = "10.1.0.0/16"
}

variable "public_subnets" {
  type        = list(string)
  description = "Public/NAT GW Subnets to create in VPC. This is only required if you want to override the default subnets that this code creates via vpc_cidr variable."
  default     = null
}

variable "pse_subnets" {
  type        = list(string)
  description = "Service Edge Subnets to create in VPC. This is only required if you want to override the default subnets that this code creates via vpc_cidr variable."
  default     = null
}

variable "az_count" {
  type        = number
  description = "Default number of subnets to create based on availability zone input"
  default     = 2
  validation {
    condition = (
      (var.az_count >= 1 && var.az_count <= 3)
    )
    error_message = "Input az_count must be set to a single value between 1 and 3. Note* some regions have greater than 3 AZs. Please modify az_count validation in variables.tf if you are utilizing more than 3 AZs in a region that supports it. https://aws.amazon.com/about-aws/global-infrastructure/regions_az/."
  }
}

variable "owner_tag" {
  type        = string
  description = "populate custom owner tag attribute"
  default     = "zszpa-admin"
}

variable "tls_key_algorithm" {
  type        = string
  description = "algorithm for tls_private_key resource"
  default     = "RSA"
}

variable "bastion_nsg_source_prefix" {
  type        = list(string)
  description = "CIDR blocks of trusted networks for bastion host ssh access"
  default     = ["0.0.0.0/0"]
}

variable "psevm_instance_type" {
  type        = string
  description = "Service Edge Instance Type"
  default     = "m5.large"
  validation {
    condition = (
      var.psevm_instance_type == "t3.xlarge" ||
      var.psevm_instance_type == "m5.large" ||
      var.psevm_instance_type == "m5.xlarge" ||
      var.psevm_instance_type == "m5.2xlarge" ||
      var.psevm_instance_type == "m5.4xlarge"
    )
    error_message = "Input psevm_instance_type must be set to an approved vm instance type."
  }
}

variable "associate_public_ip_address" {
  type        = bool
  description = "enable/disable public IP addresses on Service Edge instances. Setting this to true will result in the following: Dynamic Public IP address on the Service Edge VM Instance will be enabled; no EIP or NAT Gateway resources will be created; and the Service Edge Route Table default route next-hop will be set as the IGW"
  default     = false
}

variable "use_zscaler_ami" {
  type        = bool
  description = "By default, Service Edge will deploy via the Zscaler Latest AMI. Setting this to false will deploy the latest Amazon Linux 2 AMI instead"
  default     = true
}

variable "bastion_deploy" {
  type        = bool
  description = "Bastion deployments in a public subnet only exists in greenfield example templates.  This variable boolean is used for production Service Edge deployments with a public IP address associated to not create unneccesary public network resources. Default is true"
  default     = true
}

variable "ami_id" {
  type        = list(string)
  description = "AMI ID(s) to be used for deploying Private Service Edge appliances. Ideally all VMs should be on the same AMI ID as templates always pull the latest from AWS Marketplace. This variable is provided if a customer desires to override/retain an old ami for existing deployments rather than upgrading and forcing a replacement. It is also inputted as a list to facilitate if a customer desired to manually upgrade select PSEs deployed based on the pse_count index"
  default     = [""]
}


# ZPA Provider specific variables for Service Edge Group and Provisioning Key creation
variable "byo_provisioning_key" {
  type        = bool
  description = "Bring your own Service Edge Provisioning Key. Setting this variable to true will effectively instruct this module to not create any resources and only reference data resources from values provided in byo_provisioning_key_name"
  default     = false
}

variable "byo_provisioning_key_name" {
  type        = string
  description = "Existing Service Edge Provisioning Key name"
  default     = null
}

variable "enrollment_cert" {
  type        = string
  description = "Get name of ZPA enrollment cert to be used for Service Edge provisioning"
  default     = "Service Edge"

  validation {
    condition = (
      var.enrollment_cert == "Service Edge"
    )
    error_message = "Input enrollment_cert must be set to an approved value."
  }
}

variable "pse_group_name" {
  type        = string
  description = "Name of the Service Edge Group"
  default     = ""
}

variable "pse_group_description" {
  type        = string
  description = "Optional: Description of the Service Edge Group"
  default     = ""
}

variable "pse_group_enabled" {
  type        = bool
  description = "Whether this Service Edge Group is enabled or not"
  default     = true
}

variable "pse_group_country_code" {
  type        = string
  description = "Optional: Country code of this Service Edge Group. example 'US'"
  default     = ""
}

variable "pse_group_latitude" {
  type        = string
  description = "Latitude of the Service Edge Group. Integer or decimal. With values in the range of -90 to 90"
  default     = "37.3382082"
}

variable "pse_group_longitude" {
  type        = string
  description = "Longitude of the Service Edge Group. Integer or decimal. With values in the range of -90 to 90"
  default     = "-121.8863286"
}

variable "pse_group_location" {
  type        = string
  description = "location of the Service Edge Group in City, State, Country format. example: 'San Jose, CA, USA'"
  default     = "San Jose, CA, USA"
}

variable "pse_group_upgrade_day" {
  type        = string
  description = "Optional: Service Edges in this group will attempt to update to a newer version of the software during this specified day. Default value: SUNDAY. List of valid days (i.e., SUNDAY, MONDAY, etc)"
  default     = "SUNDAY"
}

variable "pse_group_upgrade_time_in_secs" {
  type        = string
  description = "Optional: Service Edges in this group will attempt to update to a newer version of the software during this specified time. Default value: 66600. Integer in seconds (i.e., 66600). The integer should be greater than or equal to 0 and less than 86400, in 15 minute intervals"
  default     = "66600"
}

variable "pse_group_override_version_profile" {
  type        = bool
  description = "Optional: Whether the default version profile of the Service Edge Group is applied or overridden. Default: false"
  default     = false
}

variable "pse_group_version_profile_id" {
  type        = string
  description = "Optional: ID of the version profile. To learn more, see Version Profile Use Cases. https://help.zscaler.com/zpa/configuring-version-profile"
  default     = "2"

  validation {
    condition = (
      var.pse_group_version_profile_id == "0" || #Default = 0
      var.pse_group_version_profile_id == "1" || #Previous Default = 1
      var.pse_group_version_profile_id == "2"    #New Release = 2
    )
    error_message = "Input pse_group_version_profile_id must be set to an approved value."
  }
}

variable "pse_is_public" {
  type        = bool
  description = "(Optional) Enable or disable public access for the Service Edge Group. Default value is false"
  default     = false
}

variable "zpa_trusted_network_name" {
  type        = string
  description = "To query trusted network that are associated with a specific Zscaler cloud, it is required to append the cloud name to the name of the trusted network. For more details refer to docs: https://registry.terraform.io/providers/zscaler/zpa/latest/docs/data-sources/zpa_trusted_network"
  default     = "" # a valid example name + cloud >> "Corporate-Network (zscalertwo.net)"
}

variable "provisioning_key_name" {
  type        = string
  description = "Name of the provisioning key"
  default     = ""
}

variable "provisioning_key_enabled" {
  type        = bool
  description = "Whether the provisioning key is enabled or not. Default: true"
  default     = true
}

variable "provisioning_key_association_type" {
  type        = string
  description = "Specifies the provisioning key type for Service Edges or ZPA Private Service Edges. The supported value is SERVICE_EDGE_GRP"
  default     = "SERVICE_EDGE_GRP"

  validation {
    condition = (
      var.provisioning_key_association_type == "SERVICE_EDGE_GRP"
    )
    error_message = "Input provisioning_key_association_type must be set to an approved value."
  }
}

variable "provisioning_key_max_usage" {
  type        = number
  description = "The maximum number of instances where this provisioning key can be used for enrolling an App Connector or Service Edge"
  default     = 10
}


# Autoscaling Group specific variables list
variable "min_size" {
  type        = number
  description = "Mininum number of Service Edges to maintain in Autoscaling group"
  default     = 2
}

variable "max_size" {
  type        = number
  description = "Maxinum number of Service Edges to maintain in Autoscaling group"
  default     = 4
}

variable "health_check_grace_period" {
  type        = number
  description = "The amount of time until EC2 Auto Scaling performs the first health check on new instances after they are put into service. Default is 5 minutes"
  default     = 300
}

variable "warm_pool_enabled" {
  type        = bool
  description = "If set to true, add a warm pool to the specified Auto Scaling group. See [warm_pool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#warm_pool)."
  default     = "false"
}

variable "warm_pool_state" {
  type        = string
  description = "Sets the instance state to transition to after the lifecycle hooks finish. Valid values are: Stopped (default), Running or Hibernated. Ignored when 'warm_pool_enabled' is false"
  default     = null
}

variable "warm_pool_min_size" {
  type        = number
  description = "Specifies the minimum number of instances to maintain in the warm pool. This helps you to ensure that there is always a certain number of warmed instances available to handle traffic spikes. Ignored when 'warm_pool_enabled' is false"
  default     = null
}

variable "warm_pool_max_group_prepared_capacity" {
  type        = number
  description = "Specifies the total maximum number of instances that are allowed to be in the warm pool or in any state except Terminated for the Auto Scaling group. Ignored when 'warm_pool_enabled' is false"
  default     = null
}

variable "reuse_on_scale_in" {
  type        = bool
  description = "Specifies whether instances in the Auto Scaling group can be returned to the warm pool on scale in."
  default     = "false"
}

variable "launch_template_version" {
  type        = string
  description = "Launch template version. Can be version number, `$Latest` or `$Default`"
  default     = "$Latest"
}

variable "target_tracking_metric" {
  type        = string
  description = "The AWS ASG pre-defined target tracking metric type. Service Edge recommends ASGAverageCPUUtilization"
  default     = "ASGAverageCPUUtilization"
  validation {
    condition = (
      var.target_tracking_metric == "ASGAverageCPUUtilization" ||
      var.target_tracking_metric == "ASGAverageNetworkIn" ||
      var.target_tracking_metric == "ASGAverageNetworkOut"
    )
    error_message = "Input target_tracking_metric must be set to an approved predefined metric."
  }
}

variable "target_cpu_util_value" {
  type        = number
  description = "Target value number for autoscaling policy CPU utilization target tracking. ie: trigger a scale in/out to keep average CPU Utliization percentage across all instances at/under this number"
  default     = 50
}

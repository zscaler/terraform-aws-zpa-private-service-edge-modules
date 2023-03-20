variable "name_prefix" {
  type        = string
  description = "A prefix to associate to all the Service Edge module resources"
  default     = null
}

variable "resource_tag" {
  type        = string
  description = "A tag to associate to all the Service Edge module resources"
  default     = null
}

variable "global_tags" {
  type        = map(string)
  description = "Populate any custom user defined tags from a map"
  default     = {}
}

variable "pse_subnet_ids" {
  type        = list(string)
  description = "Service Edge EC2 Instance subnet ID"
}

variable "instance_key" {
  type        = string
  description = "SSH Key for instances"
}

variable "user_data" {
  type        = string
  description = "Cloud init data"
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

variable "pse_count" {
  type        = number
  description = "Default number of Service Edge appliances to create"
  default     = 1
}

variable "security_group_id" {
  type        = list(string)
  description = "Service Edge EC2 Instance management subnet id"
}

variable "iam_instance_profile" {
  type        = list(string)
  description = "IAM instance profile ID assigned to Service Edge"
}

variable "associate_public_ip_address" {
  type        = bool
  description = "enable/disable public IP addresses on Service Edge instances. Setting this to true will result in the following: Dynamic Public IP address on the Service Edge VM Instance will be enabled; no EIP or NAT Gateway resources will be created; and the Service Edge Route Table default route next-hop will be set as the IGW"
  default     = false
}

variable "ami_id" {
  type        = list(string)
  description = "AMI ID(s) to be used for deploying Private Service Edge appliances. Ideally all VMs should be on the same AMI ID as templates always pull the latest from AWS Marketplace. This variable is provided if a customer desires to override/retain an old ami for existing deployments rather than upgrading and forcing a replacement. It is also inputted as a list to facilitate if a customer desired to manually upgrade select PSEs deployed based on the pse_count index"
  default     = [""]
}

variable "ebs_volume_type" {
  type        = string
  description = "(Optional) Type of volume. Valid values include standard, gp2, gp3, io1, io2, sc1, or st1. Defaults to gp3"
  default     = "gp3"
}

variable "encrypted_ebs_enabled" {
  type        = bool
  description = "true/false whether to encrypt root block ebs with default AWS KMS key"
  default     = true
}

variable "imdsv2_enabled" {
  type        = bool
  description = "true/false whether to force IMDSv2 only for instance bring up"
  default     = true
}

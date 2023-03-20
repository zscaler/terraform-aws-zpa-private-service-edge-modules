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
  description = "Service Edge EC2 Instance subnet IDs list"
}

variable "instance_key" {
  type        = string
  description = "SSH Key for instances"
}

variable "user_data" {
  type        = string
  description = "App Init data"
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

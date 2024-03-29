variable "name_prefix" {
  type        = string
  description = "A prefix to associate to all the Service Edge Security Group module resources"
  default     = null
}

variable "resource_tag" {
  type        = string
  description = "A tag to associate to all the Service Edge Security Group module resources"
  default     = null
}

variable "global_tags" {
  type        = map(string)
  description = "Populate any custom user defined tags from a map"
  default     = {}
}

variable "vpc_id" {
  type        = string
  description = "Service Edge VPC ID"
}

variable "sg_count" {
  type        = number
  description = "Default number of security groups to create"
  default     = 1
}

variable "byo_security_group" {
  type        = bool
  description = "Bring your own Security Group for Service Edge. Setting this variable to true will effectively instruct this module to not create any resources and only reference data resources from values provided in byo_mgmt_security_group_id and byo_service_security_group_id"
  default     = false
}

variable "byo_security_group_id" {
  type        = list(string)
  description = "Management Security Group ID for Service Edge association"
  default     = null
}

variable "associate_public_ip_address" {
  default     = false
  type        = bool
  description = "enable/disable public IP addresses on Service Edge instances. For Security Group Module, this variable determines whether the inbound HTTPS rules permit source VPC if private or source ANY (Internet) if public"
}

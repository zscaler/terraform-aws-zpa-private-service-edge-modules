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

variable "provisioning_key_name" {
  type        = string
  description = "Name of the provisioning key"
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
  description = "The maximum number of instances where this provisioning key can be used for enrolling an Service Edge or Service Edge"
}

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

variable "pse_group_id" {
  type        = string
  description = "ID of Service Edge Group from zpa-service-edge-group module"
  default     = null
}

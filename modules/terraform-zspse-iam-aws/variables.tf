variable "name_prefix" {
  type        = string
  description = "A prefix to associate to all the Service Edge IAM module resources"
  default     = null
}

variable "resource_tag" {
  type        = string
  description = "A tag to associate to all the Service Edge IAM module resources"
  default     = null
}

variable "global_tags" {
  type        = map(string)
  description = "Populate any custom user defined tags from a map"
  default     = {}
}

variable "iam_count" {
  type        = number
  description = "Default number IAM roles/policies/profiles to create"
  default     = 1
}

variable "byo_iam" {
  type        = bool
  description = "Bring your own IAM Instance Profile for Service Edge. Setting this variable to true will effectively instruct this module to not create any resources and only reference data resources from values provided in byo_iam_instance_profile_id"
  default     = false
}

variable "byo_iam_instance_profile_id" {
  type        = list(string)
  description = "Existing IAM Instance Profile IDs for Service Edge association"
  default     = null
}

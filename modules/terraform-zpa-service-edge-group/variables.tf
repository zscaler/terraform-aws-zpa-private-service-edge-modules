variable "pse_group_name" {
  type        = string
  description = "Name of the Private Service Edge Group"
}

variable "pse_group_description" {
  type        = string
  description = "Optional: Description of the Private Service Edge Group"
  default     = ""
}

variable "pse_group_enabled" {
  type        = bool
  description = "Whether this Private Service Edge Group is enabled or not"
  default     = true
}

variable "pse_group_country_code" {
  type        = string
  description = "Optional: Country code of this Private Service Edge Group. example 'US'"
  default     = ""
}

variable "pse_group_latitude" {
  type        = string
  description = "Latitude of the Private Service Edge Group. Integer or decimal. With values in the range of -90 to 90"
}

variable "pse_group_longitude" {
  type        = string
  description = "Longitude of the Private Service Edge Group. Integer or decimal. With values in the range of -90 to 90"
}

variable "pse_group_location" {
  type        = string
  description = "location of the Private Service Edge Group in City, State, Country format. example: 'San Jose, CA, USA'"
}

variable "pse_group_upgrade_day" {
  type        = string
  description = "Optional: Private Service Edges in this group will attempt to update to a newer version of the software during this specified day. Default value: SUNDAY. List of valid days (i.e., SUNDAY, MONDAY, etc)"
  default     = "SUNDAY"
}

variable "pse_group_upgrade_time_in_secs" {
  type        = string
  description = "Optional: Private Service Edges in this group will attempt to update to a newer version of the software during this specified time. Default value: 66600. Integer in seconds (i.e., 66600). The integer should be greater than or equal to 0 and less than 86400, in 15 minute intervals"
  default     = "66600"
}

variable "pse_group_override_version_profile" {
  type        = bool
  description = "Optional: Whether the default version profile of the Private Service Edge Group is applied or overridden. Default: false"
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

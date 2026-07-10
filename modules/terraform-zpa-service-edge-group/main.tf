################################################################################
# Retrieve the "Connector" enrollment certificate used for OAuth2 enrollment.
# This module exclusively onboards App Connectors of type "Connector", so the
# certificate name is intentionally hardcoded and not exposed as a variable.
################################################################################
# data "zpa_enrollment_cert" "connector" {
#   name = "Connector"
# }

################################################################################
# Retrieve the "Default" customer version profile. Only queried when the caller
# overrides the version profile (override_version_profile = true) without
# explicitly pinning a version_profile_id, in which case the module resolves the
# "Default" upgrade track automatically. Supported provider profiles for
# reference: "Default", "Previous Default", "New Release" (and *-el8 variants).
################################################################################
data "zpa_customer_version_profile" "default" {
  count = var.pse_group_override_version_profile && var.pse_group_version_profile_id == "" ? 1 : 0
  name  = "Default"
}

locals {
  # version_profile_id is Optional+Computed on zpa_service_edge_group. When the
  # version profile is NOT overridden, the API manages this value itself (it
  # returns "2"/New Release), so send null and let Terraform keep the computed
  # value. Pinning "0" here produces a perpetual "2" -> "0" idempotence diff.
  # When it IS overridden, honor an explicit caller value, otherwise fall back
  # to the resolved "Default" profile id.
  version_profile_id = (
    var.pse_group_override_version_profile == false ? null :
    var.pse_group_version_profile_id != "" ? var.pse_group_version_profile_id :
    data.zpa_customer_version_profile.default[0].id
  )
}

################################################################################
# Create ZPA Private Service Edge Group
################################################################################
# Create Private Service Edge Group
resource "zpa_service_edge_group" "service_edge_group" {
  name                     = var.pse_group_name
  description              = var.pse_group_description
  upgrade_day              = var.pse_group_upgrade_day
  upgrade_time_in_secs     = var.pse_group_upgrade_time_in_secs
  latitude                 = var.pse_group_latitude
  longitude                = var.pse_group_longitude
  location                 = var.pse_group_location
  version_profile_id       = local.version_profile_id
  override_version_profile = var.pse_group_override_version_profile
  enabled                  = var.pse_group_enabled
  country_code             = var.pse_group_country_code
  city_country             = var.pse_group_city_country
  is_public                = var.pse_is_public
  user_codes               = var.user_codes

  dynamic "trusted_networks" {
    for_each = var.zpa_trusted_network_name != "" ? [var.zpa_trusted_network_name] : []
    content {
      id = [data.zpa_trusted_network.zpa_trusted_network[0].id]
    }
  }
}

# ZPA Posture Profile Data Source
data "zpa_trusted_network" "zpa_trusted_network" {
  count = var.zpa_trusted_network_name != "" ? 1 : 0
  name  = var.zpa_trusted_network_name
}

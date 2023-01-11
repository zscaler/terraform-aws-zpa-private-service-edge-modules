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
  version_profile_id       = var.pse_group_version_profile_id
  override_version_profile = var.pse_group_override_version_profile
  enabled                  = var.pse_group_enabled
  country_code             = var.pse_group_country_code
  is_public                = var.pse_is_public

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

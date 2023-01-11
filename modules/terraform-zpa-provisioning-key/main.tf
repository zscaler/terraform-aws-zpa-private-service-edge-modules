################################################################################
# Create ZPA Service Edge Provisioning Key
################################################################################
# Retrieve Connector Enrollment Cert ID
data "zpa_enrollment_cert" "connector_cert" {
  name = var.enrollment_cert
}

# Create Service Edge provisioning key
resource "zpa_provisioning_key" "provisioning_key" {
  count              = var.byo_provisioning_key == false ? 1 : 0
  name               = var.provisioning_key_name
  enabled            = var.provisioning_key_enabled
  association_type   = var.provisioning_key_association_type
  max_usage          = var.provisioning_key_max_usage
  enrollment_cert_id = data.zpa_enrollment_cert.connector_cert.id
  zcomponent_id      = var.pse_group_id
}

# Or use existing Provisioning Key if specified in byo_provisioning_key_name
data "zpa_provisioning_key" "provisioning_key_selected" {
  name             = var.byo_provisioning_key == false ? zpa_provisioning_key.provisioning_key[0].name : var.byo_provisioning_key_name
  association_type = var.provisioning_key_association_type
}

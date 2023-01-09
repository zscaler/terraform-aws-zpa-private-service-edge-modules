output "provisioning_key" {
  description = "ZPA Provisioning Key Output"
  value       = data.zpa_provisioning_key.provisioning_key_selected.provisioning_key
}

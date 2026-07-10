locals {

  testbedconfig = <<TB


VPC:         
${module.network.vpc_id}

All PSE AZs:
${join("\n", distinct(module.pse_vm.availability_zone))}

All PSE Instance IDs:
${join("\n", module.pse_vm.id)}

All PSE Private IPs:
${join("\n", module.pse_vm.private_ip)}

All PSE Elastic IP IDs (if EIPs created):
${join("\n", module.pse_vm.eip_id)}

All PSE Public IPs (if EIPs created):
${join("\n", module.pse_vm.eip_public_ip)}

All NAT GW IPs (if no EIPs created):
${join("\n", module.network.nat_gateway_ips)}

All PSE IAM Role ARNs:
${join("\n", module.pse_iam.iam_instance_profile_arn)}

TB
}

output "testbedconfig" {
  description = "AWS Testbed results"
  value       = local.testbedconfig
}


resource "local_file" "testbed" {
  content  = local.testbedconfig
  filename = "../testbed.txt"
}

################################################################################
# Onboarding Outputs
################################################################################
output "onboarding_method" {
  description = "Onboarding method used for this deployment (oauth or provisioning_key)"
  value       = local.use_provisioning_key ? "provisioning_key" : "oauth"
}

output "oauth_user_codes" {
  description = "OAuth2 user codes retrieved from SSM Parameter Store (empty when using the provisioning key flow). Use 'terraform output -json oauth_user_codes | jq -r' to view."
  value       = local.user_codes
  sensitive   = true
}

output "service_edge_group_id" {
  description = "ZPA Service Edge Group ID"
  value       = local.use_provisioning_key ? try(module.zpa_service_edge_group_pk[0].service_edge_group_id, "") : try(module.zpa_service_edge_group[0].service_edge_group_id, "")
}

output "ssm_parameter_names" {
  description = "SSM Parameter Store paths where OAuth tokens are stored (managed by Terraform, updated by VMs). Empty when using the provisioning key flow."
  value       = local.ssm_parameter_names
}

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

All PSE Public IPs:
${join("\n", module.pse_vm.public_ip)}

All NAT GW IPs:
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

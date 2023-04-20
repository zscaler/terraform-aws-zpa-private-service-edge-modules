locals {

  testbedconfig = <<TB

1) Copy the SSH key to the bastion host
scp -i ${var.name_prefix}-key-${random_string.suffix.result}.pem ${var.name_prefix}-key-${random_string.suffix.result}.pem ec2-user@${module.bastion.public_dns}:/home/ec2-user/.

2) SSH to the bastion host
ssh -i ${var.name_prefix}-key-${random_string.suffix.result}.pem ec2-user@${module.bastion.public_dns}

3) SSH to the Private Service Edge
ssh -i ${var.name_prefix}-key-${random_string.suffix.result}.pem admin@${module.pse_vm.private_ip[0]} -o "proxycommand ssh -W %h:%p -i ${var.name_prefix}-key-${random_string.suffix.result}.pem ec2-user@${module.bastion.public_dns}"

All PSE Private IPs. Replace private IP below with admin@"ip address" in ssh example command above. ec2-user@"ip address" for AL2 AMI deployments
${join("\n", module.pse_vm.private_ip)}

VPC:         
${module.network.vpc_id}

All PSE AZs:
${join("\n", distinct(module.pse_vm.availability_zone))}

All PSE Instance IDs:
${join("\n", module.pse_vm.id)}

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

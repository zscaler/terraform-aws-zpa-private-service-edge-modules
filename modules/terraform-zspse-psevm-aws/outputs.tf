output "private_ip" {
  description = "Instance Private IP Address"
  value       = aws_instance.pse_vm[*].private_ip
}

output "availability_zone" {
  description = "Instance Availability Zone"
  value       = aws_instance.pse_vm[*].availability_zone
}

output "id" {
  description = "Instance ID"
  value       = aws_instance.pse_vm[*].id
}

output "eip_public_ip" {
  description = "Instance Elastic Public IP"
  value       = var.associate_public_ip_address ? aws_eip.pse_eip[*].public_ip : [""]
}

output "eip_id" {
  description = "Contains the EIP allocation ID"
  value       = var.associate_public_ip_address ? aws_eip.pse_eip[*].id : [""]
}

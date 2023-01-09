output "pse_security_group_id" {
  description = "Service Edge Security Group ID"
  value       = data.aws_security_group.pse_sg_selected[*].id
}

output "pse_security_group_arn" {
  description = "Service Edge Security Group ARN"
  value       = data.aws_security_group.pse_sg_selected[*].arn
}

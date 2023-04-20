output "pse_security_group_id" {
  description = "Service Edge Security Group ID"
  value       = var.byo_security_group ? data.aws_security_group.pse_sg_selected[*].id : aws_security_group.pse_sg[*].id
}

output "pse_security_group_arn" {
  description = "Service Edge Security Group ARN"
  value       = var.byo_security_group ? data.aws_security_group.pse_sg_selected[*].arn : aws_security_group.pse_sg[*].arn
}

output "iam_instance_profile_id" {
  description = "Service Edge IAM Instance Profile Name"
  value       = data.aws_iam_instance_profile.pse_host_profile_selected[*].name
}

output "iam_instance_profile_arn" {
  description = "Service Edge IAM Instance Profile ARN"
  value       = data.aws_iam_instance_profile.pse_host_profile_selected[*].arn
}

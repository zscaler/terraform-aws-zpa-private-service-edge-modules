output "availability_zone" {
  description = "Auto Scaling Group Availability Zones Output"
  value       = aws_autoscaling_group.pse_asg.availability_zones
}

output "autoscaling_group_name" {
  description = "Name of the Private Service Edge Auto Scaling Group"
  value       = aws_autoscaling_group.pse_asg.name
}

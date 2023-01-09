output "availability_zone" {
  description = "Auto Scaling Group Availability Zones Output"
  value       = aws_autoscaling_group.pse_asg.availability_zones
}

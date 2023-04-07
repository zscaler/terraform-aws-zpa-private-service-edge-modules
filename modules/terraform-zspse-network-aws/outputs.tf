output "vpc_id" {
  description = "VPC ID Selected"
  value       = try(data.aws_vpc.vpc_selected[0].id, aws_vpc.vpc[0].id)
}

output "pse_subnet_ids" {
  description = "Service Edge Subnet IDs"
  value       = data.aws_subnet.pse_subnet_selected[*].id
}

output "public_subnet_ids" {
  description = "Public Subnet IDs"
  value       = aws_subnet.public_subnet[*].id
}

output "nat_gateway_ips" {
  description = "NAT Gateway Public IPs"
  value       = data.aws_nat_gateway.ngw_selected[*].public_ip
}

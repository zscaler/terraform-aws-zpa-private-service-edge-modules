################################################################################
# Network Infrastructure Resources
################################################################################
# Identify availability zones available for region selected
data "aws_availability_zones" "available" {
  state = "available"
}


################################################################################
# VPC
################################################################################
# Create a new VPC
resource "aws_vpc" "vpc" {
  count                = var.byo_vpc == false ? 1 : 0
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = merge(var.global_tags,
    { Name = "${var.name_prefix}-vpc-${var.resource_tag}" }
  )
}

# Or reference an existing VPC
data "aws_vpc" "vpc_selected" {
  id = var.byo_vpc == false ? aws_vpc.vpc[0].id : var.byo_vpc_id
}


################################################################################
# Internet Gateway
################################################################################
# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  count  = var.byo_igw == false ? 1 : 0
  vpc_id = data.aws_vpc.vpc_selected.id

  tags = merge(var.global_tags,
    { Name = "${var.name_prefix}-igw-${var.resource_tag}" }
  )
}

# Or reference an existing Internet Gateway
data "aws_internet_gateway" "igw_selected" {
  internet_gateway_id = var.byo_igw == false ? aws_internet_gateway.igw[0].id : var.byo_igw_id
}


################################################################################
# NAT Gateway
################################################################################
# Create NAT Gateway and assign EIP per AZ. This will not be created if var.byo_ngw is set to True
# or if Service Edges are assigned public IP addresses directly with no bastion host creation
resource "aws_eip" "eip" {
  count      = var.byo_ngw == false && var.associate_public_ip_address == false || var.associate_public_ip_address == false && var.bastion_deploy == false || var.associate_public_ip_address == true && var.bastion_deploy == true ? length(aws_subnet.public_subnet[*].id) : 0
  vpc        = true
  depends_on = [data.aws_internet_gateway.igw_selected]

  tags = merge(var.global_tags,
    { Name = "${var.name_prefix}-eip-az${count.index + 1}-${var.resource_tag}" }
  )
}

# Create 1 NAT Gateway per Public Subnet.
resource "aws_nat_gateway" "ngw" {
  count         = var.byo_ngw == false && var.associate_public_ip_address == false || var.associate_public_ip_address == false && var.bastion_deploy == false || var.associate_public_ip_address == true && var.bastion_deploy == true ? length(aws_subnet.public_subnet[*].id) : 0
  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id
  depends_on    = [data.aws_internet_gateway.igw_selected]

  tags = merge(var.global_tags,
    { Name = "${var.name_prefix}-natgw-az${count.index + 1}-${var.resource_tag}" }
  )
}

# Or reference existing NAT Gateways
data "aws_nat_gateway" "ngw_selected" {
  count = var.byo_ngw == false ? length(aws_nat_gateway.ngw[*].id) : length(var.byo_ngw_ids)
  id    = var.byo_ngw == false ? aws_nat_gateway.ngw[count.index].id : element(var.byo_ngw_ids, count.index)
}


################################################################################
# Public (NAT Gateway) Subnet & Route Tables
################################################################################
# Create equal number of Public/NAT Subnets to how many Service Edge subnets exist. This will not be created if var.byo_ngw is set to True
# or if Service Edges are assigned public IP addresses directly with no bastion host creation
resource "aws_subnet" "public_subnet" {
  count             = var.byo_ngw == false && var.associate_public_ip_address == false || var.associate_public_ip_address == false && var.bastion_deploy == false || var.associate_public_ip_address == true && var.bastion_deploy == true ? length(data.aws_subnet.pse_subnet_selected[*].id) : 0
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.public_subnets != null ? element(var.public_subnets, count.index) : cidrsubnet(data.aws_vpc.vpc_selected.cidr_block, 8, count.index + 101)
  vpc_id            = data.aws_vpc.vpc_selected.id

  tags = merge(var.global_tags,
    { Name = "${var.name_prefix}-public-subnet-${count.index + 1}-${var.resource_tag}" }
  )
}


# Create a public Route Table towards IGW. This will not be created if var.byo_ngw is set to True
# or if Service Edges are assigned public IP addresses directly with no bastion host creation
resource "aws_route_table" "public_rt" {
  count  = var.byo_ngw == false && var.associate_public_ip_address == false || var.associate_public_ip_address == false && var.bastion_deploy == false || var.associate_public_ip_address == true && var.bastion_deploy == true ? 1 : 0
  vpc_id = data.aws_vpc.vpc_selected.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.igw_selected.internet_gateway_id
  }

  tags = merge(var.global_tags,
    { Name = "${var.name_prefix}-public-rt-${var.resource_tag}" }
  )
}


# Create equal number of Route Table associations to how many Public subnets exist. This will not be created if var.byo_ngw is set to True
# or if Service Edges are assigned public IP addresses directly with no bastion host creation
resource "aws_route_table_association" "public_rt_association" {
  count          = var.byo_ngw == false && var.associate_public_ip_address == false || var.associate_public_ip_address == false && var.bastion_deploy == false || var.associate_public_ip_address == true && var.bastion_deploy == true ? length(aws_subnet.public_subnet[*].id) : 0
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt[0].id
}


################################################################################
# Private (Service Edge) Subnet & Route Tables
################################################################################
# Create subnet for PSE network in X availability zones per az_count variable
resource "aws_subnet" "pse_subnet" {
  count = var.byo_subnets == false ? var.az_count : 0

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.pse_subnets != null ? element(var.pse_subnets, count.index) : cidrsubnet(data.aws_vpc.vpc_selected.cidr_block, 8, count.index + 200)
  vpc_id            = data.aws_vpc.vpc_selected.id

  tags = merge(var.global_tags,
    { Name = "${var.name_prefix}-pse-subnet-${count.index + 1}-${var.resource_tag}" }
  )
}

# Or reference existing subnets
data "aws_subnet" "pse_subnet_selected" {
  count = var.byo_subnets == false ? var.az_count : length(var.byo_subnet_ids)
  id    = var.byo_subnets == false ? aws_subnet.pse_subnet[count.index].id : element(var.byo_subnet_ids, count.index)
}


# Create Route Tables for PSE subnets pointing to NAT Gateway resource in each AZ or however many were specified. Optionally, point directly to IGW for public deployments
resource "aws_route_table" "pse_rt" {
  count  = length(data.aws_subnet.pse_subnet_selected[*].id)
  vpc_id = data.aws_vpc.vpc_selected.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.associate_public_ip_address == false ? element(data.aws_nat_gateway.ngw_selected[*].id, count.index) : null
    gateway_id     = var.associate_public_ip_address == true ? data.aws_internet_gateway.igw_selected.internet_gateway_id : null
  }

  tags = merge(var.global_tags,
    { Name = "${var.name_prefix}-pse-rt-${count.index + 1}-${var.resource_tag}" }
  )
}

# AC subnet Route Table Association
resource "aws_route_table_association" "pse_rt_association" {
  count          = length(data.aws_subnet.pse_subnet_selected[*].id)
  subnet_id      = data.aws_subnet.pse_subnet_selected[count.index].id
  route_table_id = aws_route_table.pse_rt[count.index].id
}

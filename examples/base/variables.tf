variable "aws_region" {
  type        = string
  description = "The AWS region."
  default     = "us-west-2"
}

variable "name_prefix" {
  type        = string
  description = "The name prefix for all your resources"
  default     = "zsdemo"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC IP CIDR Range. All subnet resources that might get created (public / service edge) are derived from this /16 CIDR. If you require creating a VPC smaller than /16, you may need to explicitly define all other subnets via public_subnets and pse_subnets variables"
  default     = "10.1.0.0/16"
}

variable "public_subnets" {
  type        = list(string)
  description = "Public/NAT GW Subnets to create in VPC. This is only required if you want to override the default subnets that this code creates via vpc_cidr variable."
  default     = null
}

variable "az_count" {
  type        = number
  description = "Default number of subnets to create based on availability zone"
  default     = 1
  validation {
    condition = (
      (var.az_count >= 1 && var.az_count <= 3)
    )
    error_message = "Input az_count must be set to a single value between 1 and 3. Note* some regions have greater than 3 AZs. Please modify az_count validation in variables.tf if you are utilizing more than 3 AZs in a region that supports it. https://aws.amazon.com/about-aws/global-infrastructure/regions_az/."
  }
}

variable "owner_tag" {
  type        = string
  description = "populate custom owner tag attribute"
  default     = "zspse-admin"
}

variable "tls_key_algorithm" {
  type        = string
  description = "algorithm for tls_private_key resource"
  default     = "RSA"
}

variable "bastion_nsg_source_prefix" {
  type        = list(string)
  description = "CIDR blocks of trusted networks for bastion host ssh access"
  default     = ["0.0.0.0/0"]
}

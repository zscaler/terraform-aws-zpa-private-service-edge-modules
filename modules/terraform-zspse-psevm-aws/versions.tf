terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.59.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.0"
    }
  }
  required_version = ">= 0.13.7, < 2.0.0"
}

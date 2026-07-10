terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.54.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3.0"
    }
    zpa = {
      source  = "zscaler/zpa"
      version = ">= 4.4.0"
    }
  }

  required_version = ">= 0.13.7, < 2.0.0"
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region

  # Ignore account-managed governance tags so subsequent plans stay idempotent.
  ignore_tags {
    keys = [
      "acctowner",
      "area",
      "costcenter",
      "domain",
      "envtype",
      "jiraname",
      "opsteam",
      "subarea",
    ]
  }
}

provider "zpa" {
}

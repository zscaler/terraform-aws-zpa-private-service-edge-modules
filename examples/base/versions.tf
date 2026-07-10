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
  }

  required_version = ">= 0.13.7, < 2.0.0"
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region

  # Some AWS accounts enforce Organization tag policies that automatically
  # attach governance tags (cost center, owner, environment, etc.) to created
  # resources. Terraform does not manage these tags, so without ignore_tags it
  # detects them as drift on subsequent plans and the apply is non-idempotent.
  # Ignoring these account-managed tag keys keeps plans clean.
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

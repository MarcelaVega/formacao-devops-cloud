terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.69"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = var.provider-param.region
  profile = var.provider-param.profile
}
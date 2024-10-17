# Define the version of the AWS provider required
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider with Stockholm region
provider "aws" {
  region = "eu-north-1"
}
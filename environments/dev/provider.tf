terraform {
  required_providers {
    aws = {
      source   = "hashicorp/aws"
      version = "~> 3.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.4.3"
    }
    archive = {
      source = "hashicorp/archive"
      version = "2.3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::0123456789:role/CloudFormationAdminRole"
  }
}

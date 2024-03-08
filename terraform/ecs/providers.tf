terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.39.1"
    }
  }
}

provider "aws" {
  region = var.aws-region
  access_key = var.aws-access-key
  secret_key = var.aws-secret-key
}
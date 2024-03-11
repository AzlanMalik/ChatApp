terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.39.1"
    }
  }

  backend "s3" {
    bucket               = "terraform-state-bucket-007"
    key                  = "terraform.tfstate"
    workspace_key_prefix = "chatapp/workspaces"
    region               = "us-east-1"
    dynamodb_table       = "terraform-state-lock"
    encrypt              = true
  }
}

provider "aws" {
  region     = var.aws-region
  access_key = var.aws-access-key
  secret_key = var.aws-secret-key
}
# AWS Multi-Resource Infrastructure
# VPC, Subnets, Route Tables, EKS, S3, RDS

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = "devops-multicloud"
      ManagedBy   = "Terraform"
    }
  }
}

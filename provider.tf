terraform {
  required_version = "~> 1.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
# The archive provider is used to package the Lambda function code.                   # It creates a ZIP archive of the specified source files.
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

# Tags to be applied to all resources created by this provider.
  default_tags {
    tags = {
      ManagedBy = "Terraform"
      Project   = "17-proj-import-lambda"
    }
  }
}
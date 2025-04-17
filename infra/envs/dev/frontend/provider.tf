terraform {
  required_version = ">=0.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.90.1"
    }
  }

  # backendだけは変数が使えない
  backend "s3" {
    bucket         = "seitotest-tfstate-bucket"
    key            = "dev/frontend/terraform.tfstate"
    encrypt        = true
    region         = "us-west-2"
    dynamodb_table = "seitotest-tfstate-lock"
  }
}

provider "aws" {
  profile = "terraform"
  region  = var.region
}
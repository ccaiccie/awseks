terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.72.0"
    }
  }

  # This stack uses only the AWS provider. Kubernetes and Helm live in
  # 03-platform and 04-karpenter so a plan here does not need a live API.
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = local.tags
  }
}

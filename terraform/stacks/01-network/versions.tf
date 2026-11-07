terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.72.0"
    }
  }

  # Local state is the lab default so a first apply does not need a remote
  # backend. terraform.tfstate is gitignored. See backend.s3.hcl.example
  # before you migrate. Never commit state.
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

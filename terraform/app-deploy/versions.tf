terraform {
  required_version = ">= 0.14.9"
  required_providers {
    aws = {
      version = "~> 3.27"
      source  = "hashicorp/aws"
    }

    random = {
      version = "~> 2"
      source  = "hashicorp/random"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-emperia-pdp"
    key            = "terra-backend/terraform.tfstate"
    encrypt        = true
    region         = "eu-west-2"
  }
}

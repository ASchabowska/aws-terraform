terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.63"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./vpc"
  aws_region = var.aws_region
}

module "lambda" {
  source = "./lambda"
  vpc_id = module.vpc.vpc_id
  vpc_subnet_id = module.vpc.private_subnet_id
}
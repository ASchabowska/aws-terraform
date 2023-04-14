terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-west-2"
}

resource "aws_vpc" "main" { 
    cidr_block       = "10.0.0.0/16"   
    instance_tenancy = "default"   
    tags = {     
        Name = "main"   
    } 
}

resource "aws_subnet" "public_subnet" {
 vpc_id     = aws_vpc.main.id
 cidr_block = "10.0.1.0/24"
 
 tags = {
   Name = "Public Subnet"
 }
}
 
resource "aws_subnet" "private_subnet" {
 vpc_id     = aws_vpc.main.id
 cidr_block = "10.0.2.0/24"
 
 tags = {
   Name = "Private Subnet"
 }
}

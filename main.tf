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
  region  = "us-west-2"
}

resource "aws_vpc" "main" { 
    cidr_block       = "10.0.0.0/16"   
    instance_tenancy = "default"   
    tags = {     
        Name = "main"   
    } 
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main gateway"
  }
}
 
resource "aws_subnet" "private_subnet" {
 vpc_id     = aws_vpc.main.id
 cidr_block = "10.0.2.0/24"
 
 tags = {
   Name = "private subnet"
 }
}

resource "aws_subnet" "public_subnet" {
 vpc_id     = aws_vpc.main.id
 cidr_block = "10.0.1.0/24"
 
 tags = {
   Name = "public subnet"
 }
}

resource "aws_eip" "nat_eip" {
  vpc      = true
  tags = {
    "Name" = "gateway eip"
  }
}

resource "aws_nat_gateway" "public_nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "public nat gateway"
  }
  depends_on = [aws_internet_gateway.gateway]
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.us-west-2.ssm"

  tags = {
    Environment = "ssm endpoint"
  }
}

resource "aws_vpc_endpoint" "sm" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.us-west-2.secretsmanager"

  tags = {
    Environment = "sm endpoint"
  }
}

resource "aws_vpc_endpoint" "event_bridge" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.us-west-2.eventbridge"

  tags = {
    Environment = "event bridge endpoint"
  }
}
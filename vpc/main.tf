resource "aws_vpc" "main" { 
    cidr_block       = var.vpc_cidr 
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
 cidr_block = var.private_subnet_cidr 
 
 tags = {
   Name = "private subnet"
 }
}

resource "aws_subnet" "public_subnet" {
 vpc_id     = aws_vpc.main.id
 cidr_block = var.public_subnet_cidr 
 
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

output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}
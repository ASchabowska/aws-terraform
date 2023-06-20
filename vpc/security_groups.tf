resource "aws_security_group" "eventbridge_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
  from_port        = 0
  to_port          = 0
  protocol         = "-1"
  # TO DO: change to eventbridge cidr
  cidr_blocks      = ["0.0.0.0/0"]
}
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.private_subnet_cidr]
  }
}

resource "aws_security_group" "ssm_sg" {
  vpc_id = aws_vpc.main.id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    # TO DO: add ssm cidr
    cidr_blocks      = [var.private_subnet_cidr]
  }
}
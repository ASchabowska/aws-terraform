resource "aws_vpc_endpoint" "ssm" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids = [aws_subnet.private_subnet.id]
  security_group_ids = [aws_security_group.ssm_sg.id]
  private_dns_enabled = false

  tags = {
    Environment = "ssm endpoint"
  }
}

# default security group
resource "aws_vpc_endpoint" "sm" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type = "Interface"
  subnet_ids = [aws_subnet.private_subnet.id]
  private_dns_enabled = false

  tags = {
    Environment = "sm endpoint"
  }
}

resource "aws_vpc_endpoint" "event_bridge" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.aws_region}.events"
  vpc_endpoint_type = "Interface"
  subnet_ids = [aws_subnet.private_subnet.id]
  security_group_ids = [aws_security_group.eventbridge_sg.id]
  private_dns_enabled = false

  tags = {
    Environment = "event bridge endpoint"
  }
}
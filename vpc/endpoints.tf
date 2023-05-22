resource "aws_vpc_endpoint" "ssm" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type = "Interface"
  policy = data.aws_iam_policy_document.endpoint_policy.json
  private_dns_enabled = true

  tags = {
    Environment = "ssm endpoint"
  }
}

resource "aws_vpc_endpoint" "sm" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type = "Interface"
  policy = data.aws_iam_policy_document.endpoint_policy.json
  private_dns_enabled = true

  tags = {
    Environment = "sm endpoint"
  }
}

resource "aws_vpc_endpoint" "event_bridge" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.aws_region}.eventbridge"
  vpc_endpoint_type = "Interface"
  policy = data.aws_iam_policy_document.endpoint_policy.json
  private_dns_enabled = true

  tags = {
    Environment = "event bridge endpoint"
  }
}

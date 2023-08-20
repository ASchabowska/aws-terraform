resource "aws_iam_role" "sm_lambda_role" {
 name   = "aws_sm_lambda_role"
 assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
managed_policy_arns = [
    aws_iam_policy.iam_policy_for_sm_lambda.arn,
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
}

# IAM policy for logging from a lambda
resource "aws_iam_policy" "iam_policy_for_sm_lambda" {

  name         = "aws_iam_policy_for_aws_sm_lambda_role"
  path         = "/"
  description  = "AWS IAM Policy for managing aws sm lambda role"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "secretsmanager:GetSecretValue"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_sm_lambda_role" {
  role        = aws_iam_role.sm_lambda_role.name
  policy_arn  = aws_iam_policy.iam_policy_for_sm_lambda.arn
}

resource "aws_security_group" "vpc_sm_lambda" {
  name        = "sm-lambda-sg"
  description = "Allow outbound traffic for sm-lambda"
  vpc_id      = var.vpc_id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
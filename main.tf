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

# VPC, subnets, gateways

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

# VPC endpoints

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

# LAMBDAS

resource "aws_security_group" "lambda_group" {
  name_prefix = "lambda-sg"
  vpc_id = aws_vpc.main.id
 
  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["10.0.2.0/24"]
  }
 
  egress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_iam_policy" "lambda_basic_execution_role_policy" {
  name = "AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "lambda_event_iam_role" {
  name_prefix         = "EventBridgeLambdaRole-"
  managed_policy_arns = [data.aws_iam_policy.lambda_basic_execution_role_policy.arn]

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
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_lambda_function" "lambda_function1" {
   function_name    = "lambda1"
   role             = aws_iam_role.iam_for_lambda.arn
   filename         = "../file1"
   handler          = "index.lambda_handler"
   runtime          = "python3.8"

   vpc_config {
       subnet_ids = [aws_subnet.public_subnet.id]
       security_group_ids = [aws_security_group.lambda_group.id]
   }
 }

 resource "aws_lambda_function" "lambda_function2" {
   function_name    = "lambda2"
   role             = aws_iam_role.lambda_event_iam_role.arn
   filename         = "../file2"
   handler          = "index.lambda_handler"
   runtime          = "python3.8"

   vpc_config {
       subnet_ids = [aws_subnet.public_subnet.id]
       security_group_ids = [aws_security_group.lambda_group.id]
   }
 }

# SECRET MANAGER

 module "secrets-manager" {

  source = "lgallard/secrets-manager/aws"

  secrets = {
    secret-1 = {
      description             = "My secret 1"
      recovery_window_in_days = 7
      secret_string           = "This is an example"
    },
    secret-2 = {
      description             = "My secret 2"
      recovery_window_in_days = 7
      secret_string           = "This is another example"
    }
  }

  tags = {
    Owner       = "DevOps team"
    Environment = "dev"
    Terraform   = true

  }
}

# EVENT BRIDGE

resource "aws_cloudwatch_event_rule" "event_rule" {
	name_prefix = "eventbridge-lambda-"
  event_pattern = <<EOF
{
  "detail-type": ["transaction"],
  "source": ["custom.myApp"],
  "detail": {
	"location": [{
	  "prefix": "EUR-"
	}]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "target_lambda_function" {
  rule = aws_cloudwatch_event_rule.event_rule.name
  arn  = aws_lambda_function.lambda_function2.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function2.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.event_rule.arn
}

module "eventbridge" {
  source = "terraform-aws-modules/eventbridge/aws"

  create_bus = false

  rules = {
    crons = {
      description         = "Trigger for a Lambda"
      schedule_expression = "rate(5 minutes)"
    }
  }

  targets = {
    crons = [
      {
        name  = "lambda-event"
        arn   = "arn:aws:lambda:ap-southeast-1:135367859851:function:resolved-penguin-lambda"
        input = jsonencode({"job": "cron-by-rate"})
      }
    ]
  }
}

# SYSTEM MANAGER
module "ssm" {
  source = "../../"

  name = "system-manager"

  operating_system                     = "AMAZON_LINUX_2"
  approved_patches_compliance_level    = "CRITICAL"
  approved_patches_enable_non_security = false

  approval_rules = [{
    approve_after_days  = 7
    compliance_level    = "CRITICAL"
    enable_non_security = false
    patch_filters = [
      { key = "PRODUCT", values = ["AmazonLinux2"] },
      { key = "CLASSIFICATION", values = ["Security", "Bugfix"] },
      { key = "SEVERITY", values = ["Critical", "Important"] }
    ]
  }]

  maintenance_window = {
    enabled           = true
    schedule          = "cron(0 9 */7 * ?)"
    schedule_timezone = "UTC"
    cutoff            = 0
    duration          = 1
  }
}
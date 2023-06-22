# resource "aws_security_group" "lambda_group" {
#   name_prefix = "lambda-sg"
#   vpc_id = aws_vpc.main.id
 
#   ingress {
#     from_port = 0
#     to_port = 65535
#     protocol = "tcp"
#     cidr_blocks = ["10.0.2.0/24"]
#   }
 
#   egress {
#     from_port = 0
#     to_port = 65535
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

data "archive_file" "zip_python_code" {
 type        = "zip"
 source_dir  = "${path.module}/scripts/"
 output_path = "${path.module}/scripts/hello_world.zip"
}

data "archive_file" "zip_sm_lambda_function" {
 type        = "zip"
 source_dir  = "${path.module}/scripts/"
 output_path = "${path.module}/scripts/sm_lambda_function.zip"
}

resource "aws_lambda_function" "terraform_lambda_func" {
 filename                       = "${path.module}/scripts/hello_world.zip"
 function_name                  = "Lambda-Function"
 role                           = aws_iam_role.lambda_role.arn
 handler                        = "hello_world.lambda_handler"
 runtime                        = "python3.8"
 depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}

resource "aws_lambda_function" "terraform_sm_lambda_func" {
 filename                       = "${path.module}/scripts/sm_lambda_function.zip"
 function_name                  = "SM-Lambda-Function"
 role                           = aws_iam_role.sm_lambda_role.arn
 handler                        = "sm_lambda_function.lambda_handler"
 runtime                        = "python3.9"
 depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_sm_lambda_role]
}
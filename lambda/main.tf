data "archive_file" "zip_code" {
 for_each    = toset(var.lambda_functions)
 type        = "zip"
 source_dir  = "${path.module}/scripts/"
 output_path = "${path.module}/scripts/${each.value}_function.zip"
}

resource "aws_lambda_function" "terraform_lambda_func" {
 for_each    = toset(var.lambda_functions)
 filename                       = "${path.module}/scripts/${each.value}_function.zip"
 function_name                  = "${each.value}"
 role                           = aws_iam_role.lambda_role.arn
 handler                        = "${each.value}_function.lambda_handler"
 runtime                        = "python3.8"
 depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
 vpc_config {
   security_group_ids = [aws_security_group.vpc_lambda.id]
   subnet_ids         = [var.vpc_subnet_id]
 }
}
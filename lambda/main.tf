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
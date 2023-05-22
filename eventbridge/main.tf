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
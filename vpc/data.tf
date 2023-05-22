data "aws_iam_policy_document" "endpoint_policy" {
  statement {
    actions = ["*"]
    effect = "Allow"
    resources = ["*"]
  }
}
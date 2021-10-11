data "aws_iam_policy_document" "lambda_exec_assume_role_policy" {
  statement {
    sid     = "lambda-exec-assume-role-policy"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["lambda.amazonaws.com"]
    }

  }
}

data "aws_iam_policy_document" "read_s3_bucket" {
  statement {
    sid = "1"

    actions = [
      "s3:*"
    ]

    resources = [
      "arn:aws:s3:::${var.bucket_name}"
    ]
  }
}

data "aws_iam_policy_document" "lambda_execution_policy" {
  source_policy_documents = [
    data.aws_iam_policy_document.read_s3_bucket.json
  ]
}

resource "aws_iam_role" "lambda_execution_role" {
  name               = "${var.app_name}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_exec_assume_role_policy.json
}

resource "aws_iam_policy" "lambda_execution_role_policy" {
  name = "${var.app_name}-execution-role-policy"
  path = "/"

  policy = data.aws_iam_policy_document.lambda_execution_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_execution_role_attachment" {
  role       = aws_iam_role.lambda_execution_role.arn
  policy_arn = aws_iam_policy.lambda_execution_role_policy.arn
}
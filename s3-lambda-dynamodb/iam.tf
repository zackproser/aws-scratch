data "aws_iam_policy_document" "lambda_exec_assume_role_policy" {
  statement {
    sid     = "LambdaExecAssumeRolePolicy"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
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

data "aws_iam_policy_document" "lambda_policy_doc" {
  statement {
    sid = "AllowCreatingLogGroups"

    actions = ["logs:CreateLogGroup"]

    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    sid = "AllowWritingLogs"

    actions = ["logs:CreateLogStream", "logs:PutLogEvents"]

    resources = ["arn:aws:logs:*:*:log-group:/aws/lambda/*:*"]
  }
}

data "aws_iam_policy_document" "lambda_execution_policy" {
  source_policy_documents = [
    data.aws_iam_policy_document.read_s3_bucket.json,
    data.aws_iam_policy_document.lambda_policy_doc.json
  ]
}

resource "aws_iam_role" "lambda_execution_role" {
  name               = "LambdaExecutionRole"
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

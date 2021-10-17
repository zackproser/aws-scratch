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

data "aws_iam_policy_document" "lambda_s3_policy" {
  statement {
    sid = "ListSourceBucket"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::${var.bucket_name}"
    ]
  }

  statement {
    sid = "AllObjectActions"

    actions = [
      "s3:*Object*"
    ]

    resources = [
      "arn:aws:s3:::${var.bucket_name}/*"
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
    data.aws_iam_policy_document.lambda_s3_policy.json,
    data.aws_iam_policy_document.lambda_policy_doc.json
  ]
}

data "aws_iam_policy_document" "s3_notification_queue_doc" {
  statement {
    sid = "S3NotificationQueuePolicy"

    actions = ["sqs:SendMessage"]

    resources = ["arn:aws:sns:*:*:s3-event-notification-topic"]

    condition {
      test     = "ArnEquals"
      values   = ["${aws_s3_bucket.source_bucket.arn}"]
      variable = "aws:SourceArn"
    }
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name               = "LambdaExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.lambda_exec_assume_role_policy.json
}

resource "aws_iam_policy" "lambda_execution_role_policy" {
  name = "LambdaExecutionRolePolicy"
  path = "/"

  policy = data.aws_iam_policy_document.lambda_execution_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_execution_role_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_execution_role_policy.arn
}

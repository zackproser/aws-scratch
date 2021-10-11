terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}



resource "aws_lambda_function" "url_reader" {
  function_name = "${var.app_name}-function"
  filename      = "./python"
  runtime       = "python3.9"
  handler       = "index.lambda_handler"
  role          = aws_iam_role.lambda_execution_role.arn
}

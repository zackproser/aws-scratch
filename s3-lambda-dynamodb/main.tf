terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

data "archive_file" "lambda_zip_dir" {
  type = "zip"
  output_path = "/tmp/lambda_zip_dir.zip"
  source_dir = "src"
}

resource "aws_lambda_function" "url_reader" {
  function_name = "${var.app_name}-function"
  filename      = data.archive_file.lambda_zip_dir.output_path
  runtime       = "python3.9"
  handler       = "python/index.lambda_handler"
  role          = aws_iam_role.lambda_execution_role.arn
}

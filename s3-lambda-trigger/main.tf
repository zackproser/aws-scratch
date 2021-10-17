terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

data "archive_file" "lambda_zip_dir" {
  type        = "zip"
  output_path = "/tmp/lambda_zip_dir.zip"
  source_dir  = "${path.module}/src"
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.url_reader.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.source_bucket.arn
}

resource "aws_lambda_function" "url_reader" {
  function_name = "${var.app_name}-function"
  filename      = data.archive_file.lambda_zip_dir.output_path
  source_code_hash = data.archive_file.lambda_zip_dir.output_base64sha256
  runtime       = "python3.9"
  handler       = "index.lambda_handler"
  role          = aws_iam_role.lambda_execution_role.arn
  tracing_config {
    mode = "Active"
  }
}

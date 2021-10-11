resource "aws_s3_bucket" "source_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.source_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.url_reader.arn
    events = ["s3:ObjectCreated:*"]
  }
}

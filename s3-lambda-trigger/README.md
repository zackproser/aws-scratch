# S3 <-> Lambda Trigger Architecture

This directory contains a fully working end-to-end example of a serverless, event-driven architecture that uses AWS S3 object uploads to trigger a lambda function which will:

- Read the new text file from S3
- Convert its contents to uppercase
- Put the uppercase contents back to the file of the same key

It uses a zip_archive to bundle the `src` directory, containing the lambda function's source code. This is done so that any code changes to the `src` directory will be picked up and applyed on the next `terraform apply`, because the `source_code_hash` attribute will constantly change as you update the lambda's python source locally.

# Deploying

1. Configure your AWS account credentials
2. `cd src && pip install -r requirements.txt -t .` to build the Lambda function's source
3. `terraform apply`

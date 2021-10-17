import boto3
import requests
import urllib.parse


def lambda_handler(event, context):
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    print("Bucket: {}  Key: {}".format(bucket, key))

    s3 = boto3.resource("s3")
    obj = s3.Object(bucket, key)
    original_string = obj.get()["Body"].read().decode('utf-8')

    # Transform text
    transformed_text = original_string.upper()

    # Write object back to S3 Object Lambda
    result = obj.put(Body=transformed_text)

    return {'status_code': 200}

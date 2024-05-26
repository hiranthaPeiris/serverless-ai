from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.typing import LambdaContext
import boto3
import os,json
from botocore.config import Config
import shortuuid
import requests

logger = Logger()

S3_BUCKET = os.environ["S3_BUCKET"]
REGION = os.environ["REGION"]

# s3_client = boto3.client('s3',endpoint_url=f"https://s3.{REGION}.amazonaws.com",
#     config=Config(
#         s3={"addressing_style": "virtual"}, region_name=REGION, signature_version="s3v4"
#     ),)
s3_client = boto3.client('s3')

def generate_presinged_url(key) -> str:

    #generate URL
    try:
        pre_signedURL = s3_client.generate_presigned_url( ClientMethod="put_object",
                                                            Params={
                                                                "Bucket": S3_BUCKET,
                                                                "Key": key
                                                                # "ContentType": "application/pdf",
                                                            },
                                                            ExpiresIn=3600)
        logger.debug(f"Pre-sign URL: {pre_signedURL}")
    except Exception as e:
        logger.exception(f"Exception in URL gen: {e}")
        return None
    
    return pre_signedURL

def check_file_exists(key):
    try:
        s3_client.head_object(Bucket=S3_BUCKET, Key=key)
        return True
    except:
        return False


@logger.inject_lambda_context
def lambda_handler(event: dict, context: LambdaContext) -> str:

    # user_id = event["requestContext"]["authorizer"]["jwt"]["claims"]["sub"]
    user_id = event["queryStringParameters"]["user_id"]
    file_name_request = event["queryStringParameters"]["file_name"]

    file_name = file_name_request.split('.pdf')[0]

    key = f"{user_id}/{file_name}/{file_name_request}"

    #check if file exisits
    exists = check_file_exists(key)
    if exists:
        suffix = shortuuid.ShortUUID().random(length=4)
        key = f"{user_id}/{file_name}-{suffix}.pdf/{file_name}-{suffix}.pdf"
    else:
        key = f"{user_id}/{file_name}/{file_name}.pdf"

    presigned_url = generate_presinged_url(key=key)
    logger.info(f"{key}")

    # You can log entire objects too
    logger.info({"operation": "s3 file url gen", "file key": {key},"presiged":{presigned_url}})
    
    #Test file upload with presigned URL with test.pdf file
    with open('test.pdf','rb') as file:
        upload_response = requests.put(presigned_url,data=file)
        logger.debug({"operation":"test file upload","upload_response":upload_response.reason})
    
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Headers": "*",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "*",
        },
        "body":json.dumps({"presigned":presigned_url,"file_upload_status":upload_response.status_code})
    }



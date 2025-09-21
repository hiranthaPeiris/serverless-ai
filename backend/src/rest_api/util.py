from aws_lambda_powertools import Logger
import boto3
import os
from botocore.config import Config


logger = Logger()

S3_BUCKET = os.environ["S3_BUCKET"]
REGION = os.environ["REGION"]
DOCUMENTS_TABLE = os.environ["DOCUMENTS_TABLE"]
MEMORY_TABLE = os.environ["MEMORY_TABLE"]

s3_client = boto3.client('s3',endpoint_url=f"https://s3.{REGION}.amazonaws.com",
    config=Config(
        s3={"addressing_style": "virtual"}, region_name=REGION, signature_version="s3v4"
    ),)
#s3_client = boto3.client('s3')

dynamodb_client = boto3.resource('dynamodb', region_name=REGION)


def generate_presinged_url(key) -> str:

    #generate URL
    try:
        pre_signedURL = s3_client.generate_presigned_url( ClientMethod="put_object",
                                                            Params={
                                                                "Bucket": S3_BUCKET,
                                                                "Key": key,
                                                                "ContentType": "application/pdf",
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

def get_documents(tabal_name,**kwargs):
    table = dynamodb_client.Table(tabal_name)

    key_schema = table.key_schema
    key_names = [k["AttributeName"] for k in key_schema]

    key = {}
    for k in key_names:
        if k in kwargs:
            key[k] = kwargs[k]

    if len(key) != len(key_names):
        raise ValueError(f"Missing key(s). Provided keys: {list(key.keys())}, Required keys: {key_names}")
        
    response = table.get_item(key=key)
    item = response.get('Item', None)

    return item
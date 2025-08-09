from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.typing import LambdaContext
import boto3
import os,json
import shortuuid
from botocore.config import Config
import PyPDF2
import datetime
logger = Logger()

DOCUMENTS_TABLE = os.environ["DOCUMENTS_TABLE"]
MEMORY_TABLE = os.environ["MEMORY_TABLE"]
REGION = os.environ["REGION"]
BUCKET_NAME = os.environ["S3_BUCKET"]
QUEUE = os.environ['QUEUE']

s3_client = boto3.client('s3',endpoint_url=f"https://s3.{REGION}.amazonaws.com",
    config=Config(
        s3={"addressing_style": "virtual"}, region_name=REGION, signature_version="s3v4"
    ),)

dynamodb_client = boto3.resource('dynamodb', region_name=REGION)
sqs = boto3.client('sqs',region_name=REGION)

documents_tabel = dynamodb_client.Table(DOCUMENTS_TABLE)
memory_table = dynamodb_client.Table(MEMORY_TABLE)

@logger.inject_lambda_context
def lambda_handler(event: dict, context: LambdaContext) -> str:
    # s3 file name path pattern "userid/filename.pdf/filename.pdf"
    key = event["Records"][0]["s3"]["object"]["key"]
    split_key = key.split("/")
    user_id = split_key[0]
    file_name = split_key[1]
    
    document_id = shortuuid.uuid()
    conversation_id = shortuuid.uuid()
    
    s3_client.download_file(BUCKET_NAME, key, f"/tmp/{key}")
    
    with open(f"/tmp/{key}", "rb") as file:
        pdf = PyPDF2.PdfFileReader(file)
        num_pages = pdf.getNumPages()
        
    timestamp = datetime.datetime.now()
    document = {
        "document_id": document_id,
        "user_id": user_id,
        "file_name": file_name,
        "num_pages": num_pages,
        "timestamp": timestamp,
        "file_size" : event["Records"][0]["s3"]["object"]["size"],
        "conversations:":[]
    }

    conversation = {"conversation_id":conversation_id,"last_timestamp":timestamp}
    document["conversations"].append(conversation)
    
    logger.info(f"Document: {document}")
    
    documents_tabel.put_item(Item=document)
    
    conversation = {"SessionID":conversation_id, "History":[]}
    memory_table.put_item(Item=conversation)
    
    message = {"document_id":document_id,"key":key,"user_id":user_id}
    sqs.send_message(QueueUrl=QUEUE, MessageBody=json.dumps(message))
    
    return {"statusCode": 200, "body": json.dumps(message)}
    
    
    
    
    
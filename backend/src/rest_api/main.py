import requests
from requests import Response

from aws_lambda_powertools import Logger, Tracer
from aws_lambda_powertools.event_handler import APIGatewayHttpResolver
from aws_lambda_powertools.logging import correlation_paths
from aws_lambda_powertools.utilities.typing import LambdaContext

import boto3
import os,json
import shortuuid

import utils
tracer = Tracer()
logger = Logger()
app = APIGatewayHttpResolver()


@app.get("/api/generate_presigned_url")
@tracer.capture_method
def get_todos():
    # user_id = event["requestContext"]["authorizer"]["jwt"]["claims"]["sub"]
    # user_id = app.current_event.json_body["queryStringParameters"]["user_id"]
    user_id = app.current_event.query_string_parameters.get("user_id")
    file_name_request = app.current_event.query_string_parameters.get("file_name")
    file_name = file_name_request.split('.pdf')[0]

    key = f"{user_id}/{file_name}/{file_name_request}"

    #check if file exisits
    exists = utils.check_file_exists(key)
    if exists:
        suffix = shortuuid.ShortUUID().random(length=4)
        key = f"{user_id}/{file_name}-{suffix}.pdf/{file_name}-{suffix}.pdf"
    else:
        key = f"{user_id}/{file_name}.pdf/{file_name}.pdf"

    presigned_url = utils.generate_presinged_url(key=key)
    logger.info(f"{key}")

    # You can log entire objects too
    logger.info({"operation": "s3 file url gen", "file key": {key},"presiged":{presigned_url}})
   
    # #Test file upload with presigned URL with test.pdf file
    # with open('test.pdf','rb') as file:
    #     upload_response = requests.put(presigned_url,data=file)
    #     logger.debug({"operation":"test file upload","upload_response":upload_response.reason})
   
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Headers": "*",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "*",
        },
        # "body":json.dumps({"presigned":presigned_url,"file_upload_status":upload_response.status_code})
        "body":json.dumps({"presigned":presigned_url})
    }

@app.get("/api/doc")
def get_doc():
    todos: Response = requests.get("https://jsonplaceholder.typicode.com/todos")
    todos.raise_for_status()

    # for brevity, we'll limit to the first 10 only
    return {"todos": todos.json()[:3]}

@app.get("/doc/{documentid}/{conversationid}")
def get_doc_by_id(documentid: str, conversationid: str):
    # Simulating a document retrieval based on documentid and conversationid
    return {
        "documentid": documentid,
        "conversationid": conversationid,
        "content": "This is a simulated document content."
    }

# You can continue to use other utilities just as before
@logger.inject_lambda_context(correlation_id_path=correlation_paths.API_GATEWAY_HTTP)
@tracer.capture_lambda_handler
def lambda_handler(event: dict, context: LambdaContext) -> dict:
    return app.resolve(event, context)

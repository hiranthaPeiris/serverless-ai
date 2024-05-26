from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.typing import LambdaContext
import boto3
import os,json

logger = Logger()

@logger.inject_lambda_context
def lambda_handler(event: dict, context: LambdaContext) -> str:
    
    return ""
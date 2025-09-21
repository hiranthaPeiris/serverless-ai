variable "env" {
  type = string
}
variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
  default     = "serverless-ai-rest-api"
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket the Lambda will access"
  type        = string
  default     = "serverless-ai-docs-5u72"
}

variable "lambda_handler" {
  description = "The handler method for the Lambda function"
  type        = string
  default     = "main.lambda_handler"
}

variable "python_runtime" {
  description = "The runtime for the Lambda function"
  type        = string
  default     = "python3.13"
}

variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-southeast-1"

}

variable "document_table_name" {
  description = "The name of the DynamoDB table for documents"
  type        = string
  default     = "document_table"
}

variable "memory_table_name" {
  description = "The name of the DynamoDB table for conversations"
  type        = string
  default     = "conversation_table"

}
variable "sqs_name" {
  description = "The name of the SQS queue"
  type        = string
  default     = "serverless-processing-queue"

}
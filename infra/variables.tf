variable "env" {
  type = string
}
variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
  default     = "get-presigned-url"
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket the Lambda will access"
  type        = string
  default = "serverless-ai-docs-5u72"
}

variable "lambda_handler" {
  description = "The handler method for the Lambda function"
  type        = string
  default     = "main.lambda_handler"
}

variable "python_runtime" {
  description = "The runtime for the Lambda function"
  type        = string
  default     = "python3.11"
}

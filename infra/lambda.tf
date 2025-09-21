resource "aws_iam_role" "lambda_role" {
  name = "${var.lambda_function_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# CloudWatch Log Group with retention
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14

  tags = {
    Environment = "dev"
    Function    = var.lambda_function_name
  }
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "${var.lambda_function_name}-s3-policy"
  description = "Policy to allow Lambda to list and get objects from the specified S3 bucket"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = ["s3:GetObject", "s3:ListBucket"],
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      },
      {
        Action = ["s3:PutObject", "s3:GetObject", "s3:ListBucket"],
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "basic_execution_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "serverless_rest_api" {
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_role.arn
  handler          = var.lambda_handler
  runtime          = var.python_runtime
  filename         = "${path.module}/../backend/src/rest_api/_build.zip"
  source_code_hash = filebase64sha256("${path.module}/../backend/src/rest_api/_build.zip")
  timeout          = 30

  environment {
    variables = {
      S3_BUCKET = var.s3_bucket_name,
      REGION    = var.region
    }
  }
  depends_on = [
    aws_iam_role_policy_attachment.basic_execution_role,
    aws_cloudwatch_log_group.this
  ]
}

resource "aws_lambda_permission" "allow_invoke" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.serverless_rest_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}



#upload trigger lambda
resource "aws_iam_role" "lambda_role_upload_trigger" {
  name = "${var.lambda_function_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}





# CloudWatch Log Group with retention
resource "aws_cloudwatch_log_group" "upload_trigger" {
  name              = "/aws/lambda/serverless-upload-trigger"
  retention_in_days = 14

  tags = {
    Environment = "dev"
    Function    = "serverless-upload-trigger"
  }
}

resource "aws_iam_policy" "access_policy_upload_trigger" {
  name        = "serverless-upload-trigger-policy"
  description = "Policy to allow Lambda to list and get objects from the specified S3 bucket"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = ["s3:GetObject", "s3:ListBucket"],
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      },
      {
        Action = ["s3:PutObject", "s3:GetObject", "s3:ListBucket"],
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy_2" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "basic_execution_role_2" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_lambda_function" "upload_trigger" {
  function_name    = "serverless-upload-trigger"
  role             = aws_iam_role.lambda_role_upload_trigger.arn
  handler          = "upload_trigger.lambda_handler"
  runtime          = var.python_runtime
  filename         = "${path.module}/../backend/src/upload_trigger/_build.zip"
  source_code_hash = filebase64sha256("${path.module}/../backend/src/upload_trigger/_build.zip")
  timeout          = 30

  environment {
    variables = {
      S3_BUCKET       = var.s3_bucket_name,
      REGION          = var.region,
      DOCUMENTS_TABLE = var.document_table_name,
      MEMORY_TABLE    = var.memory_table_name,
      QUEUE           = var.sqs_name
    }
  }
  depends_on = [
    aws_iam_role_policy_attachment.basic_execution_role_2,
    aws_iam_role_policy_attachment.attach_policy_2,
    aws_cloudwatch_log_group.upload_trigger
  ]
}
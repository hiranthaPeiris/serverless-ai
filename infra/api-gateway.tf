resource "aws_apigatewayv2_api" "this" {
  name          = "serverless-ai-api"
  protocol_type = "HTTP"

    cors_configuration {
    allow_origins = ["*"]
    allow_headers = ["*"]
    allow_methods = ["*"]
  }
}

resource "aws_apigatewayv2_stage" "dev" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "dev"
  auto_deploy = true
}

# resource "aws_apigatewayv2_authorizer" "cognito" {
#   api_id          = aws_apigatewayv2_api.this.id
#   name            = "cognito-authorizer"
#   authorizer_type = "JWT"

#   identity_sources = ["$request.header.Authorization"]

#   jwt_configuration {
#     audience = [aws_cognito_user_pool_client.this.id]
#     issuer   = aws_cognito_user_pool.this.endpoint
#   }
# }


resource "aws_apigatewayv2_integration" "lambda" {
  api_id          = aws_apigatewayv2_api.this.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.serverless_rest_api.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "rest-api-route" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /api/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"

  # authorization_type = "JWT"
  # authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}
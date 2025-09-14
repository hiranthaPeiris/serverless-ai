    resource "aws_cognito_user_pool" "this" {
  name = "serverless-ai-pool"

  auto_verified_attributes = ["email"]
  username_attributes      = ["email"]

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  deletion_protection = "INACTIVE" # equivalent to DeletionPolicy: Delete
}

resource "aws_cognito_user_pool_client" "this" {
  name         = "serverless-ai-client"
  user_pool_id = aws_cognito_user_pool.this.id
  generate_secret = false
}

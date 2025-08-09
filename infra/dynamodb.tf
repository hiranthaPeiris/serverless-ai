resource "aws_dynamodb_table" "document_table" {
  name           = "document_table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "document_id"


  attribute {
    name = "document_id"
    type = "S"
  }

  tags = {
    Name        = "document_table"
    Environment = "dev"
  }
}

resource "aws_dynamodb_table" "conversation_table" {
  name           = "conversation_table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "conversation_id"


  attribute {
    name = "conversation_id"
    type = "S"
  }

  tags = {
    Name        = "conversation_table"
    Environment = "dev"
  }
}
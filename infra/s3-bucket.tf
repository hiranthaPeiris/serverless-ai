# Create an S3 bucket
resource "aws_s3_bucket" "document_s3" {
  bucket = var.s3_bucket_name # Ensure this bucket name is unique across all of AWS


  tags = {
    Name        = var.s3_bucket_name
    Environment = "Dev"
  }
}

# Optionally, you can add a bucket policy
resource "aws_s3_bucket_policy" "document_s3_policy" {
  bucket = aws_s3_bucket.document_s3.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = ["s3:Get*",
          "s3:List*",
          "s3:PutObject",
          "s3:PutObjectAcl"],

        Effect    = "Allow",
        Resource  = ["${aws_s3_bucket.document_s3.arn}/*", "${aws_s3_bucket.document_s3.arn}"],
        Principal = {
          AWS = aws_iam_role.lambda_role.arn
        }
      },
      {
        Sid       = "EnforceHttpsSid"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.document_s3.arn,
          "${aws_s3_bucket.document_s3.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_cors_configuration" "this" {
  bucket = aws_s3_bucket.document_s3.id

  cors_rule {
    allowed_headers = ["*"]

    allowed_methods = [
      "GET",
      "PUT",
      "HEAD",
      "POST",
      "DELETE",
    ]

    allowed_origins = ["*"]
  }
}

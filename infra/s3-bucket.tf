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
        Action    = ["s3:Get*",
                    "s3:List*",
                    "s3:PutObject",
                    "s3:PutObjectAcl"],

        Effect    = "Allow",
        Resource  = ["${aws_s3_bucket.document_s3.arn}/*","arn:aws:s3:::serverless-ai-yh89th"],
        Principal = "*"
      }
    ]
  })
}
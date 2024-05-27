# Create an S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-bucket-name-12345" # Ensure this bucket name is unique across all of AWS


  tags = {
    Name        = "MyBucket"
    Environment = "Dev"
  }
}

# Optionally, you can add a bucket policy
resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = ["s3:GetObject"],
        Effect    = "Allow",
        Resource  = ["${aws_s3_bucket.my_bucket.arn}/*"],
        Principal = "*"
      }
    ]
  })
}
# AWS SQS Queue
resource "aws_sqs_queue" "main_queue" {
  name                       = var.sqs_name
  visibility_timeout_seconds = 180
  message_retention_seconds  = 3600
  # Terraform does not use DeletionPolicy/UpdateReplacePolicy, but destroy will delete
}

# SQS Queue Policy
resource "aws_sqs_queue_policy" "main_queue_policy" {
  queue_url = aws_sqs_queue.main_queue.id
  policy    = <<POLICY
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Principal": "*",
			"Action": "sqs:SendMessage",
			"Resource": "${aws_sqs_queue.main_queue.arn}"
		}
	]
}
POLICY
}

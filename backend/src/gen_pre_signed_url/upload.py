# import boto3

# OBJ_NAME_UPLOAD = "test.pdf"

# S3_BUCKET = "serverless-ai-yh89th"
# REGION = ""

# s3_client = boto3.client('s3')

# #generate URL
# try:
#     pre_signedURL = s3_client.generate_presigned_url( ClientMethod="put_object",
#     Params={
#         "Bucket": S3_BUCKET,
#         "Key": OBJ_NAME_UPLOAD
#         "Key": OBJ_NAME_UPLOAD
#         # "ContentType": "application/pdf",
#     },
#     ExpiresIn=600)

# except Exception as e:
#     print(e)



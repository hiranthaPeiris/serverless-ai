terraform {
 required_providers {
   aws = {
    source = "hashicorp/aws"
   }
 }
 
 backend "s3" {
   region = "ap-southeast-1"
   key    = "serverless-ai/terraform.tfstate"
   dynamodb_table = "terraform-state-lock"
 }
}
 
provider "aws" {
 region = "ap-southeast-1"
}
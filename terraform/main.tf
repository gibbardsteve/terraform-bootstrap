# Requires DynamoDB Access and S3 Access on IAM Role
# Update the placeholders under < >
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

# Uncomment the following block once you have created the initial S3 and Dynamo DB resource using terraform
# terraform {
#   backend "s3" {
#     bucket         = "<BUCKET-NAME>"
#     key            = "<CHOOSE-UNIQUE-PATH-FOR-BOOTSRAP-STATE>/terraform.tfstate"
#     region         = "eu-west-2"
#     dynamodb_table = "<DYNAMO-DB-TABLE-NAME>"
#   }

# }

resource "aws_s3_bucket" "tf-state" {
  bucket = "<BUCKET-NAME>-tf-state"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.tf-state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "blocked" {
  bucket = aws_s3_bucket.tf-state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encrypt_by_default" {
  bucket = aws_s3_bucket.tf-state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = "<DYNAMO-DB-TABLE-NAME>"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
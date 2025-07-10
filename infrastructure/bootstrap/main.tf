# infrastructure/bootstrap/main.tf
provider "aws" {
  region  = "ap-southeast-1"
  profile = "default"
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "terraform-state-bucket-aptest"
  force_destroy = true
}

resource "aws_dynamodb_table" "terraform_locks" {
  name           = "terraform-locks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

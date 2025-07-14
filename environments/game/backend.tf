terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-aptest"
    key            = "dev/aws/terraform.tfstate"
    region         = "ap-southeast-1"
    profile        = "default"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

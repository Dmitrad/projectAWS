provider "aws" {
    region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "dzmitry-bucket-002"
    key    = "docs/myfile"
    region = "us-east-1"
  }
}
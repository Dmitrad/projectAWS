resource "aws_s3_bucket" "example" {
  bucket = "team2-artifact-bucket-aws"
  acl    = "private"

  force_destroy = true
}

#add your state file s3 bucket code here
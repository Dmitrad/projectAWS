resource "aws_s3_bucket" "example" {
  bucket = "devops2022-artifact-bucket"
  acl    = "private"

  force_destroy = true
}

#add your state file s3 bucket code here
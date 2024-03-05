resource "aws_s3_bucket" "example" {
  bucket = "my-circleci-test-bucket-12548624"

  tags = {
    Name        = "My bucket"
    Environment = "testing-circleci"
  }
}
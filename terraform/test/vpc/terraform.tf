terraform {
  backend "s3" {
  }
}

// get account id
data "aws_caller_identity" "current" {
}

